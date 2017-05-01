//
//  FavoriteActivityViewController.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 4/13/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

private let headerCellIdentifier = "headerCell"
private let userActivityCellIdentifier = "userActivityCell"
private let valueCellIdentifier = "basicCell"

class FavoriteActivityViewController: UIViewController, AlertsDuration {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var getStartedButton: UIButton!
    
    fileprivate enum TableSection: Int {
        case header = 0
        case hours
        case activity
        case howLong
        case feels
        
        static var count = 5
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
    
    private var selectedSleepHoursIndex = [0, 0]
    private var selectedActivityIndex: [Int]? = []
    private var selectedValuesIndexes: [Int]? = []
    private var selectedActivityDurationIndex = [0, 0]
    
    fileprivate var favorite = Favorite()
    
    private let sleepHours = 12.labeledArray(with: "Hour")
    private let activityHours = App.Appearance.maxHours.labeledArray(with: "Hour")
    private let minutes = ["0 Minutes", "15 Minutes", "30 Minutes", "45 Minutes"]
    
    private var presenting: Presenting = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .lightBlueBackground
        self.tableView.backgroundColor = .clear
        self.getStartedButton.layer.cornerRadius = App.Appearance.buttonCornerRadius
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
    
    fileprivate func selectSleepHours() {
        
        let picker = ActionSheetMultipleStringPicker(title: "Duration", rows: [self.sleepHours, self.minutes], initialSelection: self.selectedSleepHoursIndex, doneBlock: nil, cancel: nil, origin: UIButton())!
        
        picker.toolbarBackgroundColor = UIColor.groupTableViewBackground
        picker.toolbarButtonsColor = UIColor.darkBlueBackground
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        picker.pickerTextAttributes = [NSFontAttributeName: UIFont.muliLight(size: 18.0), NSParagraphStyleAttributeName: style]
        picker.titleTextAttributes = [NSFontAttributeName: UIFont.muliBold(size: 18.0)]
        
        picker.onActionSheetDone = { (picker, indexes, values) in
            self.selectedSleepHoursIndex = indexes as! [Int]
            let hour = indexes?[0] as! Int
            let minute = indexes?[1] as! Int * 15
            self.favorite.sleepDuration = hour * 60 + minute
            
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: TableSection.hours.rawValue)], with: .fade)
        }
        
        
        picker.show()
        
    }
    
    fileprivate func selectActivity() {
        
        self.presenting = .activities
        
        guard let itemSelectionViewController = UIStoryboard(name: "ItemsSelection", bundle: nil).instantiateInitialViewController() as? ItemsSelectionViewController else {
            assertionFailure()
            return
        }
        
        let activities: [Activity] = Array(Database.shared.allActivities())
        itemSelectionViewController.createItemTitle = "Create my own"
        itemSelectionViewController.title = "Activities"
        itemSelectionViewController.items = ItemSelectionViewModel.items(from: activities)
        itemSelectionViewController.isMultipleSelectionEnabled = false
        if let index = self.selectedActivityIndex {
            itemSelectionViewController.selectedItemsIndexes = Set(index)
        }
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
            
            self.selectedActivityIndex = indexes
            guard indexes.count > 0 else {
                return
            }
            
            self.favorite.activity = activities[indexes.first!]
               self.tableView.reloadRows(at: [IndexPath(row: 0, section: TableSection.activity.rawValue)], with: .fade)
        }
    }
    
    fileprivate func selectActivityDuration() {
        
        
        let picker = ActionSheetMultipleStringPicker(title: "Duration", rows: [self.activityHours, self.minutes], initialSelection: self.selectedActivityDurationIndex, doneBlock: nil, cancel: nil, origin: UIButton())!
        
        picker.toolbarBackgroundColor = UIColor.groupTableViewBackground
        picker.toolbarButtonsColor = UIColor.darkBlueBackground
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        picker.pickerTextAttributes = [NSFontAttributeName: UIFont.muliLight(size: 18.0), NSParagraphStyleAttributeName: style]
        picker.titleTextAttributes = [NSFontAttributeName: UIFont.muliBold(size: 18.0)]
        
        picker.onActionSheetDone = { (picker, indexes, values) in
            self.selectedActivityDurationIndex = indexes as! [Int]
            let hour = indexes?[0] as! Int
            let minute = indexes?[1] as! Int * 15
            
            let totalTimeMinutes = hour * 60 + minute
            
            if totalTimeMinutes > Database.shared.user.availableMinutesForActivities {
                self.showDurationAlert() { option in
                    switch option {
                    case .allowHours:
                        self.favorite.activityDuration = totalTimeMinutes
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: TableSection.howLong.rawValue)], with: .fade)
                    case .changeHours:
                        self.selectActivityDuration()
                    }
                }
            }
            else {
                self.favorite.activityDuration = totalTimeMinutes
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: TableSection.howLong.rawValue)], with: .fade)
            }
        }
        
        
        picker.show()
        

    }
    
    fileprivate func selectValues() {
        
        self.presenting = .values
        
        guard let itemSelectionViewController = UIStoryboard(name: "ItemsSelection", bundle: nil).instantiateInitialViewController() as? ItemsSelectionViewController else {
            assertionFailure()
            return
        }
        
        let values: [Value] = Array(Database.shared.allValues()).filter { $0.type == .good }
        itemSelectionViewController.createItemTitle = "Create my own"
        itemSelectionViewController.items = ItemSelectionViewModel.items(from: values)
        itemSelectionViewController.title = "Values"
        
        if let index = self.selectedValuesIndexes {
            itemSelectionViewController.selectedItemsIndexes = Set(index)
        }
        
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
            
            self.selectedValuesIndexes = indexes
            var selectedValues: [Value] = []
            
            indexes.forEach({ (index) in
                selectedValues.append(values[index])
            })
            
            self.favorite.values = selectedValues
            
            self.tableView.reloadSections(IndexSet([TableSection.feels.rawValue]), with: .fade)

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
            value.setShowFirst()
            userActivity.values.append(value)
        }

        Database.shared.user.save(userActivity: userActivity)
        Database.shared.user.saveTimeSlept(hours: self.favorite.sleepDuration.asHoursMinutes.0 , minutes: self.favorite.sleepDuration.asHoursMinutes.1)
    }
    
    private func gotoPie() {
        
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        guard let rootViewController = window.rootViewController else {
            return
        }
        
        let sideMenuViewController = CustomSideViewController()
        sideMenuViewController.setupPie()
        
        sideMenuViewController.view.frame = rootViewController.view.frame
        sideMenuViewController.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: { 
            window.rootViewController = sideMenuViewController
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
        return TableSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case TableSection.feels.rawValue:
            return max(self.favorite.values.count, 1)
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (TableSection(rawValue: indexPath.section), indexPath.row) {
        
        case (.header?, _):
            return tableView.dequeueReusableCell(withIdentifier: headerCellIdentifier, for: indexPath)
            
        case (.hours?, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: userActivityCellIdentifier, for: indexPath) as! UserActivityTableViewCell
            
            cell.titleLabel.text = "About how many hours do you sleep in a night?"
            cell.valueLabel.text = self.favorite.sleepDuration >= 0 ? self.favorite.sleepDuration.userFriendlyText : ""
            
            return cell
            
        case (.activity?, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: userActivityCellIdentifier, for: indexPath) as! UserActivityTableViewCell
            
            cell.titleLabel.text = "What is one of your favorite activities?"
            cell.valueLabel.text = self.favorite.activity?.name ?? ""
            
            return cell
            
        case (.howLong?, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: userActivityCellIdentifier, for: indexPath) as! UserActivityTableViewCell
           
            cell.titleLabel.text = "Roughly how many hours a week do you spend on this activity?"
            cell.valueLabel.text = self.favorite.activityDuration >= 0 ? self.favorite.activityDuration.userFriendlyText : ""
            
            return cell
            
        case (.feels?, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: userActivityCellIdentifier, for: indexPath) as! UserActivityTableViewCell
            
            cell.titleLabel.text = "Why does this activity feel good?"
            cell.valueLabel.text = self.favorite.values.count == 0 ? "" : self.favorite.values[indexPath.row].name
            
            return cell
            
        case (.feels?, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: valueCellIdentifier, for: indexPath)
            cell.textLabel?.text = self.favorite.values[indexPath.row].name
            
            return cell
    
        default:
            assertionFailure()
            return tableView.dequeueReusableCell(withIdentifier: "Error")!
            
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
}


extension FavoriteActivityViewController: UITableViewDelegate, UIViewControllerTransitioningDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (TableSection(rawValue: indexPath.section), indexPath.row) {
        case (.hours?, _): return 120
        case (_, 0): return 96
        default: return 44
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch TableSection(rawValue: indexPath.section) {
        case .hours?:
            self.selectSleepHours()
            
        case .activity?:
            self.selectActivity()
            
        case .howLong?:
            self.selectActivityDuration()
            
        case .feels?:
            self.selectValues()
            
        default:
            break
        }
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PartialSizePresentationController(presentedViewController: presented, presenting: presenting, height: self.view.frame.size.height / 2.0)
        return presentationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PartialModalTrasition(withType: .dismissing)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PartialModalTrasition(withType: .presenting)
    }
}
