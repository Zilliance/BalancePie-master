//
//  UserActivity.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 04-04-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//


import Foundation
import RealmSwift

@objc enum Feeling: Int32 {
    case great
    case neutral
    case lousy
    case mixed
}

final class UserActivity: Object {
    
    dynamic var activity: Activity!
    dynamic var duration: Int = 0
    let values = List<Value>()
    dynamic var feeling: Feeling = .great
    
    var image: UIImage? {
        guard let iconName = self.activity.iconName else
        {
            return nil
        }

        return UIImage(named: iconName)
    }
}
