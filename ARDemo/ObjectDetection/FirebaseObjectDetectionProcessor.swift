//
// Created by Raj Sathi on 2019-08-22.
// Copyright (c) 2019 Raj. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import MLKitObjectDetection
import MLKitVision

class FirebaseObjectDetectionProcessor: ObjectDetectionProvider {

    private lazy var visionDetectionOptions: ObjectDetectorOptions = {
        let options = ObjectDetectorOptions()
        options.detectorMode = .singleImage
        options.shouldEnableMultipleObjects = true
        options.shouldEnableClassification = true
        return options
    }()

    private lazy var objectDetector: ObjectDetector = {
        let objectDetector = ObjectDetector.objectDetector(options: self.visionDetectionOptions)
        return objectDetector
    }()

    public var isProcessingSample: Bool = false

    public func detectObjects(buffer pixelBuffer: CVPixelBuffer, completion: @escaping ObjectDetectionCallback) {
        guard !isProcessingSample else {
            return
        }

        isProcessingSample = true
        guard let sampleBuffer: CMSampleBuffer = ImageBufferHelpers.getCMSampleBuffer(buffer: pixelBuffer) else {
            isProcessingSample = false
            return
        }

        // Asynchronously process the sample and detect objects
        let image: VisionImage = getVisionImage(buffer: sampleBuffer)
        objectDetector.process(image) { [weak self] visionDetectedObjects, error in
            DispatchQueue.main.async(execute: {
                // Reset our processing flag once we are done via defer
                defer {
                    self?.isProcessingSample = false
                }
                
                guard error == nil else {
                    // Error.
                    return
                }

                guard let visionDetectedObjects = visionDetectedObjects, visionDetectedObjects.count > 0 else {
                    // No objects detected.
                    return
                }

                var detectedObjects: [DetectedObject] = []
                for visionObject: Object in visionDetectedObjects {
                    for label in visionObject.labels {
                        // Only include objects that meet a confidence threshold
                        if  label.confidence > DetectedObjectConfidenceRequired {
                            detectedObjects.append(DetectedObject(frame: visionObject.frame, name: label.text, description: ""))
                        }
                    }
                }

                // Only call the completion delegate if objects are detected that way if any objects were
                // previously detected they remain displayed
                if detectedObjects.count > 0 {
                    completion(detectedObjects, nil)
                }
            })
        }
    }

    private func getVisionImage(buffer sampleBuffer: CMSampleBuffer) -> VisionImage {
        let image: VisionImage = VisionImage(buffer: sampleBuffer)
        image.orientation = imageOrientation(deviceOrientation: UIDevice.current.orientation)
        return image
    }

    private func imageOrientation(deviceOrientation: UIDeviceOrientation) -> UIImage.Orientation {
        switch deviceOrientation {
            case UIDeviceOrientation.portrait, .faceUp:
                return UIImage.Orientation.right
            case UIDeviceOrientation.portraitUpsideDown, .faceDown:
                return UIImage.Orientation.left
            case UIDeviceOrientation.landscapeLeft:
                return UIImage.Orientation.up
            case UIDeviceOrientation.landscapeRight:
                return UIImage.Orientation.down
            default:
                return UIImage.Orientation.up
        }
    }
}
