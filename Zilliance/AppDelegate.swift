//
//  AppDelegate.swift
//  Zilliance
//
//  Created by Philip Dow on 3/29/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit
import SideMenuController
import ZillianceShared

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

        NotificationsManager.sharedInstance.realmDB = Database.shared.realm
        Analytics.shared.initialize()
        LocalNotificationsHelper.shared.listenToNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        guard application.applicationState == .active else {
            return
        }
        
        //this will only be exectuted on iOS 9. On iOS 10 we use the UNUserNotificationCenter methods
        let alert = UIAlertController(title: notification.alertTitle, message: notification.alertBody, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }

}

