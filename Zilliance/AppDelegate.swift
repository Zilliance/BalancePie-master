//
//  AppDelegate.swift
//  Zilliance
//
//  Created by Philip Dow on 3/29/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit
import SideMenuController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
    	// App wide appearance
        
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().barTintColor = .darkBlueBackground
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.muliBold(size: 18)
        ]

        // Onboarding Logic

        var rootViewController: UIViewController?
        
        if Database.shared.user.activities.count > 0 {
            
            let sideMenuViewController = CustomSideViewController()
            sideMenuViewController.setupPie()
         	rootViewController = sideMenuViewController
            
        }
        else {
            rootViewController =  UIStoryboard(name: "Intro", bundle: nil).instantiateInitialViewController()
        }

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()

        
        return true
    }

}

