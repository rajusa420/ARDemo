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

class ARDemoScene: SKScene {

    public var sceneView: ARSKView {
        return view as! ARSKView
    }

    public var sceneViewMode: SceneViewMode = .displayMode

    public var isWorldSetUp: Bool = false
    private var currentAnchors: [ARAnchor] = []
    public var anchorNames: [UUID: String] = [:]
    private var pixelBufferSize: CGSize = CGSize(width: 0, height: 0)
    private var analysisBufferId: UInt = 0

    private lazy var objectDetectionProcessor: ObjectDetector = ObjectDetectionProcessorFactory.getInstance()

    private let detectInfoLabelTag: Int = 55000
    private func setUpWorld() {
        guard let _: ARFrame = sceneView.session.currentFrame else {
            return
        }
//        // Test code to add an anchor at startup
//        // If we start saving anchors this is where we could load them up
//
//
//        var translation: simd_float4x4 = matrix_identity_float4x4
//        translation.columns.3.z = -0.3
//
//        let transform: simd_float4x4 = currentFrame.camera.transform * translation
//        let anchor: ARAnchor = ARAnchor(transform: transform)
//        sceneView.session.add(anchor: anchor)
//        currentAnchors.append(anchor)
//        anchorNames[anchor.identifier] = "Test Anchor"
        if let view = view {
            // Button to enable detection mode
            let viewFrame: CGRect = view.frame
            let buttonSize: CGSize = CGSize(width: 80, height: 80)
            let detectButton: DetectButton = DetectButton(frame: CGRect(origin: CGPoint(x: (viewFrame.size.width - buttonSize.width) / 2.0, y: viewFrame.size.height - buttonSize.height - 15.0), size: buttonSize))
            
            detectButton.addTarget(self, action: #selector(detectButtonTouchDown), for: .touchDown)
            detectButton.addTarget(self, action: #selector(detectButtonTouchUp), for: .touchUpInside)
            detectButton.addTarget(self, action: #selector(detectButtonTouchUp), for: .touchUpOutside)
            view.addSubview(detectButton)

            let detectionInfoLabel:UILabel = UILabel(frame: CGRect.zero)
            detectionInfoLabel.tag = detectInfoLabelTag;
            detectionInfoLabel.font = ApplicationFonts.infoLabelFont()
            detectionInfoLabel.textColor = ApplicationColors.textColor()
            detectionInfoLabel.backgroundColor = ApplicationColors.detectInfoLabelBackgroundColor()
            view.addSubview(detectionInfoLabel)
        }

        isWorldSetUp = true
    }

    private var shouldRefreshAnchors: Bool = false
    override func update(_ currentTime: TimeInterval) {
        if !isWorldSetUp {
            setUpWorld()
        }

        guard let currentFrame: ARFrame = sceneView.session.currentFrame else {
            return
        }

        // update is called 60 times per second so only pass in the image buffer if we
        // aren't already processing one
        if !objectDetectionProcessor.isProcessingSample && sceneViewMode == .detectMode {
            let capturedImage: CVPixelBuffer = currentFrame.capturedImage

            // Save the pixel buffer size so that later we can translate the position of the detected
            // object into the right coordinate space
            if self.pixelBufferSize.width == 0 || self.pixelBufferSize.height == 0 {
                let imageWidth: size_t = CVPixelBufferGetWidth(capturedImage)
                let imageHeight: size_t = CVPixelBufferGetHeight(capturedImage)
                self.pixelBufferSize = CGSize(width: imageWidth, height: imageHeight)
            }

            self.updateInfoText(text: "Analyzing frame: " + analysisBufferId.description)
            objectDetectionProcessor.detectObjects(buffer: capturedImage) { [weak self] detectedObjects, error in
                guard self?.sceneViewMode == .detectMode else {
                    return
                }

                self?.updateInfoText(text: "Frame Analyzed")
                self?.analysisBufferId += 1

                // Clear all current anchors for detected objects
                if let weakSelf = self {
                    for anchor: ARAnchor in weakSelf.currentAnchors {
                        weakSelf.sceneView.session.remove(anchor: anchor)
                    }

                    weakSelf.currentAnchors.removeAll()
                    weakSelf.anchorNames.removeAll()
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
        } else if sceneViewMode == .displayMode && shouldRefreshAnchors {
            shouldRefreshAnchors = false

            for anchor: ARAnchor in currentAnchors {
                if let node: SKNode = self.sceneView.node(for: anchor) {
                    if node is SKShapeNode  {
                        let shapeNode: SKShapeNode = node as! SKShapeNode
                        let backgroundColor = ApplicationColors.randomLabelBackgroundColor()
                        shapeNode.fillColor = backgroundColor
                        shapeNode.strokeColor = UIColor.white
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

    @objc public func detectButtonTouchDown(sender: UIButton) {
        sceneViewMode = .detectMode

        let feedbackGenerator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        feedbackGenerator.impactOccurred()

        self.updateInfoText(text: "Detect mode")
    }

    @objc public func detectButtonTouchUp(sender: UIButton) {
        sceneViewMode = .displayMode
        // Trigger a refresh of the anchors so the labels can change their colors
        // from record mode to display mode
        self.shouldRefreshAnchors = true
        self.updateInfoText(text: "")
    }

    private func updateInfoText(text: String) {
        if let detectInfoLabel: UILabel = self.detectInfoLabel() {
            detectInfoLabel.text = text
            self.layoutInfoLabel(infoLabel: detectInfoLabel)
        }
    }

    private func detectInfoLabel() -> UILabel? {
        if let view = view {
            return view.viewWithTag(detectInfoLabelTag) as? UILabel
        }

        return nil
    }

    override func didMove(to view: SKView) {
        if let detectInfoLabel: UILabel = self.detectInfoLabel() {
            self.layoutInfoLabel(infoLabel: detectInfoLabel)
        }
    }

    private func layoutInfoLabel(infoLabel: UILabel) {
        if let view = view {
            let viewFrame: CGRect = view.frame
            let safeAreaInsets: UIEdgeInsets = view.safeAreaInsets
            let infoLabelSizeRequired: CGSize = infoLabel.sizeThatFits(viewFrame.size)
            infoLabel.frame = CGRect(x: 5.0, y: safeAreaInsets.top + 2.0, width: infoLabelSizeRequired.width, height: infoLabelSizeRequired.height)
        }
    }
}
