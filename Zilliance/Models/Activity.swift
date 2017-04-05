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
    
    dynamic var name = ""
    dynamic var iconName: String?
    
    /// Call updateActivityValues after changing the value of selected
    
    var image: UIImage? {
        if let iconName = self.iconName {
            return UIImage(named: iconName)
        } else {
            return nil
        }
    }
    
}
