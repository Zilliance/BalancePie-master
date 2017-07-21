//
//  CustomNavigationController.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 7/20/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}
