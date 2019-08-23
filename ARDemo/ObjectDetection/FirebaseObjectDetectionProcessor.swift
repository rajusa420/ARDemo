//
// Created by Raj Sathi on 2019-08-22.
// Copyright (c) 2019 Raj. All rights reserved.
//

import Foundation
import Firebase
import AVFoundation

class FirebaseObjectDetectionProcessor: ObjectDetector {

    private lazy var visionDetectionOptions: VisionObjectDetectorOptions = {
        let options = VisionObjectDetectorOptions()
        options.detectorMode = .singleImage
        options.shouldEnableMultipleObjects = true
        options.shouldEnableClassification = true
        return options
    }()

    private lazy var objectDetector: VisionObjectDetector = {
        let objectDetector = Vision.vision().objectDetector(options: self.visionDetectionOptions)
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
        objectDetector.process(image) { [weak self] detectedVisionObjects, error in
            defer { self?.isProcessingSample = false }
            guard error == nil else {
                // Error.
                return
            }

            guard let detectedVisionObjects: [VisionObject] = detectedVisionObjects, !detectedVisionObjects.isEmpty else {
                // No objects detected.
                return
            }

            var detectedObjects: [DetectedObject] = []
            for visionObject: VisionObject in detectedVisionObjects {
                if let confidence = visionObject.confidence?.floatValue, confidence > DetectedObjectConfidenceRequired {
                    detectedObjects.append(DetectedObject(frame: visionObject.frame, name: self?.getStringFromDetectedObjectCategory(category: visionObject.classificationCategory) ?? "Unknown", description: ""))
                }
            }

            if detectedObjects.count > 0 {
                completion(detectedObjects, nil)
            }
        }
    }

    private func getVisionImage(buffer sampleBuffer: CMSampleBuffer) -> VisionImage {
        let image: VisionImage = VisionImage(buffer: sampleBuffer)
        image.metadata = getVisionImageMetadata()
        return image
    }

    private func getVisionImageMetadata() -> VisionImageMetadata {
        let cameraPosition = AVCaptureDevice.Position.back
        let metadata: VisionImageMetadata = VisionImageMetadata()
        metadata.orientation = imageOrientation(deviceOrientation: UIDevice.current.orientation, cameraPosition: cameraPosition)
        return metadata
    }

    private func imageOrientation(deviceOrientation: UIDeviceOrientation, cameraPosition: AVCaptureDevice.Position) -> VisionDetectorImageOrientation {
        switch deviceOrientation {
        case .portrait:
            return cameraPosition == .front ? .leftTop : .rightTop
        case .landscapeLeft:
            return cameraPosition == .front ? .bottomLeft : .topLeft
        case .portraitUpsideDown:
            return cameraPosition == .front ? .rightBottom : .leftBottom
        case .landscapeRight:
            return cameraPosition == .front ? .topRight : .bottomRight
        case .faceDown, .faceUp, .unknown:
            return .leftTop
        default:
            return .topLeft
        }
    }

    private func getStringFromDetectedObjectCategory(category: VisionObjectCategory)-> String {
        switch category {
        case .fashionGoods:
            return "Fashion Goods"
        case .food:
            return "Food"
        case .homeGoods:
            return "Home Goods"
        case . places:
            return "Places"
        case .plants:
            return "Plants"
        case .unknown:
            return "Unknown"
        default:
            return "New Type"
        }
    }
}
