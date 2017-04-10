//
//  UserActivity.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 04-04-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//


import Foundation
import RealmSwift

final class UserActivity: Object {
    @objc enum Feeling: Int32 {
        case great
        case neutral
        case lousy
        case mixed
        
        func string() -> String
        {
            switch self {
            case .great:
                return "Great"
            case .neutral:
                return "Neutral"
            case .lousy:
                return "Lousy"
            case .mixed:
                return "Mixed"
            }
        }
    }
    
    dynamic var activity: Activity!
    dynamic var duration: Minutes = 0
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
        case .great:
            return UIColor.red
        case .neutral:
            return UIColor.blue
        case .lousy:
            return UIColor.black
        case .mixed:
            return UIColor.green
        }
    }
    
    var goodValues: Results<Value> {
        return self.values.filter("type == \(ValueType.good.rawValue)")
    }

    var badValues: Results<Value> {
        return self.values.filter("type == \(ValueType.bad.rawValue)")
    }

}
