//
//  ViewController.swift
//  ARDemo
//
//  Created by Raj Sathi on 8/22/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSKViewDelegate {

    var sceneView: ARSKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as? ARSKView {
            sceneView = view
            sceneView!.delegate = self

            let scene = SceneView(size: view.bounds.size)
            scene.scaleMode = .resizeFill
            scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)

            view.presentScene(scene)
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSKViewDelegate

    /*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
    */

    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        let labelNode = SKLabelNode(fontNamed: ApplicationFonts.labelFontName())
        labelNode.fontColor = ApplicationColors.textColor()
        labelNode.fontSize = ApplicationFonts.labelFontSize()
        labelNode.color = UIColor.clear

        let currentSceneView: SceneView = sceneView!.scene as! SceneView
        if let anchorName: String = currentSceneView.anchorNames[anchor.identifier] {
            labelNode.text = anchorName
        }

        let labelFrame: CGRect = labelNode.frame
        labelNode.position = CGPoint(x:0, y: -((labelFrame.size.height / 2) - 1.0));

        let backgroundColorNode: SKSpriteNode = SKSpriteNode(color: ApplicationColors.randomLabelBackgroundColor(), size: CGSize(width: labelFrame.width, height: labelFrame.height))
        backgroundColorNode.position = CGPoint(x: 200, y: 100)
        
        // TODO: Figure out why the background color isn't applying
        backgroundColorNode.color = ApplicationColors.randomLabelBackgroundColor()
        backgroundColorNode.colorBlendFactor = 1
        backgroundColorNode.blendMode = .replace
        backgroundColorNode.addChild(labelNode)

        return backgroundColorNode
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
    }

    func sessionWasInterrupted(_ session: ARSession) {
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        sceneView.session.run(session.configuration!, options: [.resetTracking, .removeExistingAnchors])
    }
}
