//
//  AppDelegate.swift
//  Zilliance
//
//  Created by Philip Dow on 3/29/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        let rootViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        
        return true
    }
}

