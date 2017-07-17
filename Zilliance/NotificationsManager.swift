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


protocol NotificationStore {
    func storeNotification(notification: Notification, completion: ((Notification?, Error?) -> ())?)
    func getNotifications(numberOfDays: Int) -> [Notification]
    func removeNotification(notification: Notification)
}

final class NotificationsManager: NotificationStore {
    
    let localNotifications = LocalNotificationsHelper.shared
    let calendarNotifications = CalendarHelper.shared
    
    var realmDB: Realm!
    
    static let sharedInstance = NotificationsManager()
    
    func storeNotification(notification: Notification, completion: ((Notification?, Error?) -> ())?) {
        
        
        let finalStore: NotificationStore = notification.type == .calendar ? self.calendarNotifications : self.localNotifications
        finalStore.storeNotification(notification: notification) {[unowned self] (notification, error) in
            guard let notification = notification else {
                completion?(nil, error)
                return
            }
            do {

                try self.realmDB.write({
                    self.realmDB.add(notification)
                    
                    completion?(notification, nil)
                })
            }
            catch let error {
                print(error)
                completion?(nil, error)
            }

        }
            
    }
    

    func removeNotification(notification: Notification) {
    
        let internalStore: NotificationStore = notification.type == .calendar ? self.calendarNotifications : self.localNotifications

        internalStore.removeNotification(notification: notification)
        
        do {
            try realmDB.write({
                realmDB.delete(notification)
            })
        }
        catch let error {
            print(error)
        }
        
    }
    
    func purgeNotifications() {
        
        let storedNotifications = realmDB.objects(Notification.self)

        //uncomment to remove all (testing)
//        storedNotifications.forEach {
//            removeNotification(notification: $0)
//        }
        
        //todo: remove notifications
        
        let pendingNotificationIds = getNotifications().flatMap{ $0.notificationId }
        
        let notificationsToDelete = storedNotifications.filter { pendingNotificationIds.contains(($0.notificationId) ?? "") }
        
        do {
            try realmDB.write {
                for notification in notificationsToDelete {
                    realmDB.delete(notification)
                }
            }
        }
        catch let error {
            print(error)
        }
        
    }
    
    func getNotifications(numberOfDays: Int = 7) -> [Notification] {
        
        if let firstNotification = realmDB.objects(Notification.self).first {
            print(firstNotification)
        }
        
        realmDB.refresh()
        
        let storedNotifications = realmDB.objects(Notification.self)
        
        let storedCalendarNotificationsIds = calendarNotifications.getNotifications().flatMap { $0.notificationId }
        
        var notifications: [Notification] = []
        
        for storedNotification in storedNotifications {
            guard let notificationId = storedNotification.notificationId else {
                continue
            }
            
            guard storedNotification.nextNotificationDate() != nil else {
                continue
            }
            
            //it could have been removed from outside the app.
            if (storedNotification.type == .local || storedCalendarNotificationsIds.index(of: notificationId) != nil) {
                notifications.append(storedNotification)
            }
            
        }
        
        return notifications
        
    }
    
    func getLocalNotifications(numberOfDays: Int) -> [Notification]{
        
        let notifications = realmDB.objects(Notification.self).filter("type == \(Notification.NotificationType.local)").filter { (notification) -> Bool in
            return (notification.startDate ?? Date() > Date() || notification.recurrence == .weekly)
        }
        
        return Array(notifications)
    }
    
}

//calendar methods
extension CalendarHelper: NotificationStore {
    
    func removeNotification(notification: Notification) {
        guard let notificationId = notification.notificationId else {
            return assertionFailure()
        }
        
        self.removeEvent(eventId: notificationId)
    }

    func getNotifications(numberOfDays: Int = 7) -> [Notification] {
        
        let group = DispatchGroup()
        var response: [Notification] = []
        
        group.enter()
        getEvents(numberOfDays: numberOfDays) { (notifications, error) in
            
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
    
    func getAllNotifications() -> [Notification] {
                
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
    
    func getNotifications(numberOfDays: Int = 7) -> [Notification] {
        
        return getAllNotifications()
        
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
            DispatchQueue.main.async {
                completion?(notification, nil)
            }
            
        }
        
    }
    
}
