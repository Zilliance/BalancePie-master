//
//  User.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 1/9/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import Foundation
import RealmSwift

final class User: Object {
    
    dynamic var isIntroStarted: Bool = false
    dynamic var isIntroFinished: Bool = false

    //daily minutes spent sleeping:
    dynamic var timeSlept: Minutes = 0

    func startIntro() {
        try! Database.shared.realm.write {
            self.isIntroStarted = true
        }
    }
    
    func finishIntro() {
        try! Database.shared.realm.write {
            self.isIntroStarted = true
            self.isIntroFinished = true
        }
    }
    
    func isOnboarding() -> Bool {
        return self.isIntroStarted && !self.isIntroFinished
    }
    
    let activities = List<UserActivity>()
    
    var currentActivitiesDuration: Minutes {
        return self.activities.reduce(0, {$0 + $1.duration})
    }
    
    var availableHours: Int {
        return (24 * 7) - (self.timeSlept / 60) * 7
    }
    
    var availableMinutes: Int {
        return (24 * 7) * 60 - self.timeSlept * 7
    }

    
}

extension User
{
    
    func saveTimeSlept(hours: Int, minutes: Minutes)
    {
        try! Database.shared.realm.write {
            self.timeSlept = hours * 60 + minutes
        }
    }
    
    var weeklyHours: Int {
            return (self.timeSlept * 7) / 60
    }

}
