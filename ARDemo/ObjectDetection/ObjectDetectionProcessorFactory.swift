//
// Created by Raj Sathi on 2019-08-23.
// Copyright (c) 2019 Raj. All rights reserved.
//

import Foundation

// Helper class that allows switching of object detection platforms
// Currently CoreML and Firebase are supported (Just using the default available models)
public class ObjectDetectionProcessorFactory {
    private static let useFirebaseProcessor: Bool = true

    public static func getInstance() -> ObjectDetector {
        if useFirebaseProcessor {
            return FirebaseObjectDetectionProcessor()
        }

        return CoreMLObjectDetectionProcessor()
    }
}