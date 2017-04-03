//
//  LocalNotificationsUtils.swift
//  Balance Pie
//
//  Created by mac on 21-03-17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

final class LocalNotificationsHelper
{
    static let notificationCategory = "reminderNotification"
    
    static let shared = LocalNotificationsHelper()
    
    fileprivate var waitingAuthorizationCompletion: ((Bool) -> ())?
    
    private func ownAuthorization(vc: UIViewController, completion: @escaping (Bool) -> ())
    {
        
        let alert = UIAlertController(title: "Allow Notifications", message: "Balance Pie would like to send you a notification reminder", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
            completion(false)
        }))
        
        alert.addAction(UIAlertAction(title: "Allow", style: .default, handler: { (_) in
            completion(true)
        }))
        vc.present(alert, animated: true, completion: nil)
        
    }
    
    func requestAuthorization(inViewController viewController: UIViewController, completion: @escaping (Bool) -> ())
    {
        
        let ownAuthorization:() -> () =
        {
            self.ownAuthorization(vc: viewController, completion: { (authorized) in
                if (authorized)
                {
                    self.requestOSAuthorization(completion: completion)
                }
            })
        }
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            
            center.getNotificationSettings(completionHandler: {(settings) in
                
                DispatchQueue.main.async {
                    if (settings.authorizationStatus == .authorized)
                    {
                        completion(true)
                    }
                    else
                    {
                        if (settings.authorizationStatus == .notDetermined)
                        {
                            ownAuthorization()
                        }
                        else
                        {
                            completion(false)
                        }
                    }
                    
                }


            })
            
        } else {
            
            
            if let types = UIApplication.shared.currentUserNotificationSettings?.types, types.contains([.alert, .sound])
            {
                completion(true)
                return
            }
            else
            {
                ownAuthorization()
            }

            
        }
    }
    
    private func requestOSAuthorization(completion: ((Bool) -> ())?)
    {
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                
                completion?(granted)
                
            }
        } else {
            
            waitingAuthorizationCompletion = completion
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .sound], categories: nil))
            
        }
        
    }
    
    func authorizationReceived(authorized: Bool)
    {
        waitingAuthorizationCompletion?(authorized)
    }
    
    static func scheduleLocalNotification(title: String, body: String, date: Date)
    {
        if #available(iOS 10.0, *) {
            
            let center = UNUserNotificationCenter.current()
            
            center.removeAllPendingNotificationRequests()
            
            let content = UNMutableNotificationContent()
            content.categoryIdentifier = notificationCategory
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default()
            
            let dateComponents = Calendar.current.dateComponents([.day, .hour, .minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: "reminder", content: content, trigger: trigger)
            
            // Schedule the notification.
            center.add(request) { (error) in
            }
            
        } else {
            guard let settings = UIApplication.shared.currentUserNotificationSettings, settings.types != .none else {
                return
            }
            
            UIApplication.shared.cancelAllLocalNotifications()
            let notification = UILocalNotification()
            notification.fireDate = date
            notification.alertTitle = title
            notification.alertBody = body
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notification)
            
        }
    }

    static func getPreviousNotificationInformation() -> (String, String, Date)?
    {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            
            let dispatchGroup = DispatchGroup()
            var previousRequest:UNNotificationRequest?
            
            dispatchGroup.enter()
            
            center.getPendingNotificationRequests(completionHandler: { (notificationRequest) in
                
                previousRequest = notificationRequest.first
                dispatchGroup.leave()
            })
            
            dispatchGroup.wait()
            
            if let previousRequest = previousRequest, let trigger = previousRequest.trigger as? UNCalendarNotificationTrigger, let date = trigger.nextTriggerDate()
            {
                return (previousRequest.content.title, previousRequest.content.body, date)
            }
            
            
        } else {
            
            if let notification = UIApplication.shared.scheduledLocalNotifications?.first, let date = notification.fireDate, let title = notification.alertTitle, let body = notification.alertBody
            {
                return (title, body, date)
            }
            
        }
        
        return nil
    }

    
}

