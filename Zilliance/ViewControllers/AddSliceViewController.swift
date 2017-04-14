//
//  AddSliceViewController.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 10-04-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import Foundation
import UIKit
import ActionSheetPicker_3_0

final class AddSliceViewController: UIViewController
{
    enum TableSection: Int
    {
        case name = 0
        case duration
        case feelingType
        case goodFeelings
        case badFeelings
        
        static func feelingSections() -> [Int]{
            return [feelingType.rawValue, goodFeelings.rawValue, badFeelings.rawValue]
        }
    }

    fileprivate static let initialRowFeelingsTable: Int = 3
    fileprivate var isPresentingActivities = false
    
    @IBOutlet weak var tuneSliceButton: UIButton!
    @IBOutlet weak var addAnotherActivityButton: UIButton!
    @IBOutlet fileprivate weak var tableView: UITableView!

    var newActivity = UserActivity()
    
    fileprivate var feelingInternalTableModel: EmbeddedFeelingTableViewModel!
    fileprivate weak var table: UITableView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup width and corner radius
        for view in [self.tuneSliceButton, self.addAnotherActivityButton] as [UIView]
        {
            view.layer.cornerRadius = App.Appearance.buttonCornerRadius
            view.layer.borderWidth = App.Appearance.borderWidth
            view.layer.borderColor = UIColor.lightGray.cgColor
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isPresentingActivities {
            self.selectActivityName()
        }
        self.isPresentingActivities = false
    }
    
    func validateValues() -> Bool
    {
        if (self.newActivity.activity == nil)
        {
            showAlert(message: "Please select an activity", title: "")
            return false
        }
        else
        if (self.newActivity.duration == 0)
        {
            showAlert(message: "Please select a duration for the activity", title: "")
            return false
        }
        else
            if (self.newActivity.feeling == .none)
            {
                showAlert(message: "Please select how you feel about the activity", title: "")
                return false
        }
        
        return true
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        
        if (self.validateValues())
        {
            self.saveActivity()
            self.dismiss(animated: true, completion: nil)
        }

    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func saveActivity()
    {
        Database.shared.user.save(userActivity: self.newActivity)
        
        //since we'll keep modifying it we'll need an in memory copy of it
        self.newActivity = self.newActivity.detached()
        
    }
    
    private func fineTune(userActivity: UserActivity) {

        //fine tune setup example. It should use other view controllers
        let addStoryboard = UIStoryboard(name: "AddCustom", bundle: nil)
        
        let fineTuneStoryboard = UIStoryboard(name: "FineTuneActivity", bundle: nil)
        
        guard let addActivityVC = addStoryboard.instantiateViewController(withIdentifier: "AddActivityViewController") as? AddActivityViewController,
            let addValueVC = addStoryboard.instantiateViewController(withIdentifier: "AddValuesViewController") as? AddValuesViewController,
            let fineTuneVC = fineTuneStoryboard.instantiateInitialViewController() as? FineTuneActivityViewController
            else
        {
            return
        }
        
        let fineTuneItem0 = FineTuneItem(title: "Activity", image: UIImage(named: "btnPlus")!, viewController: addActivityVC)
        let fineTuneItem1 = FineTuneItem(title: "Value", image: UIImage(named: "btnPlus")!, viewController: addValueVC)
        
        let items = [fineTuneItem0, fineTuneItem1]
        
        fineTuneVC.items = items
        let navigationFineTuneVC = UINavigationController(rootViewController: fineTuneVC)
        self.present(navigationFineTuneVC, animated: true, completion: nil)
    }
    
    @IBAction func fineTuneTapped(_ sender: Any) {
        if (self.validateValues())
        {
            self.saveActivity()
            fineTune(userActivity: self.newActivity)
        }
    }
    
    @IBAction func addAnotherSliceTapped(_ sender: Any) {
        self.saveActivity()
        
        let addStoryboard = UIStoryboard(name: "AddCustom", bundle: nil)
        guard let addActivityVC = addStoryboard.instantiateViewController(withIdentifier: "AddSliceViewController") as? AddSliceViewController
            else{
                return
        }
        
        self.navigationController?.pushViewController(addActivityVC, animated: true)
    }
    
    @IBAction func backToPieTapped(_ sender: Any) {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    
}

extension AddSliceViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    } 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section
        {
        case TableSection.goodFeelings.rawValue:
            
            if (self.newActivity.feeling == .lousy || self.newActivity.feeling == .neutral || self.newActivity.feeling == .none)
            {
                return 0
            }
            
            return max(self.newActivity.goodValues.count, 1)
        case TableSection.badFeelings.rawValue:
            
            if (self.newActivity.feeling == .great || self.newActivity.feeling == .none)
            {
                return 0
            }
            
            return max(self.newActivity.badValues.count, 1)
        default:
            return 1
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        switch (indexPath.section, indexPath.row) {
            
        case (TableSection.name.rawValue, _):
            cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell")!
            cell.textLabel?.text = "Name of this activity"
            
            cell.detailTextLabel?.text = self.newActivity.activity?.name ?? " "
            
        case (TableSection.duration.rawValue, _):
            
            cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell")!
            cell.textLabel?.text = "About how long"
            cell.detailTextLabel?.text = self.newActivity.duration.userFriendlyText
            
        case (TableSection.feelingType.rawValue, _):
            
            cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell")!
            cell.textLabel?.text = "How do you feel"
            cell.detailTextLabel?.text = self.newActivity.feeling.string
            
        case (TableSection.goodFeelings.rawValue, 0):
            
            cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell")!
            cell.textLabel?.text = "Feels good because"
            if (self.newActivity.goodValues.count == 0)
            {
                cell.detailTextLabel?.text = ""
                break
            }
            cell.detailTextLabel?.text = self.newActivity.goodValues[indexPath.row].name
            
        case (TableSection.badFeelings.rawValue, 0):
            
            cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell")!
            cell.textLabel?.text = "Feels bad because"
            if (self.newActivity.badValues.count == 0)
            {
                cell.detailTextLabel?.text = ""
                break
            }
            cell.detailTextLabel?.text = self.newActivity.badValues[indexPath.row].name
            
        case (TableSection.goodFeelings.rawValue, 1...Int(INT_MAX)):
            
            cell = tableView.dequeueReusableCell(withIdentifier: "basicCell")!
            cell.textLabel?.text = self.newActivity.goodValues[indexPath.row].name
            
        case (TableSection.badFeelings.rawValue, 1...Int(INT_MAX)):
            
            cell = tableView.dequeueReusableCell(withIdentifier: "basicCell")!
            cell.textLabel?.text = self.newActivity.badValues[indexPath.row].name
            
        default:
            break
        }
        
        cell.selectionStyle = .none
        
        return cell
        
    }

}

extension AddSliceViewController: UITableViewDelegate, UIViewControllerTransitioningDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 64 : 34
    }
    
    func selectActivityName()
    {
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
                self.isPresentingActivities = true

                self.present(customActivityViewController, animated: true, completion: nil)
            })
            
        }
        
        itemSelectionViewController.doneAction = { indexes in
            
            guard indexes.count > 0 else {
                return
            }
            
            self.newActivity.activity = activities[indexes.first!]
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        }
    
    }
    
    func selectDuration()
    {
        let hours = 80.labeledArray(with: "Hour")
        let minutes = ["0 Minutes", "15 Minutes", "30 Minutes", "45 Minutes"]
        let selectedDuration = self.newActivity.duration
        let selectedHour = selectedDuration.asHoursMinutes.0
        let selectedMinutes = selectedDuration.asHoursMinutes.1 / 15
        
        ActionSheetMultipleStringPicker.show(withTitle: "Duration", rows: [hours, minutes], initialSelection: [selectedHour, selectedMinutes], doneBlock: { (picker, indexes, values) in
            
            guard let hour = indexes?[0] as? Int, var minute = indexes?[1] as? Int else {
                assertionFailure()
                return
            }
            minute *= 15
            
            let totalTimeMinutes = hour * 60 + minute
            
            self.newActivity.duration = totalTimeMinutes
            
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
            
        }, cancel: { (picker) in
            
        }, origin: UIButton())
    }
    
    func selectHowItFeels()
    {
        let feelings = Feeling.all
        let feelingsNames = feelings.map({$0.string})
        
        let initialIndex = feelings.index(of: self.newActivity.feeling) ?? 0
        
        ActionSheetStringPicker.show(withTitle: "How do you feel about it ?", rows: feelingsNames, initialSelection: initialIndex, doneBlock: { (picker, index, name) in
            
            self.newActivity.feeling = feelings[index]
            
            let feelingSections: [Int] = TableSection.feelingSections()
            
            self.tableView.reloadSections(IndexSet(feelingSections), with: .fade)
            
            self.tableView.endUpdates()
            
            return
        }, cancel: { (picker) in
            return
        }, origin: tableView)
    }
    
    
    func selectValues(values: [Value], initialIndexes: [Int], completion: @escaping ([Int])->())
    {
        let storyboard = UIStoryboard(name: "ItemsSelection", bundle: nil)
        if let itemsVC = storyboard.instantiateInitialViewController() as? ItemsSelectionViewController
        {
            
            itemsVC.selectedItemsIndexes = Set(initialIndexes)
            
            let valuesNames = values.map({$0.name})
            for valueName in valuesNames
            {
                let itemModel = ItemSelectionViewModel(title: valueName, image:nil)
                itemsVC.items.append(itemModel)
            }
            
            itemsVC.createItemTitle = "Create a new Value"
            itemsVC.createNewItemAction = {
                print("this should launch a controller to show the activity creation")
            }
            
            itemsVC.doneAction = { indexes in
                completion(indexes)
            }
            
            itemsVC.createNewItemAction = {
                
                itemsVC.dismiss(animated: true, completion: {
                    guard let customValueViewController = UIStoryboard(name: "AddCustom", bundle: nil).instantiateViewController(withIdentifier: "AddValuesViewController") as? AddValuesViewController else {
                        assertionFailure()
                        return
                    }
                    
                    let navigation = UINavigationController(rootViewController: customValueViewController)
                    self.present(navigation, animated: true, completion: nil)
                    
                    customValueViewController.dismissAction = {
                        //need to go back to the values selection
                        self.selectValues(values: values, initialIndexes: initialIndexes, completion: completion)
                    }
                    
                })
                
            }
            
            let navigation = UINavigationController(rootViewController: itemsVC)
            navigation.transitioningDelegate = self
            navigation.modalPresentationStyle = .custom
            
            self.present(navigation, animated: true, completion: nil)
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //activity name
        
        switch indexPath.section {
        case TableSection.name.rawValue:
            self.selectActivityName()
            
        case TableSection.duration.rawValue:
            self.selectDuration()
            
        case TableSection.feelingType.rawValue:
            self.selectHowItFeels()
            
        case TableSection.goodFeelings.rawValue:
            let values = Value.goodValues
            let selectedValues = values.flatMap({self.newActivity.goodValues.index(of: $0) == nil ? nil : values.index(of: $0)})
            
            self.selectValues(values: values, initialIndexes: selectedValues, completion: { (indexes) in
                self.newActivity.removeGoodValues()
                
                for index in indexes
                {
                    let value = values[index]
                    self.newActivity.values.append(value)
                }
                
                self.tableView.reloadSections(IndexSet([TableSection.goodFeelings.rawValue]), with: .fade)
            })
            
        case TableSection.badFeelings.rawValue:
            let values = Value.badValues
            let selectedValues = values.flatMap({self.newActivity.badValues.index(of: $0) == nil ? nil : values.index(of: $0)})
            
            self.selectValues(values: values, initialIndexes: selectedValues, completion: { (indexes) in
                self.newActivity.removeBadValues()
                
                for index in indexes
                {
                    let value = values[index]
                    self.newActivity.values.append(value)
                }
                
                self.tableView.reloadSections(IndexSet([TableSection.badFeelings.rawValue]), with: .fade)
            })
            
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

