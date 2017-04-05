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
    dynamic var timeSlept: Int = 0

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
    
}

extension User
{
    
    func saveTimeSlept(hours: Int, minutes: Int)
    {
        try! Database.shared.realm.write {
            self.timeSlept = hours * 60 + minutes
        }
    }
    
    var weeklyHours: Int {
            return (self.timeSlept * 7) / 60
    }

}
