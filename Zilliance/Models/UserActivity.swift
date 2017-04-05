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
    
    var color: UIColor {
        switch(feeling){
        case .neutral:
            return UIColor.blue
        case .lousy:
            return UIColor.black
        case .mixed:
            return UIColor.green
            
        default:
            return UIColor.red
        }
    }
    
    var goodValues: List<Value> {
        return self.values.filter("type == \(ValueType.good.rawValue)")
    }

    var badValues: List<Value> {
        return self.values.filter("type == \(ValueType.bad.rawValue)")
    }

}
