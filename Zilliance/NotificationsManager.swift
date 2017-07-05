//
//  NotificationsManager.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 05-07-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import Foundation

struct Notification {
    
    var notificationId: String?
    
    enum Recurrence {
        case daily
        case weekly
    }
    
    enum NotificationType {
        case local
        case calendar
    }
    
    var startDate: Date
    var type: NotificationType
    var recurrence: Recurrence?
    
    var title: String
    var body: String
    
}

final class NotificationsStore {
    
    enum Error {
        case calendarNotAvailable
        case unknown
    }
    
    let sharedInstance = NotificationsStore()
    
    func storeNotification(notification: Notification, completion: ((Notification?, Error?) -> ())?) {
        
        switch notification.type {
        case .calendar:
            self.addCalendarNotification(notification: notification, completion: completion)
        case .local:
            self.addLocalNotification(notification: notification, completion: completion)
            
        }
        
    }
    
    func removeNotification(notification: Notification) {
        
        guard let id = notification.notificationId else {
            return assertionFailure()
        }
        
        switch notification.type {
        case .calendar:
            self.removeCalendarNotification(notificationId: id)
        case .local:
            self.removeLocalNotification(notificationId: id)
            
        }
        
    }
    
    func getNotifications() -> [Notification] {
        
        //get local notifications and transform to Notification
        
        
        //get calendar notifications and transform to Notification
        
        
        
        //merge notifications
        
        return []
        
    }
    
}

//calendar methods
extension NotificationsStore {
    
    fileprivate func addCalendarNotification(notification: Notification, completion: ((Notification?, Error?) -> ())?) {
        
        CalendarHelper.addEvent(with: notification.title, notes: notification.body, date: notification.startDate) { (eventId, error) in
            guard let eventId = eventId, error == nil else {
                print(error ?? "unknown error")
                
                let error: NotificationsStore.Error = error == .notGranted ? .calendarNotAvailable : .unknown
                    
                completion?(nil, error)
                
                return
            }
            
            var notification = notification
            notification.notificationId = eventId
            completion?(notification, nil)
            
        }
    
    }

    fileprivate func removeCalendarNotification(notificationId: String) {
        
        CalendarHelper.removeEvent(eventId: notificationId)
        
    }

}


//local notifications
extension NotificationsStore {

    fileprivate func addLocalNotification(notification: Notification, completion: ((Notification, Error) -> ())?) {
        
    }
    
    fileprivate func removeLocalNotification(notificationId: String) {
        
    }
    
}
