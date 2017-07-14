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


@objc enum dayOfTheWeek: Int32 {
    case sun = 0
    case mon
    case tue
    case wed
    case thu
    case fri
    case sat
    
}

class DayObject: Object{
    dynamic var internalValue: dayOfTheWeek = .sun
    
    var rawValue: Int {
        return Int(internalValue.rawValue)
    }
    
    convenience init(internalValue: dayOfTheWeek) {
        self.init()
        self.internalValue = internalValue
    }
    
}

class Notification: Object{

    
    @objc enum NotificationType: Int32 {
        case local
        case calendar
    }
    
    @objc enum Recurrence: Int32 {
        case daily
        case weekly
        case none
    }
    
    dynamic var notificationId: String?

    override class func primaryKey() -> String? {
        return "notificationId"
    }
    
    dynamic var startDate: Date?
    dynamic var type: NotificationType = .local
    dynamic var recurrence: Recurrence = .none
    
    dynamic var dateAdded = Date()
    
    dynamic var title: String = ""
    dynamic var body: String = ""
    
    let weekDays = List<DayObject>()
    
    //if there's one day for the weekdays selected that is after today, select that one.
    //if not, the first one can be
    
    func getNextWeekDate(fromDate: Date) -> Date? {
        
        guard weekDays.count > 0 else {
            return nil
        }
        
        if (recurrence == .weekly) {
            let fromDateDay = fromDate.weekDay()
            
            //if there's a day after the start day, let's take that day this week.
            for weekDay in weekDays {
                if (fromDateDay < weekDay.rawValue) {
                    return fromDate.nextDateWithWeekDate(weekDay: weekDay.rawValue)
                }
            }
            
            //there should be at least 1 weekday
            guard let firstDay = weekDays.first else {
                assertionFailure()
                return nil
            }
            
            //if can't find a day after today this week let's use the first day for next week
            return fromDate.nextDateWithWeekDate(weekDay: firstDay.rawValue)
            
        }

        return nil
        
    }
    
    func nextNotificationDate(fromDate: Date = Date()) -> Date? {
        
        guard let startDate = startDate else {
            return nil
        }
        
        if (startDate > fromDate) {
            return startDate
        }
        
        guard let nextWeekDate = getNextWeekDate(fromDate: fromDate) else {
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
        
//        try! realmDB.write {
//            realmDB.delete(realmDB.objects(Notification.self))
//        }
        
        let storedNotifications = realmDB.objects(Notification.self)
        
        storedNotifications.forEach {
            removeNotification(notification: $0)
        }
        
        //todo: remove notifications
        
//        let pendingNotificationIds = getNotifications().flatMap{ $0.notificationId }
//        
//        let notificationsToDelete = storedNotifications.filter { pendingNotificationIds.contains(($0.notificationId) ?? "") }
//        
//        do {
//            try realmDB.write {
//                for notification in notificationsToDelete {
//                    realmDB.delete(notification)
//                }
//            }
//        }
//        catch let error {
//            print(error)
//        }
        
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

        //filter not working?
//        //filter notifications
//        let finalNotifications = storedNotifications.filter {
//            guard let notificationId = $0.notificationId else {
//                return false
//            }
//            
//            guard $0.nextNotificationDate != nil else {
//                return false
//            }
//            
//            //it could have been removed from outside the app.
//            return ($0.type == .local || storedCalendarNotificationsIds.index(of: notificationId) != nil)
//        }
        
        
        return notifications
        
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
        
        let numberOfDays = 7
        
        var futureNotifications: [NotificationTableItemViewModel] = []
        
        let endDate = Date().addingTimeInterval(TimeInterval(60 * 60 * 24 * numberOfDays)).endOfDay()
        
        let notifications = getNotifications(numberOfDays: numberOfDays)
        
        notifications.forEach({ (notification) in
            
            guard let notificationId = notification.notificationId else {
                assertionFailure()
                return
            }
            
            var newDate = Date()
            
            while let nextDate = notification.nextNotificationDate(fromDate: newDate), nextDate < endDate {
                
                let newItem = NotificationTableItemViewModel(type: notification.type, recurrence: notification.recurrence, title: notification.title, body: notification.body, nextDate: nextDate, notificationId: notificationId)
                
                futureNotifications.append(newItem)
                
                newDate = nextDate
            }
            
        })
        
        futureNotifications = futureNotifications.sorted { $0.0.nextDate < $0.1.nextDate }
        
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
            DispatchQueue.main.async {
                completion?(notification, nil)
            }
            
        }
        
    }
    
}
