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

enum DurationAlertAction {
    case allowHours
    case changeHours
}

final class ActivityTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
}

final class AddSliceViewController: UIViewController, AlertsDuration
{
    enum TableSection: Int
    {
        case name = 0
        case duration
        case feelingType
        case goodFeelings
        case badFeelings
        
        static var count = 5
        
        static var feelings: [Int] = [
            feelingType.rawValue,
            goodFeelings.rawValue,
            badFeelings.rawValue
        ]
    }

    fileprivate static let initialRowFeelingsTable: Int = 3
    fileprivate var isPresentingActivities = false
    
    @IBOutlet weak var addSliceButton: UIButton!
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

        self.addSliceButton.layer.cornerRadius = App.Appearance.buttonCornerRadius
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 70
        
        self.view.backgroundColor = UIColor.lightGrayBackground
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
        else
                if (self.newActivity.values.count == 0) {
                    showAlert(message: "Please select values", title: "")
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
        // Will depend on the feeling of the current activity
        
        let fineTuneVC = UIStoryboard(name: "FineTuneActivity", bundle: nil).instantiateInitialViewController() as! FineTuneActivityViewController
        
        fineTuneVC.zUserActivity = userActivity
        
        self.navigationController!.pushViewController(fineTuneVC, animated: true)
    }
    
    @IBAction func fineTuneAction() {
        if (self.validateValues())
        {
            self.fineTune(userActivity: self.newActivity)
        }
    }
    
    @IBAction func addSliceAction(_ sender: Any) {
        
        if (self.validateValues())
        {
            self.saveActivity()
            self.showOptionsAlert()
        }
    }
    
    @IBAction func addAnotherSliceAction() {
        self.saveActivity()
        
        let addStoryboard = UIStoryboard(name: "AddCustom", bundle: nil)
        guard let addActivityVC = addStoryboard.instantiateViewController(withIdentifier: "AddSliceViewController") as? AddSliceViewController
            else{
                return
        }
        
        self.navigationController?.pushViewController(addActivityVC, animated: true)
    }
    
    @IBAction func backToPieAction() {
        
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
            
            return 1
        case TableSection.badFeelings.rawValue:
            
            if (self.newActivity.feeling == .great || self.newActivity.feeling == .none)
            {
                return 0
            }
            
            return 1
        default:
            return 1
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tapToSelectText = "Tap to select"

        switch (TableSection(rawValue: indexPath.section)) {
            
        case (.name?):
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! ActivityTableViewCell
            
            cell.titleLabel.text = "Name of this activity:"
            cell.subtitleLabel.text = self.newActivity.activity?.name ?? tapToSelectText
            cell.selectionStyle = .none
            
            return cell
            
        case (.duration?):
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! ActivityTableViewCell

            cell.titleLabel.text = "Roughly how many hours a week do you spend on this activity?"
            cell.subtitleLabel.text = self.newActivity.duration.userFriendlyText ?? tapToSelectText
            cell.selectionStyle = .none

            return cell
            
        case (.feelingType?):
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! ActivityTableViewCell

            cell.titleLabel.text = "How do you feel when you are engaged in this activity?"
            cell.subtitleLabel.text = self.newActivity.feeling.string ?? tapToSelectText
            cell.selectionStyle = .none
            
            return cell
            
        case (.goodFeelings?):
            let cell = tableView.dequeueReusableCell(withIdentifier: "valuesCell", for: indexPath) as! ActivityTableViewCell
            
            let text = self.newActivity.goodValues.map{$0.name}.joined(separator: ", ")
            
            cell.titleLabel.text = "This activity feels good because of:"
            cell.subtitleLabel.text = text.characters.count > 0 ? text : tapToSelectText
            cell.selectionStyle = .none
            
            return cell
            
        case (.badFeelings?):
            let cell = tableView.dequeueReusableCell(withIdentifier: "valuesCell", for: indexPath) as! ActivityTableViewCell
            let text = self.newActivity.badValues.map{$0.name}.joined(separator: ", ")

            cell.titleLabel.text = "This activity feels lousy because of:"
            cell.subtitleLabel.text = text.characters.count > 0 ? text : tapToSelectText
            cell.selectionStyle = .none
            
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.selectionStyle = .none
            return cell
        }
    }

}

extension AddSliceViewController: UITableViewDelegate, UIViewControllerTransitioningDelegate
{
    
    func selectActivityName() {
        guard let itemSelectionViewController = UIStoryboard(name: "ItemsSelection", bundle: nil).instantiateInitialViewController() as? ItemsSelectionViewController else {
            assertionFailure()
            return
        }
        
        let selectedActivities = Database.shared.user.activities.map { $0.activity }
        let activities: [Activity] = Array(Database.shared.allActivities()).filter { activity in
            return !selectedActivities.contains { $0 == activity }
        }

        itemSelectionViewController.title = "Activities"
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
        
        let picker = ActionSheetMultipleStringPicker(title: "Duration", rows: [hours, minutes], initialSelection: [selectedHour, selectedMinutes], doneBlock: nil, cancel: nil, origin: UIButton())!
        
        picker.toolbarBackgroundColor = UIColor.groupTableViewBackground
        picker.toolbarButtonsColor = UIColor.darkBlueBackground
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        picker.pickerTextAttributes = [NSFontAttributeName: UIFont.muliLight(size: 18.0), NSParagraphStyleAttributeName: style]
        picker.titleTextAttributes = [NSFontAttributeName: UIFont.muliBold(size: 18.0)]
        UIFont.systemFont(ofSize: 8.0)
        picker.onActionSheetDone = { (picker, indexes, values) in
            guard let hour = indexes?[0] as? Int, var minute = indexes?[1] as? Int else {
                assertionFailure()
                return
            }
            
            minute *= 15
            
            let totalTimeMinutes = hour * 60 + minute
            
            if totalTimeMinutes > Database.shared.user.availableMinutesForActivities {
                self.showDurationAlert() { option in
                    switch option {
                    case .allowHours:
                        self.newActivity.duration = totalTimeMinutes
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                    case .changeHours:
                        self.selectDuration()
                    }
                    
                }
            }
            else {
                
                self.newActivity.duration = totalTimeMinutes
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                
            }
        }

        
        picker.show()
        
    }
    
    func selectHowItFeels()
    {
        let feelings = Feeling.all
        let feelingsNames = feelings.map({$0.string})
        
        let initialIndex = feelings.index(of: self.newActivity.feeling) ?? 0
        
        let picker = ActionSheetStringPicker(title: "How do you feel about it?", rows: feelingsNames, initialSelection: initialIndex, doneBlock: nil, cancel: nil, origin: tableView)!
        
        picker.toolbarBackgroundColor = UIColor.groupTableViewBackground
        picker.toolbarButtonsColor = UIColor.darkBlueBackground
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        picker.pickerTextAttributes = [NSFontAttributeName: UIFont.muliLight(size: 18.0), NSParagraphStyleAttributeName : style]
        picker.titleTextAttributes = [NSFontAttributeName: UIFont.muliBold(size: 14.0)]
        
        picker.onActionSheetDone = { (picker, index, name) in
            let feelingSections: [Int] = TableSection.feelings
            
            self.newActivity.feeling = feelings[index]
            self.tableView.reloadSections(IndexSet(feelingSections), with: .fade)
            self.tableView.endUpdates()
            
        }
        
        picker.show()

        
    }
    
    func showOptionsAlert() {
        
        let title = "Added \(self.newActivity.activity!.name) to Your Pie"
        let message = "What would you like to do next?"
        
        let alertController = UIAlertController(title: title , message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Improve This Slice", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.fineTuneAction()
        })
        
        alertController.addAction(UIAlertAction(title: "Add Another Slice", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.addAnotherSliceAction()
        })
        
        alertController.addAction(UIAlertAction(title: "See My Pie", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.backToPieAction()
        })
        
        self.present(alertController, animated: true, completion: nil)

    }
    
    func selectValues(values: [Value], initialIndexes: [Int], completion: @escaping ([Int])->())
    {
        let storyboard = UIStoryboard(name: "ItemsSelection", bundle: nil)
        if let itemsVC = storyboard.instantiateInitialViewController() as? ItemsSelectionViewController
        {
            
            itemsVC.selectedItemsIndexes = Set(initialIndexes)
            
            let valuesNames = values.map { $0.name }
            for valueName in valuesNames
            {
                let itemModel = ItemSelectionViewModel(title: valueName, image:nil)
                itemsVC.items.append(itemModel)
            }
            
            itemsVC.title = "Values"
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
        
        switch TableSection(rawValue: indexPath.section) {
        case .name?:
            self.selectActivityName()
            
        case .duration?:
            self.selectDuration()
            
        case .feelingType?:
            self.selectHowItFeels()
            
        case .goodFeelings?:
            let values = Value.goodValues.sorted { $0.0.order == 1 }
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
            
        case .badFeelings?:
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
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PartialModalTrasition(withType: .dismissing)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PartialModalTrasition(withType: .presenting)
    }
}

