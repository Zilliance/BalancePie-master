//
//  Activity.swift
//  RealmStuff
//
//  Created by Philip Dow on 1/23/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import Foundation
import RealmSwift

final class Activity: Object {
    enum State: Int {
        case happyValueAligned          = 1
        case happyNotValueAligned       = 2
        case notHappyValueAligned       = 3
        case notHappyNotValueAligned    = 4
        case none                       = 0
    }
    
    dynamic var name = ""
    dynamic var iconName: String?
    dynamic var duration: Minutes = 0
    dynamic var happiness: Percent = 50
    
    /// Call updateActivityValues after changing the value of selected
    
    dynamic var selected = false
    
    /// Realm internal
    
    override static func ignoredProperties() -> [String] {
        return ["state", "isHappy", "isValueAligned", "valuesScore", "happinessScore", "score"]
    }
    
    var image: UIImage? {
        if let iconName = self.iconName {
            return UIImage(named: iconName)
        } else {
            return nil
        }
    }
    
    /// An activity is happy when happines is greater than or equal to 50%
    
    var isHappy: Bool {
        return self.happiness >= 50
    }
    
    
    /// Returns the score for happiness, which is just the value of happiness
    
    var happinessScore: Percent {
        return self.happiness
    }
    
    
    /// Resets an activity, called when removing it from the pie. Call this method
    /// within a realm.write block
    
    func reset() {
        self.duration = 0
        self.happiness = 50
        self.selected = false
    }
    
    
}

extension Activity {
    class func isValueAligned(values: [Percent]) -> Bool {
        return (values.reduce(0, {$0 + $1}) / Float(values.count)) >= 50
    }
}
