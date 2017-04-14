//
//  PartialSizePresentationController.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 06-04-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import Foundation
import UIKit

class PartialSizePresentationController : UIPresentationController {
    
    fileprivate var height: CGFloat = 0
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, height: CGFloat) {
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        self.height = height
                
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        
        guard let containerView = containerView else {return CGRect()}
        
        return CGRect(x: 0, y: containerView.frame.size.height - self.height, width: containerView.bounds.width, height: self.height)
    }
    
    override var shouldPresentInFullscreen: Bool {
        return false
    }
    
}
