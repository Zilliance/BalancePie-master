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
    case none
    case great
    case neutral
    case lousy
    case mixed
    
    func string() -> String
    {
        switch self {
        case .none:
            return ""
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
    
    static let allFeelings: [Feeling] = {
        return [Feeling.great, Feeling.neutral, Feeling.lousy, Feeling.mixed]
    }()
}

final class UserActivity: Object {
    
    dynamic var activity: Activity!
    dynamic var duration: Minutes = 0
    var values = List<Value>()
    dynamic var feeling: Feeling = .none
    dynamic var id: String = UUID().uuidString
    
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
        case .none:
            return UIColor.white
        }
        
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    var goodValues: Array<Value> {
        return self.values.filter{$0.type == .good}
    }

    var badValues: Array<Value> {
        return self.values.filter{$0.type == .bad}
    }
    
    func removeBadValues()
    {
        self.badValues.forEach{
            if let index = self.values.index(of: $0)
            {
                self.values.remove(objectAtIndex: index)
            }
        }
    }
    
    func removeGoodValues()
    {
        self.goodValues.forEach{
            if let index = self.values.index(of: $0)
            {
                self.values.remove(objectAtIndex: index)
            }
        }
    }
    
    override func detached() -> UserActivity {
        let detachedActiviy = UserActivity.init(value: self)
        detachedActiviy.values = List<Value>(self.values)
        return detachedActiviy
    }

}
