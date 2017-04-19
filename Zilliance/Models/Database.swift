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
            ["name": "Passion", "type": Value.goodValues],
            ["name": "Purpose, meaning", "type": Value.goodValues],
            ["name": "Imact, ability to make a difference", "type": Value.goodValues],
            ["name": "Contribution, giving back", "type": Value.goodValues],
            ["name": "Personal development, learning, growth", "type": Value.goodValues],
            ["name": "Leisure", "type": Value.goodValues],
            ["name": "Freedom", "type": Value.goodValues],
            ["name": "Spontaneity", "type": Value.goodValues],
            ["name": "Laughter", "type": Value.goodValues],
            ["name": "Variety, diversity", "type": Value.goodValues],
            ["name": "Camaraderie, friendship", "type": Value.goodValues],
            ["name": "Teamwork", "type": Value.goodValues],
            ["name": "Family time", "type": Value.goodValues],
            ["name": "Adventure", "type": Value.goodValues],
            ["name": "Self-care", "type": Value.goodValues],
            ["name": "Healthiness", "type": Value.goodValues],
            ["name": "Love, connection, belonging", "type": Value.goodValues],
            ["name": "Romance", "type": Value.goodValues],
            ["name": "Intimacy", "type": Value.goodValues],
            ["name": "Joy, happiness", "type": Value.goodValues],
            ["name": "Authenticity", "type": Value.goodValues],
            ["name": "Honesty", "type": Value.goodValues],
            ["name": "Challenge", "type": Value.goodValues],
            ["name": "Integrity, ethics", "type": Value.goodValues],
            ["name": "Creativity, self-expression", "type": Value.goodValues],
            ["name": "Fun, pleasure", "type": Value.goodValues],
            ["name": "Wealth, money", "type": Value.goodValues],
            ["name": "Achievement, mastery", "type": Value.goodValues],
            ["name": "Wisdom", "type": Value.goodValues],
            ["name": "Fame, recognition, popularity", "type": Value.goodValues],
            ["name": "Respect", "type": Value.goodValues],
            ["name": "Power, influence", "type": Value.goodValues],
            ["name": "Stability, security", "type": Value.goodValues],
            ["name": "Independece", "type": Value.goodValues],
            ["name": "Spirituality, faith", "type": Value.goodValues],
            ["name": "Community", "type": Value.goodValues],
            ["name": "Nurturance", "type": Value.goodValues],
            ["name": "Solitude", "type": Value.goodValues],
            ["name": "Privacy", "type": Value.goodValues],
            ["name": "Leadership", "type": Value.goodValues],
            ["name": "Courage, bravery", "type": Value.goodValues],
            ["name": "Simplicity", "type": Value.goodValues],
            ["name": "Harmony", "type": Value.goodValues],
            ["name": "Optimism / Benevolence", "type": Value.goodValues],
            ["name": "Dullness", "type": Value.badValues],
            ["name": "Meaninglessness", "type": Value.badValues],
            ["name": "Submissiveness", "type": Value.badValues],
            ["name": "Stagnation", "type": Value.badValues],
            ["name": "Restraints", "type": Value.badValues],
            ["name": "Servitude", "type": Value.badValues],
            ["name": "Boredom", "type": Value.badValues],
            ["name": "Seriousness", "type": Value.badValues],
            ["name": "Monotony", "type": Value.badValues],
            ["name": "Formality", "type": Value.badValues],
            ["name": "Combativeness", "type": Value.badValues],
            ["name": "Solitude", "type": Value.badValues],
            ["name": "Feelings of inadequacy", "type": Value.badValues],
            ["name": "Harmfulness", "type": Value.badValues],
            ["name": "Pain", "type": Value.badValues],
            ["name": "Loneliness", "type": Value.badValues],
            ["name": "Sadness", "type": Value.badValues],
            ["name": "Time commitement", "type": Value.badValues],
            ["name": "Fraudulence", "type": Value.badValues],
            ["name": "Dishonesty", "type": Value.badValues],
            ["name": "Simplicity", "type": Value.badValues],
            ["name": "Arrogance", "type": Value.badValues],
            ["name": "Ignorance", "type": Value.badValues],
            ["name": "Irreverence", "type": Value.badValues],
            ["name": "Meekness", "type": Value.badValues],
            ["name": "Instability", "type": Value.badValues],
            ["name": "Blasphemy", "type": Value.badValues],
            ["name": "Helplessness", "type": Value.badValues],
            ["name": "Complexity", "type": Value.badValues],
            ["name": "Fear", "type": Value.badValues],
            ["name": "Pessimism", "type": Value.badValues],
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
