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
}

class Value: Object {
    dynamic var name = ""
    dynamic var iconName: String?
    dynamic var type: ValueType = .good
    dynamic var isShowingFirst = false
    
    var image: UIImage? {
        if let iconName = self.iconName {
            return UIImage(named: iconName)
        } else {
            return nil
        }
    }
    
    func setShowFirst() {
        try! Database.shared.realm.write {
            self.isShowingFirst = true
        }
    }

    static var goodValues: Array<Value> {
        return Array(Database.shared.realm.objects(Value.self).filter("type == %d", ValueType.good.rawValue))
    }

    static var badValues: Array<Value> {
        return Array(Database.shared.realm.objects(Value.self).filter("type == %d", ValueType.bad.rawValue))
    }
    
    override class func primaryKey() -> String? {
        return "name"
    }
}

extension Value {
    static func ==(lhs: Value, rhs: Value) -> Bool {
        return lhs.name == rhs.name
    }
}
