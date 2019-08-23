//
// Created by Raj Sathi on 2019-08-23.
// Copyright (c) 2019 Raj. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreML
import Vision

public class CoreMLObjectDetectionProcessor: ObjectDetector {

    init() {
        self.setupObjectDetectionProcess()
    }

    private lazy var visionModel: VNCoreMLModel? = {
        do {
            guard let modelURL = Bundle.main.url(forResource: "ObjectDetectorModel", withExtension: "mlmodelc") else {
                NSLog("Error loading model")
                return nil
            }
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            return visionModel
        } catch {
            NSLog("Error loading model")
        }

        return nil
    }()

    private var requests = [VNRequest]()
    private func setupObjectDetectionProcess() {
    if let visionModel = visionModel {
        let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
            DispatchQueue.main.async(execute: {
                [weak self] in
                // perform all the UI updates on the main queue
                defer { self?.isProcessingSample = false }
                if let callback = self?.objectDetectionCallBack, let pixelBufferWidth = self?.pixelBufferSize.width, let pixelBufferHeight = self?.pixelBufferSize.height {
                    if let results = request.results {
                        var detectedObjects: [DetectedObject] = []
                        for observation in results where observation is VNRecognizedObjectObservation {
                            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                                continue
                            }

                            let topLabelObservation = objectObservation.labels[0]
                            NSLog("Object found: " + topLabelObservation.identifier + ":" + objectObservation.confidence.description)
                            
                            if objectObservation.confidence > DetectedObjectConfidenceRequired {
                                let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(pixelBufferWidth), Int(pixelBufferHeight))
                                detectedObjects.append(DetectedObject(frame: objectBounds, name: topLabelObservation.identifier, description: topLabelObservation.description))
                            }
                        }

                        if detectedObjects.count > 0 {
                            callback(detectedObjects, nil)
                        }
                    }
                }
            })
        })
        self.requests = [objectRecognition]
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
