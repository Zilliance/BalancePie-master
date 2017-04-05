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
    
    var image: UIImage? {
        if let iconName = self.iconName {
            return UIImage(named: iconName)
        } else {
            return nil
        }
    }

    
}
