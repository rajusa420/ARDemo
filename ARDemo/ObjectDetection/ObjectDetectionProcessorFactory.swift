//
// Created by Raj Sathi on 2019-08-23.
// Copyright (c) 2019 Raj. All rights reserved.
//

import Foundation

public class ObjectDetectionProcessorFactory {
    private static let useFirebaseProcessor: Bool = false

    public static func getInstance() -> ObjectDetector {
        if useFirebaseProcessor {
            return FirebaseObjectDetectionProcessor()
        }

        return CoreMLObjectDetectionProcessor()
    }
}