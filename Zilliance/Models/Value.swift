//
//  Value.swift
//  RealmStuff
//
//  Created by Philip Dow on 1/29/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import Foundation
import RealmSwift

final class Value: Object {
    dynamic var name = ""
    dynamic var iconName: String?
    
    // https://github.com/realm/realm-cocoa/issues/870#issuecomment-54543539
    // well that's a major bummer
    
    /// Call updateActivityValues after changing the value of selected
    
    dynamic var selected = false
    
    var image: UIImage? {
        if let iconName = self.iconName {
            return UIImage(named: iconName)
        } else {
            return nil
        }
    }
    
    override static func ignoredProperties() -> [String] {
        return []
    }

    
}
