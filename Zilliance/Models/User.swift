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
        return (24 * 7) - self.weeklyHoursTimeSlept
    }
    
    var availableMinutes: Minutes {
        return (24 * 7) * 60 - self.timeSlept * 7
    }

    
}

extension User
{
    
    var availableMinutesForActivities: Minutes {
        return self.availableMinutes - self.timeSlept * 7 - self.currentActivitiesDuration
    }
    
    func saveTimeSlept(hours: Int, minutes: Minutes)
    {
        try! Database.shared.realm.write {
            self.timeSlept = hours * 60 + minutes
        }
    }
    
    func save(userActivity: UserActivity) {
        
        let realm = Database.shared.realm
        
        try! realm?.write {
            
            //if it already contains the activity we need to update it
            if (self.activities.filter("id = '\(userActivity.id)'").count > 0)
            {
                realm?.create(UserActivity.self, value: userActivity, update: true)
            }
            else
            {
                self.activities.append(userActivity)
            }
        }
    }
    
    func remove(userActivity: UserActivity) {
        try! Database.shared.realm.write {
            Database.shared.realm.delete(userActivity)
        }
    }
    
    var weeklyHoursTimeSlept: Int {
            return self.timeSlept * 7 / 60
    }

}
