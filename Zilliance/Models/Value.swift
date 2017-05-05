//
//  Value.swift
//  RealmStuff
//
//  Created by Philip Dow on 1/29/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import Foundation
import RealmSwift

@objc enum ValueType: Int32 {
    case good
    case bad
    case neutral
}

@objc enum OrderPriority: Int32 {
    case highest = 0
    case high
    case normal
}

class Value: Object {
    
    dynamic var name = ""
    dynamic var iconName: String?
    dynamic var type: ValueType = .good
    dynamic var order: OrderPriority = .normal
    
    var image: UIImage? {
        if let iconName = self.iconName {
            return UIImage(named: iconName)
        } else {
            return nil
        }
    }
    
    func setOrderPriority(priority: OrderPriority) {
        try! Database.shared.realm.write {
            self.order = priority
        }
    }

    static var goodValues: Array<Value> {
        return Array(Database.shared.realm.objects(Value.self).filter("type == %d", ValueType.good.rawValue))
    }

    static var badValues: Array<Value> {
        return Array(Database.shared.realm.objects(Value.self).filter("type == %d", ValueType.bad.rawValue))
    }
    
    static var neutralValues: Array<Value> {
        return Array(Database.shared.realm.objects(Value.self).filter("type == %d", ValueType.neutral.rawValue))
    }
}

extension Value {
    static func ==(lhs: Value, rhs: Value) -> Bool {
        return lhs.name == rhs.name
    }
}
