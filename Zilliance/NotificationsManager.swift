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
    
    enum daysOfTheWeek: Int {
        case sun = 0
        case mon
        case tue
        case wed
        case thu
        case fri
        case sat
    }
    
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
    
    var dateAdded = Date()
    
    var title: String = ""
    var body: String = ""
    
    var weekDays: [daysOfTheWeek]?
    
    //if there's one day for the weekdays selected that is after today, select that one.
    //if not, the first one can be
    
    func getNextWeekDate() -> Date? {
        
        guard let weekDays = weekDays, weekDays.count > 0 else {
            return nil
        }
        
        let now = Date()
        
        for weekDay in weekDays {
            let nextDay = dateAdded.nextDateWithWeekDate(weekDay: weekDay.rawValue)
            if (nextDay > now) {
                return nextDay
            }
        }
        
        if (recurrence == .weekly) {
            let today = now.weekDay()
            
            //if there's a day after today, let's take that day this week.
            for weekDay in weekDays {
                if (today < weekDay.rawValue) {
                    return now.nextDateWithWeekDate(weekDay: weekDay.rawValue)
                }
            }
            
            //there should be at least 1 weekday
            guard let firstDay = weekDays.first else {
                assertionFailure()
                return nil
            }
            
            //if can't find a day after today this week let's use the first day for next week
            return now.nextDateWithWeekDate(weekDay: firstDay.rawValue)
            
        }

        return nil
        
    }
    
    var nextNotificationDate: Date? {
        
        guard let startDate = startDate else {
            return nil
        }
        
        if (startDate > Date()) {
            return startDate
        }
        
        guard let nextWeekDate = getNextWeekDate() else {
            return nil
        }
        
        return nextWeekDate
        
    }
    
}

struct NotificationTableItemViewModel {
    var type: Notification.NotificationType = .local
    var recurrence: Notification.Recurrence = .none
    var title: String = ""
    var body: String = ""
    var nextDate: Date!
    var notificationId: String
}

protocol NotificationStore {
    func storeNotification(notification: Notification, completion: ((Notification?, Error?) -> ())?)
    func getNotifications(numberOfDays: Int) -> [Notification]
    func removeNotification(notification: Notification)
}

protocol NotificationTableViewModel {
    
    func getNextNotifications() -> [NotificationTableItemViewModel]

}

final class NotificationsManager: NotificationStore {
    
    let localNotifications = LocalNotificationsHelper.shared
    let calendarNotifications = CalendarHelper.shared
    
    var realmDB: Realm!
    
    let sharedInstance = NotificationsManager()
    
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
    
    func purgeNotifications() {
        let storedNotifications = realmDB.objects(Notification.self)
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
        
        let storedNotifications = Array(realmDB.objects(Notification.self))
        
        let storedCalendarNotificationsIds = calendarNotifications.getNotifications().flatMap { $0.notificationId }
        
        //filter notifications
        let finalNotifications = storedNotifications.filter {
            guard let notificationId = $0.notificationId else {
                return false
            }
            
            guard $0.nextNotificationDate != nil else {
                return false
            }
            
            //it could have been removed from outside the app.
            return ($0.type == .local || storedCalendarNotificationsIds.index(of: notificationId) != nil)
        }
        
        //todo: order notifications.
        
        return finalNotifications
        
    }
    
    func getLocalNotifications(numberOfDays: Int) -> [Notification]{
        
        let notifications = realmDB.objects(Notification.self).filter("type == \(Notification.NotificationType.local)").filter { (notification) -> Bool in
            return (notification.startDate ?? Date() > Date() || notification.recurrence == .weekly)
        }
        
        return Array(notifications)
    }
    
}

extension NotificationsManager: NotificationTableViewModel {
    
    func getNextNotifications() -> [NotificationTableItemViewModel] {
        
        let futureNotifications: [NotificationTableItemViewModel] = getNotifications(numberOfDays: 7).flatMap {
            
            guard let nextDate = $0.nextNotificationDate, let notificationId = $0.notificationId else {
                return nil
            }
            
            return NotificationTableItemViewModel(type: $0.type, recurrence: $0.recurrence, title: $0.title, body: $0.body, nextDate: nextDate, notificationId: notificationId)
            
        }.sorted { $0.0.nextDate < $0.1.nextDate }
        
        return futureNotifications
        
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
            completion?(notification, nil)
            
        }
        
        
    }
    
}
