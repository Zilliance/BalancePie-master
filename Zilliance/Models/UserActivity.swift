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
    case good
    case lousy
    case mixed
    
    var string: String? {
        switch self {
        case .none:
            return nil
        case .great:
            return "😄 Great"
        case .good:
            return "🙂 Good"
        case .lousy:
            return "☹️ Lousy"
        case .mixed:
            return "😕 Mixed"
        }
    }
    
    static let all: [Feeling] = [.great, .good, .lousy, .mixed]
}

extension Feeling {
    
    var goodTitleText: String {
        switch self {
        case .great:
            return "Why does this activity make you feel great?"
        case .good:
            assertionFailure()
            return ""
        case .lousy:
            assertionFailure()
            return ""
        case .mixed:
            return "What feels good about this activity"
        case .none:
            assertionFailure()
            return ""
        }

    }
    
    var badTitleText: String {
        switch self {
        case .great:
            assertionFailure()
            return ""
        case .good:
            return "Why does this activity make you feel good?"
        case .lousy:
            return "Why does this activity make you feel lousy?"
        case .mixed:
            return "What feels not-so-good about this activity?"
        case .none:
            assertionFailure()
            return ""
        }
    }

}

final class UserActivity: Object {
    
    dynamic var activity: Activity?
    dynamic var duration: Minutes = 0
    var values = List<Value>()
    dynamic var feeling: Feeling = .none
    dynamic var id: String = UUID().uuidString
    
    var image: UIImage? {
        guard let iconName = self.activity?.iconName else
        {
            return nil
        }

        return UIImage(named: iconName)
    }
    
    var color: UIColor {
        switch(feeling){
        case .great:
            return .feelingGreat
        case .good:
            return .feelingGood
        case .lousy:
            return .feelingLousy
        case .mixed:
            return .feelingMixed
        case .none:
            return UIColor.white
        }
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    var goodValues: Array<Value> {
        return self.values.filter{$0.type == .good}.sorted {
            $0.order == $1.order ? $0.name < $1.name : $0.order.rawValue < $1.order.rawValue
        }
    }

    var badValues: Array<Value> {
        return self.values.filter{$0.type == .bad}.sorted {
            $0.order == $1.order ? $0.name < $1.name : $0.order.rawValue < $1.order.rawValue
        }
    }
    
    var neutralValues: Array<Value> {
        return self.values.filter{$0.type == .neutral}.sorted {
            $0.order == $1.order ? $0.name < $1.name : $0.order.rawValue < $1.order.rawValue
        }
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
    
    
    func removeNeutralValues()
    {
        self.neutralValues.forEach{
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
        let detachedActivity = UserActivity(value: self)
        detachedActivity.values = List<Value>(self.values)
        return detachedActivity
    }

}

extension UIColor {
    static let feelingGreat = UIColor.color(forRed: 91.0, green: 178.0, blue: 86.0, alpha: 1)
    static let feelingGood = UIColor.color(forRed: 255.0, green: 206.0, blue: 7.0, alpha: 1)
    static let feelingMixed = UIColor.color(forRed: 255.0, green: 130.0, blue: 16.0, alpha: 1)
    static let feelingLousy = UIColor.color(forRed: 235.0, green: 60.0, blue: 67.0, alpha: 1)
}
