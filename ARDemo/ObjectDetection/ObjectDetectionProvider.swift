//
//  ObjectDetector.swift
//  ARDemo
//
//  Created by Raj Sathi on 8/23/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import Foundation
import ARKit

public class DetectedObject {
    public var frame: CGRect = CGRect.zero
    public var name: String = ""
    public var description: String? = ""

    convenience init(frame: CGRect, name: String, description: String?) {
        self.init()

        self.frame = frame
        self.name = name
        self.description = description
    }
}

public typealias ObjectDetectionCallback = ([DetectedObject]?, Error?) -> Void

public protocol ObjectDetectionProvider {
    var isProcessingSample: Bool { get set }

    func detectObjects(buffer pixelBuffer: CVPixelBuffer, completion: @escaping ObjectDetectionCallback)
}

public let DetectedObjectConfidenceRequired: Float = 0.75
