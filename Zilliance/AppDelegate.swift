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
        
        self.userActivitiesTestData()
        
        let rootViewController = UIStoryboard(name: "Pie", bundle: nil).instantiateInitialViewController()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        
        return true
    }

    //MARK : - Test data remove later
    
    private func userActivitiesTestData() {
        
        let activity1 = Activity()
        activity1.name = "Test"
        
        let userActivity = UserActivity()
        userActivity.activity = activity1
        userActivity.duration = 300
        userActivity.feeling = .mixed
        Database.shared.user.save(userActivity: userActivity)
        
        let activity2 = Activity()
        activity2.name = "Test2"
        
        let userActivity1 = UserActivity()
        userActivity1.activity = activity2
        userActivity1.duration = 800
        userActivity1.feeling = .great
        Database.shared.user.save(userActivity: userActivity1)
        
        
    }
}

