//
//  CustomSideViewController.swift
//  Zilliance
//
//  Created by mac on 17-04-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import Foundation
import UIKit
import SideMenuController

final class CustomSideViewController: SideMenuController
{
    func initialize()
    {
        SideMenuController.preferences.drawing.menuButtonImage = UIImage(named: "driving")
        SideMenuController.preferences.drawing.sidePanelPosition = .overCenterPanelLeft
        SideMenuController.preferences.drawing.sidePanelWidth = 300
        SideMenuController.preferences.drawing.centerPanelShadow = true
        SideMenuController.preferences.animating.statusBarBehaviour = .showUnderlay
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
        initialize()
    }
}
