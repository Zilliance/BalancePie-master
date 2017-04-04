//
//  CalendarHelper.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 3/20/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import Foundation
import EventKit

enum CalendarError {
    case notGranted
    case errorSavingEvent
}

class CalendarHelper {
    
    typealias CalendarClosure = (Bool, CalendarError?) -> Void
    
    
    /// adds an event to calendar
    ///
    /// - Parameters:
    ///   - title: the title of the event
    ///   - date: the date of the event
    ///   - calendarClosure: completion closure
    class func addEvent(with title: String, notes: String, date:Date, calendarClosure: @escaping CalendarClosure) {
        
        let store = EKEventStore()
        
        store.requestAccess(to: .event) { (granted, error) in
            guard granted else {
                calendarClosure(false, .notGranted)
                return
            }
            
            let event = EKEvent(eventStore: store)
            event.title = title
            event.startDate = date
            event.notes = notes
            event.endDate = event.startDate.addingTimeInterval(3600) // 1 hour event
            event.calendar = store.defaultCalendarForNewEvents
            do {
                try store.save(event, span: .thisEvent)
                calendarClosure(true, nil)
            } catch {
                calendarClosure(false, .errorSavingEvent)
            }
        }
        
    }
}
