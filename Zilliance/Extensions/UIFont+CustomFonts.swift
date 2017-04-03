//
//  UIFont+CustomFonts.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 1/16/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import UIKit

extension UIFont {
    
    class func balancePieLightFont(ofSize size: (CGFloat)) -> UIFont {
        return UIFont(name: "Roboto-Light", size: size)!
    }
    
    class func balancePieThinFont(ofSize size: (CGFloat)) -> UIFont {
        return UIFont(name: "Roboto-Thin", size: size)!
    }
    
    class func balancePieItalicFont(ofSize size: (CGFloat)) -> UIFont {
        return UIFont(name: "Roboto-Italic", size: size)!
    }
    
    class func balancePieBlackFont(ofSize size: (CGFloat)) -> UIFont {
        return UIFont(name: "Roboto-Black", size: size)!
    }
    
    class func balancePieRegularFont(ofSize size: (CGFloat)) -> UIFont {
        return UIFont(name: "Roboto-Regular", size: size)!
    }
    
    class func balancePieMediumFont(ofSize size: (CGFloat)) -> UIFont {
        return UIFont(name: "Roboto-Medium", size: size)!
    }
    
    class func balancePieBoldFont(ofSize size: (CGFloat)) -> UIFont {
        return UIFont(name: "Roboto-Bold", size: size)!
    }
}
