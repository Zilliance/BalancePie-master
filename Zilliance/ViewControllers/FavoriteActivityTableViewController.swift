//
//  FavoriteActivityTableViewController.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 4/10/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class FavoriteActivityTableViewController: UITableViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var sleepHoursLabel: UILabel!
    @IBOutlet weak var favoriteActivityLabel: UILabel!
    @IBOutlet weak var howLongLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    private enum TableRow: Int {
        case hours = 0
        case activity
        case howLong
        case feels
    }
    
    private struct Favorite {
        var sleepDuration: Minutes = -1
        var activity: Activity?
        var activityDuration: Minutes = -1
        var value: Value?
    }
    
    private enum Presenting {
        case activities
        case values
        case none
    }
    
    private var favorite = Favorite()
    
    private let hours = App.Appearance.zilianceMaxHours.labeledArray(with: "Hour")
    private let minutes = ["0 Minutes", "15 Minutes", "30 Minutes", "45 Minutes"]

    private var presenting: Presenting = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupPresenting()
    }
    
    private func setupPresenting() {
        switch self.presenting {
        case .activities:
            self.selectActivity()
        case .values:
            self.selectValues()
        case .none:
            break
        }
        
        self.presenting = .none
    }
    
    // MARK: --
    
    private func selectSleepHours() {
        
        ActionSheetMultipleStringPicker.show(withTitle: "Sleep Hours", rows: [self.hours, self.minutes], initialSelection: [0, 0], doneBlock: { (picker, indexes, values) in
            
            let hour = indexes?[0] as! Int
            let minute = indexes?[1] as! Int * 15
            self.favorite.sleepDuration = hour * 60 + minute
            self.sleepHoursLabel.text = self.favorite.sleepDuration.userFriendlyText
            
        }, cancel: { (picker) in
            
        }, origin: UITableViewCell())

        
    }
    
    private func selectActivity() {
        
        self.presenting = .activities
        
        guard let itemSelectionViewController = UIStoryboard.init(name: "ItemsSelection", bundle: nil).instantiateInitialViewController() as? ItemsSelectionViewController else {
            assertionFailure()
            return
        }
        let activities: [Activity] = Array(Database.shared.allActivities())
        itemSelectionViewController.modalPresentationStyle = .custom
        itemSelectionViewController.transitioningDelegate = self
        itemSelectionViewController.createItemTitle = "Create my own"
        itemSelectionViewController.items = ItemSelectionViewModel.items(from: activities)
        itemSelectionViewController.isMultipleSelectionEnabled = false
        DispatchQueue.main.async {
            self.present(itemSelectionViewController, animated: true, completion: nil)
        }

        
        itemSelectionViewController.createNewItemAction = {
            
            itemSelectionViewController.dismiss(animated: true, completion: {
                guard let customActivityViewController = UIStoryboard.init(name: "AddCustom", bundle: nil).instantiateViewController(withIdentifier: "AddActivity") as? UINavigationController else {
                    assertionFailure()
                    return
                }
                
                self.present(customActivityViewController, animated: true, completion: nil)
            })
            
        }
        
        itemSelectionViewController.doneAction = { index in
            self.favorite.activity = activities[index.first!]
            self.favoriteActivityLabel.text = activities[index.first!].name
        }
    }
    
    private func selectActivityDuration() {
        
        ActionSheetMultipleStringPicker.show(withTitle: "Activity Duration", rows: [self.hours, self.minutes], initialSelection: [0, 0], doneBlock: { (picker, indexes, values) in
            
            let hour = indexes?[0] as! Int
            let minute = indexes?[1] as! Int * 15
            self.favorite.activityDuration = hour * 60 + minute
            self.howLongLabel.text = self.favorite.activityDuration.userFriendlyText
            
        }, cancel: { (picker) in
            
        }, origin: UITableViewCell())
        
    }

    private func selectValues() {
        
        self.presenting = .values
        
        guard let itemSelectionViewController = UIStoryboard.init(name: "ItemsSelection", bundle: nil).instantiateInitialViewController() as? ItemsSelectionViewController else {
            assertionFailure()
            return
        }
        
        let values: [Value] = Array(Database.shared.allValues())
        itemSelectionViewController.modalPresentationStyle = .custom
        itemSelectionViewController.transitioningDelegate = self
        itemSelectionViewController.createItemTitle = "Create my own"
        itemSelectionViewController.items = ItemSelectionViewModel.items(from: values)
        DispatchQueue.main.async {
            self.present(itemSelectionViewController, animated: true, completion: nil)
        }
        
        itemSelectionViewController.createNewItemAction = {
            
            itemSelectionViewController.dismiss(animated: true, completion: { 
                guard let customValueViewController = UIStoryboard.init(name: "AddCustom", bundle: nil).instantiateViewController(withIdentifier: "AddValue") as? UINavigationController else {
                    assertionFailure()
                    return
                }
                
                self.present(customValueViewController, animated: true, completion: nil)
            })
            
        }
        
    }
    
    // MARK: -- User Actions
    
    @IBAction func getStartedAction(_ sender: Any) {
        
        
    }
    
    
    // MARK: -- table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case TableRow.hours.rawValue:
            self.selectSleepHours()
        case TableRow.activity.rawValue:
            self.selectActivity()
        case TableRow.howLong.rawValue:
            self.selectActivityDuration()
        case TableRow.feels.rawValue:
            self.selectValues()
        default:
            break
        }
    }
    
    // MARK: -- UIViewControllerTransitioningDelegate
    
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let presentationController = PartialSizePresentationController(presentedViewController: presented,
                                                                       presenting: presenting, height: self.view.frame.size.height / 2.0)
        return presentationController
    }
}
