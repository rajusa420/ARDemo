//
//  DetectButton.swift
//  ARDemo
//
//  Created by Raj Sathi on 8/24/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import Foundation
import UIKit

public class DetectButton: UIButton {

    override public func draw(_ rect: CGRect) {
        let padding: CGFloat = 5

        let outerRingFrame: CGRect = rect.insetBy(dx: padding, dy: padding)
        let outerRingLineWidth: CGFloat = 5
        let outerRing: UIBezierPath = UIBezierPath(ovalIn: CGRect(x:padding, y:padding, width:outerRingFrame.width, height:outerRingFrame.height))
        outerRing.lineWidth = outerRingLineWidth
        ApplicationColors.detectButtonOuterRingColor().setStroke()
        outerRing.stroke()

        let innerRingInset: CGFloat = padding + outerRingLineWidth
        let innerRingFrame: CGRect = rect.insetBy(dx: innerRingInset, dy: innerRingInset)
        let innerRing: UIBezierPath = UIBezierPath(ovalIn: CGRect(x:innerRingInset, y:innerRingInset, width:innerRingFrame.width, height:innerRingFrame.height))
        if isSelected || self.isHighlighted {
            ApplicationColors.detectButtonInnerRingPressedColor().setFill()
        } else {
            ApplicationColors.detectButtonInnerRingColor().setFill()
        }
        innerRing.fill()
    }

    public override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            if super.isSelected != newValue {
                self.setNeedsDisplay()
            }
            super.isSelected = newValue
        }
    }
    
    public override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if super.isHighlighted != newValue {
                self.setNeedsDisplay()
            }
            super.isHighlighted = newValue
        }
    }
}
