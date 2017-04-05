//
//  Database.swift
//  RealmStuff
//
//  Created by Philip Dow on 1/29/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import Foundation
import RealmSwift

// Shared Types

typealias Minutes = Int
typealias Percent = Float

// Database

class Database {
    static let shared = Database()
    
    /// You may access the realm object directly to query for objects or use the
    /// convenience methods provided below
    
    private(set) var realm: Realm!
    
    /// You must initialize the database before using it
    
    func initialize() -> Bool {
        do {
            
            // Inside your application(application:didFinishLaunchingWithOptions:)
            
            let config = Realm.Configuration(
                schemaVersion: 1,

                migrationBlock: { migration, oldSchemaVersion in
                    if (oldSchemaVersion < 1) {
                        // Nothing to do!
                        // Realm will automatically detect new properties and removed properties
                        // And will update the schema on disk automatically
                    }
            })
            
            // Tell Realm to use this new configuration object for the default Realm
            Realm.Configuration.defaultConfiguration = config
            
            // Now that we've told Realm how to handle the schema change, opening the file
            // will automatically perform the migration
            
            self.realm = try Realm()
            return true
        } catch {
            print("realm initialization failed, aborting")
            return false
        }
    }
    
    // MARK: - Convenience queries
    
    /// Return User
    var user: User {
        return self.realm.objects(User.self).first!
    }
    
    /// Returns all activities
    
    var activities: Results<Activity> {
        return self.realm.objects(Activity.self)
    }
    
    /// Returns all values
    
    var values: Results<Value> {
        return self.realm.objects(Value.self)
    }
    
    /// Returns currently selected activities
    
    var selectedActivities: Results<Activity> {
        return self.realm.objects(Activity.self).filter("selected == true")
    }
    
    /// Returns currently selected values
    
    var selectedValues: Results<Value> {
        return self.realm.objects(Value.self).filter("selected == true")
    }
    
    /// Returns the total number of minutes for selected Activities, use to calculate pie percentages
    
    var durationOfSelectedActivities: Int {
        return self.selectedActivities.sum(ofProperty: "duration")
    }
    
    
    /// Total number of available hours = hours in week - hours user sleeps
    
    var availableHours: Int {
        return (24 * 7) - (self.user.timeSlept / 60) * 7
    }
    
    /// Total number of active hours
    
//    var activeHours: Int {
//        return self.selectedActivities.map{$0.duration}.reduce(0,{$0+$1}) / 60
//    }
    
    // MARK: - Bootstrap
    
    /// Bootstrap the database to establish default model objects immediately after initialization
    /// The database will not be bootstrapped more than once
    
    func bootstrap() {
        self.bootstrapUser()
        self.bootstrapActivities()
        self.bootstrapValues()
    }
    
    private var defaultActivityData: [[String: String]] {
        return [
            ["name": "Family Time", "iconName": "familyTime"],
            ["name": "Kid's Activities", "iconName": "kids"],
            ["name": "Work", "iconName": "work"],
            ["name": "Driving", "iconName": "driving"],
            ["name": "Treatment", "iconName": "treatment"],
            ["name": "Chores", "iconName": "chores"],
            ["name": "Leisure Time", "iconName": "leisureTime"],
            ["name": "Exercise", "iconName": "exercise"],
            ["name": "Television", "iconName": "tv"],
            ["name": "Romance", "iconName": "romance"],
            ["name": "Reading", "iconName": "reading"],
            ["name": "Spiritual Practice", "iconName": "spiritualPractice"],
            ["name": "Social Networking", "iconName": "socialNetworking"],
            ["name": "Time with Friends",  "iconName": "timeWithFriends"],
            ["name": "Personal Phone Time",  "iconName": "talkingOnPhone"],
            ["name": "Quiet Time", "iconName": "quietTime"],
            ["name": "Hobbies",  "iconName": "hobbies"],
            ["name": "Volunteering",  "iconName": "volunterring"]
        ]
    }
    
    private func bootstrapUser() {
        guard self.realm.objects(User.self).count == 0 else {
            return
    }
        
        let user = User()
        user.isIntroStarted = false
        user.isIntroFinished = false
        try! self.realm.write {
            self.realm.add(user)
        }
    }
    
    private func bootstrapActivities() {
        guard self.realm.objects(Activity.self).count == 0 else {
            return
        }
        
        self.defaultActivityData.forEach { (dict) in
            let activity = Activity()
            
            activity.name = dict["name"]!
            activity.iconName = dict["iconName"]
            
            try! self.realm.write {
                self.realm.add(activity)
            }
        }
    }
    
    private var defaultValuesData: [[String: String]] {
        return [
            ["name": "Passion"],
            ["name": "Purpose"],
            ["name": "Service"],
            ["name": "Personal Growth"],
            ["name": "Freedom"],
            ["name": "Adventure"],
            ["name": "Healthy Lifestyle"],
            ["name": "Love"],
            ["name": "Intimacy"],
            ["name": "Joy"],
            ["name": "Authenticity"],
            ["name": "Integrity"],
            ["name": "Creativity"],
            ["name": "Fun"],
            ["name": "Wealth"],
            ["name": "Achievement"],
            ["name": "Recognition"],
            ["name": "Power"],
            ["name": "Stability"],
            ["name": "Spiritualiry"],
            ["name": "Wisdom"],
            ["name": "Impact"],
        ]
    }
    
    private func bootstrapValues() {
        guard self.realm.objects(Value.self).count == 0 else {
            return
        }
        
        self.defaultValuesData.forEach { (dict) in
            let value = Value()
            
            value.name = dict["name"]!
            value.iconName = dict["iconName"]
            
            try! self.realm.write {
                self.realm.add(value)
            }
        }
    }
}
