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
                schemaVersion: 4,
                
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
    
    var allActivities: Results<Activity> {
        let sortProperties = [SortDescriptor(keyPath: "order", ascending: true), SortDescriptor(keyPath: "name", ascending: true)]
        
        return self.realm.objects(Activity.self).sorted(by: sortProperties)
    }
    
    var allValues: Results<Value> {
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
            ["name": "Achievement", "type": ValueType.great],
            ["name": "Adventure", "type": ValueType.great],
            ["name": "Authenticity", "type": ValueType.great],
            ["name": "Belonging", "type": ValueType.great],
            ["name": "Benevolence", "type": ValueType.great],
            ["name": "Bravery", "type": ValueType.great],
            ["name": "Challenge", "type": ValueType.great],
            ["name": "Community", "type": ValueType.great],
            ["name": "Connection", "type": ValueType.great],
            ["name": "Contribution", "type": ValueType.great],
            ["name": "Creativity", "type": ValueType.great],
            ["name": "Ethics", "type": ValueType.great],
            ["name": "Faith", "type": ValueType.great],
            ["name": "Fame", "type": ValueType.great],
            ["name": "Family time", "type": ValueType.great],
            ["name": "Freedom", "type": ValueType.great],
            ["name": "Friendship", "type": ValueType.great],
            ["name": "Fun", "type": ValueType.great],
            ["name": "Giving back", "type": ValueType.great],
            ["name": "Growth", "type": ValueType.great],
            ["name": "Happiness", "type": ValueType.great],
            ["name": "Harmony", "type": ValueType.great],
            ["name": "Healthiness", "type": ValueType.great],
            ["name": "Honesty", "type": ValueType.great],
            ["name": "Impact", "type": ValueType.great],
            ["name": "Independence", "type": ValueType.great],
            ["name": "Influence", "type": ValueType.great],
            ["name": "Intimacy", "type": ValueType.great],
            ["name": "Joy", "type": ValueType.great],
            ["name": "Laughter", "type": ValueType.great],
            ["name": "Leadership", "type": ValueType.great],
            ["name": "Learning", "type": ValueType.great],
            ["name": "Leisure", "type": ValueType.great],
            ["name": "Love", "type": ValueType.great],
            ["name": "Mastery", "type": ValueType.great],
            ["name": "Meaning", "type": ValueType.great],
            ["name": "Money", "type": ValueType.great],
            ["name": "Nurturance", "type": ValueType.great],
            ["name": "Optimism", "type": ValueType.great],
            ["name": "Passion", "type": ValueType.great],
            ["name": "Personal development", "type": ValueType.great],
            ["name": "Power", "type": ValueType.great],
            ["name": "Privacy", "type": ValueType.great],
            ["name": "Respect", "type": ValueType.great],
            ["name": "Romance", "type": ValueType.great],
            ["name": "Security", "type": ValueType.great],
            ["name": "Self-care", "type": ValueType.great],
            ["name": "Self-expression", "type": ValueType.great],
            ["name": "Simplicity", "type": ValueType.great],
            ["name": "Spirituality", "type": ValueType.great],
            ["name": "Spontaneity", "type": ValueType.great],
            ["name": "Stability", "type": ValueType.great],
            ["name": "Variety", "type": ValueType.great],
            ["name": "Wisdom", "type": ValueType.great],
            ["name": "Teamwork", "type": ValueType.great],
            
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
            
            ["name": "Achievement", "type": ValueType.good],
            ["name": "Adventure", "type": ValueType.good],
            ["name": "Authenticity", "type": ValueType.good],
            ["name": "Belonging", "type": ValueType.good],
            ["name": "Boredom", "type": ValueType.good],
            ["name": "Camaraderie", "type": ValueType.good],
            ["name": "Challenge", "type": ValueType.good],
            ["name": "Community", "type": ValueType.good],
            ["name": "Complexity", "type": ValueType.good],
            ["name": "Connection", "type": ValueType.good],
            ["name": "Constraints", "type": ValueType.good],
            ["name": "Creativity", "type": ValueType.good],
            ["name": "Family time", "type": ValueType.good],
            ["name": "Feelings of inadequacy", "type": ValueType.good],
            ["name": "Formality", "type": ValueType.good],
            ["name": "Freedom", "type": ValueType.good],
            ["name": "Friendship", "type": ValueType.good],
            ["name": "Fun", "type": ValueType.good],
            ["name": "Giving back", "type": ValueType.good],
            ["name": "Happiness", "type": ValueType.good],
            ["name": "Harmony", "type": ValueType.good],
            ["name": "Healthiness", "type": ValueType.good],
            ["name": "Honesty", "type": ValueType.good],
            ["name": "Impact", "type": ValueType.good],
            ["name": "Independence", "type": ValueType.good],
            ["name": "Integrity", "type": ValueType.good],
            ["name": "Intimacy", "type": ValueType.good],
            ["name": "Joy", "type": ValueType.good],
            ["name": "Lack of compensation", "type": ValueType.good],
            ["name": "Laughter", "type": ValueType.good],
            ["name": "Leadership", "type": ValueType.good],
            ["name": "Leisure", "type": ValueType.good],
            ["name": "Loneliness", "type": ValueType.good],
            ["name": "Love", "type": ValueType.good],
            ["name": "Meekness", "type": ValueType.good],
            ["name": "Monotony", "type": ValueType.good],
            ["name": "Nurturance", "type": ValueType.good],
            ["name": "Optimism", "type": ValueType.good],
            ["name": "Pain", "type": ValueType.good],
            ["name": "Passion", "type": ValueType.good],
            ["name": "Personal development", "type": ValueType.good],
            ["name": "Power", "type": ValueType.good],
            ["name": "Purpose", "type": ValueType.good],
            ["name": "Respect", "type": ValueType.good],
            ["name": "Restraints", "type": ValueType.good],
            ["name": "Romance", "type": ValueType.good],
            ["name": "Self-care", "type": ValueType.good],
            ["name": "Seriousness", "type": ValueType.good],
            ["name": "Simplicity", "type": ValueType.good],
            ["name": "Solitude", "type": ValueType.good],
            ["name": "Spontaneity", "type": ValueType.good],
            ["name": "Stability", "type": ValueType.good],
            ["name": "Stagnation", "type": ValueType.good],
            ["name": "Teamwork", "type": ValueType.good],
            ["name": "Time commitment", "type": ValueType.good],
            ["name": "Variety", "type": ValueType.good],
            ["name": "Wealth", "type": ValueType.good],
            ["name": "Wisdom", "type": ValueType.good],
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
