//
//  FavoriteActivityViewController.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 4/13/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class FavoriteActivityViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate enum FavoriteTableSections: Int
    {
        case hours = 0
        case activity
        case howLong
        case feels
    }
    
    fileprivate struct Favorite {
        var sleepDuration: Minutes = -1
        var activity: Activity?
        var activityDuration: Minutes = -1
        var values: [Value] = []
    }
    
    private enum Presenting {
        case activities
        case values
        case none
    }
    
    private enum InputDataError {
        case sleepDuration
        case activity
        case activityDuration
        case values
    }
    
    fileprivate var favorite = Favorite()
    
    private let hours = App.Appearance.zilianceMaxHours.labeledArray(with: "Hour")
    private let minutes = ["0 Minutes", "15 Minutes", "30 Minutes", "45 Minutes"]
    
    private var presenting: Presenting = .none
    
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
    
    fileprivate func selectSleepHours() {
        
        ActionSheetMultipleStringPicker.show(withTitle: "Sleep Hours", rows: [self.hours, self.minutes], initialSelection: [0, 0], doneBlock: { (picker, indexes, values) in
            
            let hour = indexes?[0] as! Int
            let minute = indexes?[1] as! Int * 15
            self.favorite.sleepDuration = hour * 60 + minute
            
             self.tableView.reloadRows(at: [IndexPath(row: 0, section: FavoriteTableSections.hours.rawValue)], with: .fade)
            
        }, cancel: { (picker) in
            
        }, origin: UITableViewCell())
        
        
    }
    
    fileprivate func selectActivity() {
        
        self.presenting = .activities
        
        guard let itemSelectionViewController = UIStoryboard(name: "ItemsSelection", bundle: nil).instantiateInitialViewController() as? ItemsSelectionViewController else {
            assertionFailure()
            return
        }
        
        let activities: [Activity] = Array(Database.shared.allActivities())
        itemSelectionViewController.createItemTitle = "Create my own"
        itemSelectionViewController.items = ItemSelectionViewModel.items(from: activities)
        itemSelectionViewController.isMultipleSelectionEnabled = false
        let navigationController = UINavigationController(rootViewController: itemSelectionViewController)
        navigationController.modalPresentationStyle = .custom
        navigationController.transitioningDelegate = self
        DispatchQueue.main.async {
            self.present(navigationController, animated: true, completion: nil)
        }
        
        
        itemSelectionViewController.createNewItemAction = {
            
            itemSelectionViewController.dismiss(animated: true, completion: {
                guard let customActivityViewController = UIStoryboard(name: "AddCustom", bundle: nil).instantiateViewController(withIdentifier: "AddActivity") as? UINavigationController else {
                    assertionFailure()
                    return
                }
                
                self.present(customActivityViewController, animated: true, completion: nil)
            })
            
        }
        
        itemSelectionViewController.doneAction = { indexes in
            
            guard indexes.count > 0 else {
                return
            }
            
            self.favorite.activity = activities[indexes.first!]
               self.tableView.reloadRows(at: [IndexPath(row: 0, section: FavoriteTableSections.activity.rawValue)], with: .fade)
        }
    }
    
    fileprivate func selectActivityDuration() {
        
        ActionSheetMultipleStringPicker.show(withTitle: "Activity Duration", rows: [self.hours, self.minutes], initialSelection: [0, 0], doneBlock: { (picker, indexes, values) in
            
            let hour = indexes?[0] as! Int
            let minute = indexes?[1] as! Int * 15
            self.favorite.activityDuration = hour * 60 + minute
            
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: FavoriteTableSections.howLong.rawValue)], with: .fade)
            
            
        }, cancel: { (picker) in
            
        }, origin: UITableViewCell())
        
    }
    
    fileprivate func selectValues() {
        
        self.presenting = .values
        
        guard let itemSelectionViewController = UIStoryboard(name: "ItemsSelection", bundle: nil).instantiateInitialViewController() as? ItemsSelectionViewController else {
            assertionFailure()
            return
        }
        
        let values: [Value] = Array(Database.shared.allValues())
        itemSelectionViewController.createItemTitle = "Create my own"
        itemSelectionViewController.items = ItemSelectionViewModel.items(from: values)
        
        let navigationController = UINavigationController(rootViewController: itemSelectionViewController)
        navigationController.modalPresentationStyle = .custom
        navigationController.transitioningDelegate = self
        DispatchQueue.main.async {
            self.present(navigationController, animated: true, completion: nil)
        }
        
        itemSelectionViewController.createNewItemAction = {
            
            itemSelectionViewController.dismiss(animated: true, completion: {
                guard let customValueViewController = UIStoryboard(name: "AddCustom", bundle: nil).instantiateViewController(withIdentifier: "AddValue") as? UINavigationController else {
                    assertionFailure()
                    return
                }
                
                self.present(customValueViewController, animated: true, completion: nil)
            })
            
        }
        
        itemSelectionViewController.doneAction = { indexes in
            
            guard indexes.count > 0 else {
                return
            }
            
            var selectedValues: [Value] = []
            
            indexes.forEach({ (index) in
                selectedValues.append(values[index])
            })
            
            self.favorite.values = selectedValues
            
            self.tableView.reloadSections(IndexSet([FavoriteTableSections.feels.rawValue]), with: .fade)

        }
        
    }
    
    private func validateData() -> InputDataError? {
        
        if self.favorite.sleepDuration < 0 {
            return .sleepDuration
        }
        
        if self.favorite.activity == nil {
            return .activity
        }
        
        if self.favorite.activityDuration < 0 {
            return .activityDuration
        }
        
        if self.favorite.values.count == 0 {
            return .values
        }
        
        return nil
    }
    
    private func saveData() {
        let userActivity = UserActivity()
        userActivity.activity = self.favorite.activity
        userActivity.duration = self.favorite.activityDuration
        userActivity.feeling = .great
        
        self.favorite.values.forEach { (value) in
            userActivity.values.append(value)
        }
        
        Database.shared.user.save(userActivity: userActivity)
        Database.shared.user.saveTimeSlept(hours: self.favorite.sleepDuration.asHoursMinutes.0 , minutes: self.favorite.sleepDuration.asHoursMinutes.1)
    }
    
    private func gotoPie() {
        guard let pieViewController = UIStoryboard(name: "Pie", bundle: nil).instantiateInitialViewController() else {
            assertionFailure()
            return
        }
        
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        guard let rootViewController = window.rootViewController else {
            return
        }
        
        pieViewController.view.frame = rootViewController.view.frame
        pieViewController.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: { 
            window.rootViewController = pieViewController
        }, completion: nil)
    }


    // MARK -- User Actions
    
    @IBAction func getStartedAction(_ sender: Any) {
        
        if let error: InputDataError = validateData() {
            
            switch error {
            case .sleepDuration:
                self.showAlert(message: "Please enter your sleep time", title: nil)
            case .activity:
                self.showAlert(message: "Please select an activity", title: nil)
            case .activityDuration:
                self.showAlert(message: "Please enter the duration of your activity", title: nil)
            case .values:
                self.showAlert(message: "Please select your value(s)", title: nil)
                
            }
            
        } else {
            self.saveData()
            self.gotoPie()
        }

    }
    
}

extension FavoriteActivityViewController: UITableViewDataSource
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case FavoriteTableSections.feels.rawValue:
            return max(self.favorite.values.count, 1)
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        switch (indexPath.section, indexPath.row) {
        case (FavoriteTableSections.hours.rawValue, _):
            
            cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell")!
            cell.textLabel?.text = "Sleep Hours"
            
            cell.detailTextLabel?.text = self.favorite.sleepDuration >= 0 ? self.favorite.sleepDuration.userFriendlyText : ""
            
        case (FavoriteTableSections.activity.rawValue, _):
            
            cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell")!
            cell.textLabel?.text = "Favorite Activity"
            if let title = self.favorite.activity?.name {
                cell.detailTextLabel?.text = title
            } else {
                cell.detailTextLabel?.text = ""
            }
            
        case (FavoriteTableSections.howLong.rawValue, _):
            cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell")!
            cell.textLabel?.text = "About how Long"
            cell.detailTextLabel?.text = self.favorite.activityDuration >= 0 ? self.favorite.activityDuration.userFriendlyText : ""
            
        case (FavoriteTableSections.feels.rawValue, 0):
            
            cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell")!
            cell.textLabel?.text = "Activity Feels Good Because Off"
            cell.detailTextLabel?.text = ""
            
            if (self.favorite.values.count == 0)
            {
                cell.detailTextLabel?.text = ""
                break
            }
            cell.detailTextLabel?.text = self.favorite.values[indexPath.row].name
            
        case (FavoriteTableSections.feels.rawValue, 1...Int(INT_MAX)):
            
            cell = tableView.dequeueReusableCell(withIdentifier: "basicCell")!
            cell.textLabel?.text = self.favorite.values[indexPath.row].name
    
        default:
            break
            
            
        }
        
        return cell
        
    }
}


extension FavoriteActivityViewController: UITableViewDelegate, UIViewControllerTransitioningDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 64 : 44
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //activity name
        
        switch indexPath.section {
        case FavoriteTableSections.hours.rawValue:
            self.selectSleepHours()
            
        case FavoriteTableSections.activity.rawValue:
            self.selectActivity()
            
        case FavoriteTableSections.howLong.rawValue:
            self.selectActivityDuration()
            
        case FavoriteTableSections.feels.rawValue:
            self.selectValues()
            
        default:
            break
        }
        
    }
    
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let presentationController = PartialSizePresentationController(presentedViewController: presented,
                                                                       presenting: presenting, height: self.view.frame.size.height / 2.0)
        return presentationController
    }
    
}
