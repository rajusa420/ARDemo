//
//  ApplicationColors.swift
//  ARDemo
//
//  Created by Raj Sathi on 8/23/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import Foundation
import UIKit

public class ApplicationColors {

    public static func textColor() -> UIColor {
        return UIColor.white
    }

    public static func randomLabelBackgroundColor() -> UIColor {
        let red: Float = Float(arc4random_uniform(255)) / Float(255.0)
        let blue: Float = Float(arc4random_uniform(255)) / Float(255.0)
        let green: Float = Float(arc4random_uniform(255)) / Float(255.0)
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
    }
    
    public static func detectButtonOuterRingColor() -> UIColor {
        return UIColor.white
    }
    
    public static func detectButtonInnerRingColor() -> UIColor {
        return UIColor.red
    }
    
    public static func detectButtonInnerRingPressedColor() -> UIColor {
        return UIColor.gray
    }

    public static func detectLabelBackgroundColor() -> UIColor {
        return UIColor.red
    }
}
