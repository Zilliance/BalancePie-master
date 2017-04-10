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
    
    private enum TableRow: Int {
        case hours = 0
        case activity
        case howLong
        case feels
    }
    
    private enum Presenting {
        case activities
        case values
        case none
    }
    
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
            
//            let hour = indexes?[0] as! Int
//            let minute = indexes?[1] as! Int * 15
//            let hourString = Int(hour) < 10 ? "0" + String(hour) : String(hour)
//            let minuteString = Int(minute) < 10 ? "0" + String(minute) : String(minute)
            
            
        }, cancel: { (picker) in
            
        }, origin: UITableViewCell())

        
    }
    
    private func selectActivity() {
        
        self.presenting = .activities
        
        guard let itemSelectionViewController = UIStoryboard.init(name: "ItemsSelection", bundle: nil).instantiateInitialViewController() as? ItemsSelectionViewController else {
            assertionFailure()
            return
        }
        itemSelectionViewController.modalPresentationStyle = .custom
        itemSelectionViewController.transitioningDelegate = self
        itemSelectionViewController.createItemTitle = "Create my own"
        itemSelectionViewController.items = ItemSelectionViewModel.activitiesItems()
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
    }
    
    private func selectActivityDuration() {
        
        ActionSheetMultipleStringPicker.show(withTitle: "Activity Duration", rows: [self.hours, self.minutes], initialSelection: [0, 0], doneBlock: { (picker, indexes, values) in
            
            //            let hour = indexes?[0] as! Int
            //            let minute = indexes?[1] as! Int * 15
            //            let hourString = Int(hour) < 10 ? "0" + String(hour) : String(hour)
            //            let minuteString = Int(minute) < 10 ? "0" + String(minute) : String(minute)
            
            
        }, cancel: { (picker) in
            
        }, origin: UITableViewCell())
        
    }

    private func selectValues() {
        
        self.presenting = .values
        
        guard let itemSelectionViewController = UIStoryboard.init(name: "ItemsSelection", bundle: nil).instantiateInitialViewController() as? ItemsSelectionViewController else {
            assertionFailure()
            return
        }
        itemSelectionViewController.modalPresentationStyle = .custom
        itemSelectionViewController.transitioningDelegate = self
        itemSelectionViewController.createItemTitle = "Create my own"
        itemSelectionViewController.items = ItemSelectionViewModel.valuesItems()
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
