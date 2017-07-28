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
    
    var realmDB: Realm! {
        didSet {
            let localStoredNotifications = realmDB.objects(Notification.self).filter { (notification) -> Bool in
                return notification.type == .local
            }
            
            var newNotifications: [Notification] = []
            
            let waitingGroup = DispatchGroup()
            
            localStoredNotifications.forEach {
                
                waitingGroup.enter()
                
                let notificationCopy = $0.detached()
                
                localNotifications.scheduleNextMonth(notification: notificationCopy, completion: { (_, _) in
                    waitingGroup.leave()
                })
                
                newNotifications.append(notificationCopy)
            }
            
            waitingGroup.notify(queue: DispatchQueue.main) { 
                do {
                    try self.realmDB.write({
                        self.realmDB.add(newNotifications, update: true)
                    })
                }
                catch let error {
                    print(error)
                }
            }

        }
    }
    
    static let sharedInstance = NotificationsManager()
    
    func storeNotification(notification: Notification, completion: ((Notification?, Error?) -> ())?) {
        
        if let notificationId = notification.notificationId {
            removeNotification(withId: notificationId)
        }
        
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
    
    func removeNotifications(withAssociatedObjectId id: String) {
        
        let notifications = realmDB.objects(Notification.self).filter { $0.associatedObjectId == id }
        
        notifications.forEach { (notification) in
            removeNotification(notification: notification)
        }
        
    }
    
    func removeNotification(withId id: String) {
        if let notification = realmDB.object(ofType: Notification.self, forPrimaryKey: id) {
            removeNotification(notification: notification)
        }
        else {
            print("notification already removed")
//            assertionFailure()
        }
    }
    
    func getNotification(withId id: String) -> Notification? {
        return realmDB.object(ofType: Notification.self, forPrimaryKey: id)
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
        
        self.addEvent(with: notification.body, notes: nil, date: startDate) {(eventId, error) in
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
        
        for scheduledInstance in notification.scheduledInstances {
            
            guard let id = scheduledInstance.id else {
                return assertionFailure()
            }
            
            LocalNotificationsHelper.removeNotificationsForIdentifier(identifier: id)
            
        }
        
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
    
    func scheduleNextMonth(notification: Notification, completion: ((Notification?, Error?) -> ())?) {
        
        guard var startDate = notification.startDate else {
            assertionFailure()
            return
        }
        
        //scheduling a minute in the past since we search for the next date in the repeating series and we have to include the start date.
        startDate = startDate.addingTimeInterval(-60)
        
        let nextMonth = Date().addingTimeInterval(60 * 60 * 24 * 30)
        
        let group = DispatchGroup()
        
        var anError: Error? = nil
                
        let alreadyScheduledDates = Array(notification.scheduledInstances.flatMap {
            Int($0.date?.timeIntervalSince1970 ?? 0)
        })
        
        let calendar = NSCalendar.current
        
        let previousComponents = calendar.dateComponents([.hour, .minute, .second], from: startDate)
        
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.minute = previousComponents.minute
        components.second = previousComponents.second
        components.hour = previousComponents.hour
        
        guard var previousDate = calendar.date(from: components) else {
            return assertionFailure()
        }
        
        while anError == nil, let nextDate = notification.nextNotificationDate(fromDate: previousDate), nextDate < nextMonth, nextDate > previousDate {
            
            defer {
                previousDate = nextDate
            }
            
            guard alreadyScheduledDates.index(of: Int(nextDate.timeIntervalSince1970)) == nil else {
                continue
            }
            
            group.enter()
            
            let newNotificationId = UUID().uuidString
            
            LocalNotificationsHelper.scheduleLocalNotification(title: notification.title, body: notification.body, date: nextDate, identifier: newNotificationId) { (error) in
                
                defer {
                    group.leave()
                }
                
                guard error == nil else {

                    anError = error
                    completion?(nil, error)
                    return
                }
                
                notification.scheduledInstances.append(RecurrentInstance(id: newNotificationId, date: nextDate))
                
            }
            
        }
        
        group.notify(queue: DispatchQueue.main) {
            if (anError == nil) {
                completion?(notification, nil)
            }
            else {
                completion?(nil, anError)
            }
        }
        
    }
    
    func storeNotification(notification: Notification, completion: ((Notification?, Error?) -> ())?) {
        
        notification.notificationId = UUID().uuidString
        
        scheduleNextMonth(notification: notification, completion: completion)
        
    }
    
}
