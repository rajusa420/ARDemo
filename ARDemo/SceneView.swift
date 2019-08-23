//
// Created by Raj Sathi on 2019-08-22.
// Copyright (c) 2019 Raj. All rights reserved.
//

import Foundation
import ARKit
import Firebase

enum SceneViewMode {
    case displayMode
    case detectMode
}

class SceneView: SKScene {

    public var sceneView: ARSKView {
        return view as! ARSKView
    }

    public var sceneViewMode: SceneViewMode = .displayMode

    public var isWorldSetUp: Bool = false
    private var currentAnchors: [ARAnchor] = []
    public var anchorNames: [UUID: String] = [:]
    private var pixelBufferSize: CGSize = CGSize(width: 0, height: 0)

    private lazy var objectDetectionProcessor: ObjectDetector = ObjectDetectionProcessorFactory.getInstance()

    private func setUpWorld() {
        guard let currentFrame = sceneView.session.currentFrame
                else { return }

        var translation: simd_float4x4 = matrix_identity_float4x4
        translation.columns.3.z = -0.3

        let transform = currentFrame.camera.transform * translation
        let anchor = ARAnchor(transform: transform)
        sceneView.session.add(anchor: anchor)
        currentAnchors.append(anchor)

        isWorldSetUp = true
    }

    override func update(_ currentTime: TimeInterval) {
        if !isWorldSetUp {
            setUpWorld()
        }
        
        guard let currentFrame: ARFrame = sceneView.session.currentFrame else {
            return
        }

        if !objectDetectionProcessor.isProcessingSample && sceneViewMode == .detectMode {
            let capturedImage: CVPixelBuffer = currentFrame.capturedImage

            if self.pixelBufferSize.width == 0 || self.pixelBufferSize.height == 0 {
                let imageWidth: size_t = CVPixelBufferGetWidth(capturedImage)
                let imageHeight: size_t = CVPixelBufferGetHeight(capturedImage)
                self.pixelBufferSize = CGSize(width: imageWidth, height: imageHeight)
            }
            
            objectDetectionProcessor.detectObjects(buffer: capturedImage) { [weak self] detectedObjects, error in
                guard self?.sceneViewMode == .detectMode else {
                    return
                }

                if var currentAnchors = self?.currentAnchors, var anchorNames = self?.anchorNames {
                    for anchor: ARAnchor in currentAnchors {
                        self?.sceneView.session.remove(anchor: anchor)
                    }
                    
                    currentAnchors.removeAll()
                    anchorNames.removeAll()
                }

                guard let detectedObjects: [DetectedObject] = detectedObjects, !detectedObjects.isEmpty, let scene = self?.scene else {
                    // No objects detected.
                    return
                }

                for detectedObject: DetectedObject in detectedObjects {
                    let objectFrame: CGRect = detectedObject.frame
                    let sceneSize: CGSize = scene.size
                    if let bufferSize: CGSize = self?.pixelBufferSize {
                        let positionX: CGFloat = ((objectFrame.origin.x + (objectFrame.size.width / 2.0)) / bufferSize.width) * sceneSize.width
                        let positionY: CGFloat = ((objectFrame.origin.y + (objectFrame.size.height / 2.0)) / bufferSize.height) * sceneSize.height

                        if let results: [ARHitTestResult] = self?.sceneView.hitTest(CGPoint(x: positionX, y: positionY), types: [.featurePoint, .existingPlaneUsingGeometry]), results.count > 0 {
                            if let result: ARHitTestResult = results.first {
                                let transform = result.worldTransform
                                let anchor = ARAnchor(transform: transform)
                                self?.sceneView.session.add(anchor: anchor)
                                self?.currentAnchors.append(anchor)
                                self?.anchorNames[anchor.identifier] = detectedObject.name
                            }
                        }
                    }
                }
            }
        }
        
        if let lightEstimate = currentFrame.lightEstimate {
            let neutralIntensity: CGFloat = 1000
            let ambientIntensity = min(lightEstimate.ambientIntensity,
                    neutralIntensity)
            let blendFactor = 1 - ambientIntensity / neutralIntensity

            for node in children {
                if let node = node as? SKSpriteNode {
                    node.color = .black
                    node.colorBlendFactor = blendFactor
                }
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        sceneViewMode = .detectMode

        let feedbackGenerator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        feedbackGenerator.impactOccurred()

        super.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneViewMode = .displayMode
        super.touchesEnded(touches, with: event)
    }
}
