//
//  FineTuneItem.swift
//  Zilliance
//
//  Created by Philip Dow on 7/31/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

struct FineTuneItem {
    let title: String
    let image: UIImage
    let viewController: FineTuneItemViewController
    let type : FineTuneType
}

enum FineTuneType: String {
    case pleasure
    case prioritize
    case gratitude
    case giving
    case values
    case replace
    case reduce
    case shift
    case need
}

extension FineTuneItem {
    
    // Great
    
    static var greatPleasure: FineTuneItem = {
        let item = FineTuneItem(title: "Pleasure", image: UIImage(named: "fine-tune-pleasure")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "great-pleasure") as! FineTuneItemViewController, type : .pleasure)
        item.viewController.item = item
        return item
    }()
    
    static let greatPrioritize: FineTuneItem = {
        let item = FineTuneItem(title: "Prioritize", image: UIImage(named: "fine-tune-prioritize")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "great-prioritize") as! FineTuneItemViewController, type : .prioritize)
        item.viewController.item = item
        return item
    }()
    
    static var greatGratitude: FineTuneItem = {
        let item = FineTuneItem(title: "Gratitude", image: UIImage(named: "fine-tune-gratitude")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "great-gratitude") as! FineTuneItemViewController, type : .gratitude)
        item.viewController.item = item
        return item
    }()
    
    static let greatGiving: FineTuneItem = {
        let item = FineTuneItem(title: "Giving", image: UIImage(named: "fine-tune-giving")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "great-giving") as! FineTuneItemViewController, type : .giving)
        item.viewController.item = item
        return item
    }()
    
    static let greatValues: FineTuneItem = {
        let item = FineTuneItem(title: "Values", image: UIImage(named: "fine-tune-values")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "great-values") as! FineTuneItemViewController, type : .values)
        item.viewController.item = item
        return item
    }()
    
    // Good
    
    static let goodGratitude: FineTuneItem = {
        let item = FineTuneItem(title: "Gratitude", image: UIImage(named: "fine-tune-gratitude")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "good-gratitude") as! FineTuneItemViewController, type : .gratitude)
        item.viewController.item = item
        return item
    }()
    
    static let goodPleasure: FineTuneItem = {
        let item = FineTuneItem(title: "Pleasure", image: UIImage(named: "fine-tune-pleasure")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "good-pleasure") as! FineTuneItemViewController, type : .pleasure)
        item.viewController.item = item
        return item
    }()
    
    static let goodPrioritize: FineTuneItem = {
        let item = FineTuneItem(title: "Prioritize", image: UIImage(named: "fine-tune-prioritize")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "good-prioritize") as! FineTuneItemViewController, type : .prioritize)
        item.viewController.item = item
        return item
    }()
    
    static let goodNeed: FineTuneItem = {
        let item = FineTuneItem(title: "Need", image: UIImage(named: "fine-tune-need")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "good-need") as! FineTuneItemViewController, type : .need)
        item.viewController.item = item
        return item
    }()
    
    static let goodValues: FineTuneItem = {
        let item = FineTuneItem(title: "Values", image: UIImage(named: "fine-tune-values")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "good-values") as! FineTuneItemViewController, type : .values)
        item.viewController.item = item
        return item
    }()
    
    // Mixed
    
    static var mixedReplace: FineTuneItem = {
        let item = FineTuneItem(title: "Replace", image: UIImage(named: "fine-tune-replace")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "mixed-replace") as! FineTuneItemViewController, type : .replace)
        item.viewController.item = item
        return item
    }()
    
    static let mixedReduce: FineTuneItem = {
        let item = FineTuneItem(title: "Reduce", image: UIImage(named: "fine-tune-reduce")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "mixed-reduce") as! FineTuneItemViewController, type : .reduce)
        item.viewController.item = item
        return item
    }()
    
    static let mixedShift: FineTuneItem = {
        let item = FineTuneItem(title: "Shift", image: UIImage(named: "fine-tune-shift")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "mixed-shift") as! FineTuneItemViewController, type : .shift)
        item.viewController.item = item
        return item
    }()
    
    static let mixedValues: FineTuneItem = {
        let item = FineTuneItem(title: "Values", image: UIImage(named: "fine-tune-values")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "mixed-values") as! FineTuneItemViewController, type : .values)
        item.viewController.item = item
        return item
    }()
    
    static let mixedNeed: FineTuneItem = {
        let item = FineTuneItem(title: "Need", image: UIImage(named: "fine-tune-need")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "mixed-need") as! FineTuneItemViewController, type : .need)
        item.viewController.item = item
        return item
    }()
    
    // Lousy
    
    static let lousyReplace: FineTuneItem = {
        let item = FineTuneItem(title: "Replace", image: UIImage(named: "fine-tune-replace")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "lousy-replace") as! FineTuneItemViewController, type : .replace)
        item.viewController.item = item
        return item
    }()
    
    static let lousyReduce: FineTuneItem = {
        let item = FineTuneItem(title: "Reduce", image: UIImage(named: "fine-tune-reduce")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "lousy-reduce") as! FineTuneItemViewController, type : .reduce)
        item.viewController.item = item
        return item
    }()
    
    static let lousyShift: FineTuneItem = {
        let item = FineTuneItem(title: "Shift", image: UIImage(named: "fine-tune-shift")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "lousy-shift") as! FineTuneItemViewController, type : .shift)
        item.viewController.item = item
        return item
    }()
    
    static let lousyNeed: FineTuneItem = {
        let item = FineTuneItem(title: "Need", image: UIImage(named: "fine-tune-need")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "lousy-need") as! FineTuneItemViewController, type : .need)
        item.viewController.item = item
        return item
    }()
    
    static let lousyValues: FineTuneItem = {
        let item = FineTuneItem(title: "Values", image: UIImage(named: "fine-tune-values")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "lousy-values") as! FineTuneItemViewController, type : .values)
        item.viewController.item = item
        return item
    }()
}
