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
    
    typealias CalendarClosure = (String?, CalendarError?) -> Void
    
    
    /// adds an event to calendar
    ///
    /// - Parameters:
    ///   - title: the title of the event
    ///   - date: the date of the event
    ///   - calendarClosure: completion closure
    static func addEvent(with title: String, notes: String?, date:Date, calendarClosure: @escaping CalendarClosure) {
        
        let store = EKEventStore()
        
        store.requestAccess(to: .event) { (granted, error) in
            guard granted else {
                DispatchQueue.main.async { calendarClosure(nil, .notGranted) }
                return
            }
            
            let event = EKEvent(eventStore: store)
            event.title = title
            event.startDate = date
            
            if let eventNotes = notes {
                event.notes = eventNotes
            }
            
            event.endDate = event.startDate.addingTimeInterval(3600) // 1 hour event
            event.calendar = store.defaultCalendarForNewEvents
            do {
                try store.save(event, span: .thisEvent)
                DispatchQueue.main.async { calendarClosure(event.eventIdentifier, nil) }
            } catch {
                DispatchQueue.main.async { calendarClosure(nil, .errorSavingEvent) }
            }
        }
        
    }
    
    static func removeEvent(eventId: String) {
        
        let store = EKEventStore()
        
        guard let event = store.event(withIdentifier: eventId) else {
            return assertionFailure()
        }
        
        do {
            
            try store.remove(event, span: .futureEvents)
            
        } catch {
            
            print("error removing an event")
            assertionFailure()
            
        }
        
    }
}
