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
    dynamic var order: OrderPriority = .normal
    
    func setOrderPriority(priority: OrderPriority) {
        try! Database.shared.realm.write {
            self.order = priority
        }
    }

}
