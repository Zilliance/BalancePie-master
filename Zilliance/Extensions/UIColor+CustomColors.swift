//
//  UIColor+CustomColors.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 1/23/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import UIKit

extension UIColor {
    
    static let lightBlueBackground = UIColor.color(forRed: 1, green: 188, blue: 213, alpha: 1)
    static let darkBlueBackground = UIColor(red: 30.0/255.0, green: 43.0/255.0, blue: 62.0/255.0, alpha: 1)
    static let darkBlueBackground2 = UIColor(red: 51.0/255.0, green: 74.0/255.0, blue: 95.0/255.0, alpha: 1)
    static let darkBlueBackground3 = UIColor(red: 74.0/255.0, green: 100.0/255.0, blue: 124.0/255.0, alpha: 1)
    static let lightGrayBackground = UIColor(white: 0.94, alpha: 1.0)
    
    
    static let lightGray = UIColor.color(forRed: 213, green: 213, blue: 213, alpha: 1)
    static let textGray = UIColor.color(forRed: 27, green: 36, blue: 48, alpha: 1)
    
    static let buttonBackground = UIColor.color(forRed: 18.0, green: 44.0, blue: 77.0, alpha: 1)
    static let activityCellSeparator = UIColor.color(forRed: 255, green: 255, blue: 255, alpha: 0.49)
    
    static let toogleButtonSelected = UIColor.color(forRed: 0, green: 188.0, blue: 212.0, alpha: 1)
    static let toogleButtonUnselected = UIColor.color(forRed: 4, green: 159.0, blue: 185.0, alpha: 1)
    
    static let selectedIcon = UIColor.color(forRed: 120.0, green: 139.0, blue: 167.0, alpha: 0.5)
    static let unselectedIcon = UIColor.color(forRed: 120.0, green: 139.0, blue: 167.0, alpha: 0.2)
    
    static let iconsCollectionViewBackground = UIColor.color(forRed: 30.0, green: 43.0, blue: 62.0, alpha: 1.0)
    static let sliderThumb = UIColor.color(forRed: 50.0, green: 68.0, blue: 92.0, alpha: 1.0)
    static let overlay = UIColor.color(forRed: 0, green: 0, blue: 0, alpha: 0.5)
    
    class func color(forRed red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
}

extension UIColor {

    func lighter(amount : CGFloat = 0.25) -> UIColor {
        return self.hueColorWithBrightnessAmount(amount: 1 + amount)
    }

    func darker(amount : CGFloat = 0.25) -> UIColor {
        return self.hueColorWithBrightnessAmount(amount: 1 - amount)
    }

    private func hueColorWithBrightnessAmount(amount: CGFloat) -> UIColor {
        var hue         : CGFloat = 0
        var saturation  : CGFloat = 0
        var brightness  : CGFloat = 0
        var alpha       : CGFloat = 0       

        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor( hue: hue,
                            saturation: saturation,
                            brightness: brightness * amount,
                            alpha: alpha )
        } else {
            return self
        }
    }
}
