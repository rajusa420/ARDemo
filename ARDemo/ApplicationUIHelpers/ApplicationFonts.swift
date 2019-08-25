//
//  ApplicationFonts.swift
//  ARDemo
//
//  Created by Raj Sathi on 8/23/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import Foundation
import UIKit

public class ApplicationFonts {

    public static func labelFontName() -> String {
        return "Avenir-Book"
    }

    public static func labelFontSize() -> CGFloat {
        return 12
    }

    public static func infoLabelFont() -> UIFont? {
        return UIFont(name: ApplicationFonts.labelFontName(), size: UIFont.systemFontSize)
    }
}
