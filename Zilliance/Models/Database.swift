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
    
    private(set) var user: User!
    
    init() {
        do {
            
            // Inside your application(application:didFinishLaunchingWithOptions:)
            
            let config = Realm.Configuration(
                schemaVersion: 3,
                
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
            
            if let user = self.realm.objects(User.self).first
            {
                self.user = user
            }
            else
            {
                //first time launch, let's prepare the DB
                self.bootstrap()
            }
            
            
        } catch {
            print("realm initialization failed, aborting")
        }
    }
    
    func allActivities() -> Results<Activity>
    {
        return self.realm.objects(Activity.self)
    }
    
    func allValues() -> Results<Value>
    {
        return self.realm.objects(Value.self)
    }

    // MARK: - Convenience queries

    
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
        
        self.user = user
    }
    
    private func bootstrapActivities() {
        guard self.realm.objects(Activity.self).count == 0 else {
            return
        }
        
        self.defaultActivityData.forEach { (dict) in
            let activity = Activity()
            
            activity.name = dict["name"]!
            activity.iconName = dict["iconName"]
            
            addActivity(activity: activity)
        }
    }
    
    fileprivate func addActivity(activity: Activity)
    {
        try! self.realm.write {
            self.realm.add(activity)
        }
    }
    
    private var defaultValuesData: [[String: Any]] {
        return [
            ["name": "Achievement", "type": ValueType.good],
            ["name": "Adventure, meaning", "type": ValueType.good],
            ["name": "Authenticity, ability to make a difference", "type": ValueType.good],
            ["name": "Belonging, giving back", "type": ValueType.good],
            ["name": "Benevolence, learning, growth", "type": ValueType.good],
            ["name": "Bravery", "type": ValueType.good],
            ["name": "Challenge", "type": ValueType.good],
            ["name": "Community", "type": ValueType.good],
            ["name": "Connection", "type": ValueType.good],
            ["name": "Contribution, diversity", "type": ValueType.good],
            ["name": "Creativity, friendship", "type": ValueType.good],
            ["name": "Ethics", "type": ValueType.good],
            ["name": "Faith", "type": ValueType.good],
            ["name": "Fame", "type": ValueType.good],
            ["name": "Family time", "type": ValueType.good],
            ["name": "Freddom", "type": ValueType.good],
            ["name": "Friendship", "type": ValueType.good],
            ["name": "Fun", "type": ValueType.good],
            ["name": "Giving back", "type": ValueType.good],
            ["name": "Growth", "type": ValueType.good],
            ["name": "Happiness", "type": ValueType.good],
            ["name": "Harmony", "type": ValueType.good],
            ["name": "Healthiness", "type": ValueType.good],
            ["name": "Honesty", "type": ValueType.good],
            ["name": "Impact", "type": ValueType.good],
            ["name": "Independence", "type": ValueType.good],
            ["name": "Influence", "type": ValueType.good],
            ["name": "Intimacy", "type": ValueType.good],
            ["name": "Joy", "type": ValueType.good],
            ["name": "Laughter", "type": ValueType.good],
            ["name": "Leadership", "type": ValueType.good],
            ["name": "Learning", "type": ValueType.good],
            ["name": "Lesiure", "type": ValueType.good],
            ["name": "Love", "type": ValueType.good],
            ["name": "Mastery", "type": ValueType.good],
            ["name": "Meaning", "type": ValueType.good],
            ["name": "Money", "type": ValueType.good],
            ["name": "Nurturance", "type": ValueType.good],
            ["name": "Optimism", "type": ValueType.good],
            ["name": "Passion", "type": ValueType.good],
            ["name": "Personal development", "type": ValueType.good],
            ["name": "Power", "type": ValueType.good],
            ["name": "Privacy", "type": ValueType.good],
            ["name": "Respect", "type": ValueType.good],
            ["name": "Romance", "type": ValueType.good],
            ["name": "Security", "type": ValueType.good],
            ["name": "Self-care", "type": ValueType.good],
            ["name": "Self-expression", "type": ValueType.good],
            ["name": "Simplicity", "type": ValueType.good],
            ["name": "Spirituality", "type": ValueType.good],
            ["name": "Spontaneity", "type": ValueType.good],
            ["name": "Stability", "type": ValueType.good],
            ["name": "Variety", "type": ValueType.good],
            ["name": "Wisdom", "type": ValueType.good],
            ["name": "Teamwork", "type": ValueType.good],
            ["name": "Arrogance", "type": ValueType.bad],
            ["name": "Boredom", "type": ValueType.bad],
            ["name": "Combativeness", "type": ValueType.bad],
            ["name": "Complexity", "type": ValueType.bad],
            ["name": "Dishonesty", "type": ValueType.bad],
            ["name": "Dullness", "type": ValueType.bad],
            ["name": "Fear", "type": ValueType.bad],
            ["name": "Feelings of inadequacy", "type": ValueType.bad],
            ["name": "Formality", "type": ValueType.bad],
            ["name": "Fraudulence", "type": ValueType.bad],
            ["name": "Harmfulness", "type": ValueType.bad],
            ["name": "Helplessness", "type": ValueType.bad],
            ["name": "Ignorance", "type": ValueType.bad],
            ["name": "Meaninglessness", "type": ValueType.bad],
            ["name": "Monotony", "type": ValueType.bad],
            ["name": "Pain", "type": ValueType.bad],
            ["name": "Pessimism", "type": ValueType.bad],
            ["name": "Restraints", "type": ValueType.bad],
            ["name": "Sadness", "type": ValueType.bad],
            ["name": "Seriousness", "type": ValueType.bad],
            ["name": "Servitude", "type": ValueType.bad],
            ["name": "Solitude", "type": ValueType.bad],
            ["name": "Stagnation", "type": ValueType.bad],
            ["name": "Submissiveness", "type": ValueType.bad],
            ["name": "Time commitment", "type": ValueType.bad],
        ]
    }
    
    private func bootstrapValues() {
        guard self.realm.objects(Value.self).count == 0 else {
            return
        }
        
        self.defaultValuesData.forEach { (dict) in
            let value = Value()
            
            value.name = dict["name"] as! String
            value.type = dict["type"] as! ValueType
            
            try! self.realm.write {
                self.realm.add(value)
            }
        }
    }
    
}
