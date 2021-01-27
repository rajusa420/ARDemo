//
// Created by Raj Sathi on 2019-08-23.
// Copyright (c) 2019 Raj. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreML
import Vision

public class CoreMLObjectDetectionProcessor: ObjectDetectionProvider {

    init() {
        self.setupObjectDetectionProcess()
    }

    private lazy var visionModel: VNCoreMLModel? = {
        do {
            guard let modelURL: URL = Bundle.main.url(forResource: "ObjectDetectorModel", withExtension: "mlmodelc") else {
                NSLog("Error loading model from bundle")
                return nil
            }
            let visionModel: VNCoreMLModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            return visionModel
        } catch {
            NSLog("Exception thrown while loading model")
        }

        return nil
    }()

    private var requests = [VNRequest]()

    private func setupObjectDetectionProcess() {
        if let visionModel: VNCoreMLModel = visionModel {
            // The object recognition request is setup here and is passed in to VNImageRequestHandler in the detect
            // objects method to perform the object detection
            let objectRecognitionRequest: VNCoreMLRequest = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                // Perform the processing and creation of detected objects on the main thread
                DispatchQueue.main.async(execute: {
                    [weak self] in
                    defer {
                        // Once we are done with the processing reset our flags via defer
                        self?.isProcessingSample = false
                    }

                    if let callback: ObjectDetectionCallback = self?.objectDetectionCallBack,
                       let pixelBufferWidth: CGFloat = self?.pixelBufferSize.width,
                       let pixelBufferHeight: CGFloat = self?.pixelBufferSize.height,
                       let results: [Any] = request.results {

                        var detectedObjects: [DetectedObject] = []
                        for observation in results where observation is VNRecognizedObjectObservation {
                            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                                continue
                            }

                            let topLabelObservation: VNClassificationObservation = objectObservation.labels[0]
                            NSLog("Object found: " + topLabelObservation.identifier + ":" + objectObservation.confidence.description)

                            // We don't label objects that we find that are below a confidence threshold
                            if objectObservation.confidence > DetectedObjectConfidenceRequired {
                                let objectBounds: CGRect = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(pixelBufferWidth), Int(pixelBufferHeight))
                                detectedObjects.append(DetectedObject(frame: objectBounds, name: topLabelObservation.identifier, description: topLabelObservation.description))
                            }
                        }

                        // Only call the completion delegate if objects are detected that way if any objects were
                        // previously detected they remain displayed
                        if detectedObjects.count > 0 {
                            callback(detectedObjects, nil)
                        }

                    }
                })
            })
            self.requests = [objectRecognitionRequest]
        }
    }

    public var isProcessingSample: Bool = false
    private var objectDetectionCallBack: ObjectDetectionCallback? = nil
    private var pixelBufferSize: CGSize = CGSize(width: 0, height: 0)

    public func detectObjects(buffer pixelBuffer: CVPixelBuffer, completion: @escaping ObjectDetectionCallback) {
        guard !isProcessingSample else {
            return
        }

        isProcessingSample = true
        objectDetectionCallBack = completion

        let imageWidth: size_t = CVPixelBufferGetWidth(pixelBuffer)
        let imageHeight: size_t = CVPixelBufferGetHeight(pixelBuffer)
        pixelBufferSize = CGSize(width: imageWidth, height: imageHeight)

        let exifOrientation = exifOrientationFromDeviceOrientation()
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            isProcessingSample = false
            print(error)
        }
    }

    private func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation

        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }

        return exifOrientation
    }
}
