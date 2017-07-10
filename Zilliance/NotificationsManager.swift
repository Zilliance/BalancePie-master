//
//  NotificationsManager.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 05-07-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import Foundation
import UserNotifications
import RealmSwift

class Notification: Object{
    
    var notificationId: String?
    
    enum Recurrence {
        case daily
        case weekly
        case none
    }
    
    enum NotificationType {
        case local
        case calendar
    }
    
    var startDate: Date?
    var type: NotificationType = .local
    var recurrence: Recurrence = .none
    
    var title: String = ""
    var body: String = ""
    
}

protocol NotificationStore {
    func storeNotification(notification: Notification, completion: ((Notification?, Error?) -> ())?)
    func getNotifications() -> [Notification]
    func removeNotification(notification: Notification)
}


final class NotificationsStore: NotificationStore {
    
    let localNotifications = LocalNotificationsHelper.shared
    let calendarNotifications = CalendarHelper.shared
    
    var realmDB: Realm!
    
    let sharedInstance = NotificationsStore()

    
    func storeNotification(notification: Notification, completion: ((Notification?, Error?) -> ())?) {
        
        do {
            try realmDB.write({
                realmDB.add(notification, update: true)
            })
        }
        catch let error {
            print(error)
        }
        
        let finalStore: NotificationStore = notification.type == .calendar ? self.calendarNotifications : self.localNotifications
        finalStore.storeNotification(notification: notification, completion: completion)
            
    }
    

    func removeNotification(notification: Notification) {
    
        let finalStore: NotificationStore = notification.type == .calendar ? self.calendarNotifications : self.localNotifications

        finalStore.removeNotification(notification: notification)
        
        do {
            try realmDB.write({
                realmDB.delete(notification)
            })
        }
        catch let error {
            print(error)
        }
        
    }
    
    func getNotifications() -> [Notification] {
        
        let storedNotifications = Array(realmDB.objects(Notification.self))
        
        let storedCalendarNotificationsIds = calendarNotifications.getNotifications().flatMap { $0.notificationId }
        let storedLocalNotificationsIds = localNotifications.getNotifications().flatMap { $0.notificationId }
        
        //filter notifications
        let finalNotifications = storedNotifications.filter {
            guard let notificationId = $0.notificationId else {
                return false
            }
            
            return (storedLocalNotificationsIds.index(of: notificationId) != nil) || (storedCalendarNotificationsIds.index(of: notificationId) != nil)
        }
        
        //todo: order notifications.
        
        return finalNotifications
        
    }
    
}

//calendar methods
extension CalendarHelper: NotificationStore {
    
    //storing the ids internally since the user can edit the calendar from outside the app.
    
    func removeNotification(notification: Notification) {
        guard let notificationId = notification.notificationId else {
            return assertionFailure()
        }
        
        self.removeEvent(eventId: notificationId)
    }

    func getNotifications() -> [Notification] {
        
        let group = DispatchGroup()
        var response: [Notification] = []
        
        group.enter()
        getEvents { (notifications, error) in
            
            if let notifications = notifications {
                response = notifications.map {
                    
                    let notification = Notification()
                    notification.notificationId = $0.eventIdentifier
                    return notification
                    
                }
            }
            else {
                
                print(error ?? "unknown error")
                assertionFailure()
            }
            
            group.leave()
        }
        
        group.wait()
        
        return response
    }

    func storeNotification(notification: Notification, completion: ((Notification?, Error?) -> ())?) {
        guard let startDate = notification.startDate else {
            assertionFailure()
            return
        }
        
        self.addEvent(with: notification.title, notes: notification.body, date: startDate) {(eventId, error) in
            guard let eventId = eventId, error == nil else {
                print(error ?? "unknown error")
                
                completion?(nil, error)
                
                return
            }
            
            notification.notificationId = eventId
            
            completion?(notification, nil)
            
        }
    }

}


extension LocalNotificationsHelper: NotificationStore {
    
    func removeNotification(notification: Notification) {
        guard let notificationId = notification.notificationId else {
            return assertionFailure()
        }
        
        LocalNotificationsHelper.removeNotificationsForIdentifier(identifier: notificationId)
        
    }
    
    func getNotifications() -> [Notification] {
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            
            var notifications: [Notification] = []
            
            center.getPendingNotificationRequests(completionHandler: { (notificationRequest) in
                
                notifications = notificationRequest.map {
                    let notification = Notification()
                    notification.notificationId = $0.identifier
                    return notification
                }
                
                dispatchGroup.leave()
            })
            
            dispatchGroup.wait()
            
            return notifications
            
        } else {
            
            let notifications = UIApplication.shared.scheduledLocalNotifications?.map { (localNotification) -> Notification in
                let notification = Notification()
                notification.notificationId = localNotification.userInfo?["identifier"] as? String
                return notification
                } ?? []
            
            return notifications
            
        }
        
    }
    
    func storeNotification(notification: Notification, completion: ((Notification?, Error?) -> ())?) {
        guard let startDate = notification.startDate else {
            assertionFailure()
            return
        }
        
        let notificationId = UUID().uuidString
        
        LocalNotificationsHelper.scheduleLocalNotification(title: notification.title, body: notification.body, date: startDate, identifier: notificationId) { (error) in
            
            guard error == nil else {
                completion?(nil, error)
                return
            }
            
            notification.notificationId = notificationId
            completion?(notification, nil)
            
        }
        
        
    }
    
}
