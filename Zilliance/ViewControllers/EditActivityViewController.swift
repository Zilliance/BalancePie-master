//
//  EditActivityViewController.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 13-04-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import Foundation
import UIKit
import ActionSheetPicker_3_0

final class EditActivityViewController: UIViewController, AlertsDuration {
    
    enum TableSection: Int
    {
        case duration = 0
        case feelingType
        case goodFeelings
        case badFeelings
        
        static var count = 4
        
        static var feelings : [Int] = [
            feelingType.rawValue,
            goodFeelings.rawValue,
            badFeelings.rawValue
        ]
    }
    
    @IBOutlet weak var updateSliceButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    var activity: UserActivity! {
        didSet{
            self.activity = activity.detached()
            self.title = self.activity.activity?.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 70
        
        self.view.backgroundColor = UIColor.lightGrayBackground

    }
    
    private func setupViews() {
        self.updateSliceButton.layer.cornerRadius = App.Appearance.buttonCornerRadius
    }
    
    // MARK: -- User Actions
    
    @IBAction func updateTapped(){
        Database.shared.user.save(userActivity: self.activity)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension EditActivityViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case TableSection.goodFeelings.rawValue:
            
            if (self.activity.feeling == .lousy || self.activity.feeling == .good)
            {
                return 0
            }
            
            return 1
        case TableSection.badFeelings.rawValue:
            
            if (self.activity.feeling == .great)
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
            
        case (.duration?):
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! ActivityTableViewCell
            
            cell.titleLabel.text = "Roughly how many hours a week do you spend on this activity?"
            cell.subtitleLabel.text = self.activity.duration.userFriendlyText ?? tapToSelectText
            cell.subtitleLabel.textColor = self.activity.duration.userFriendlyText != nil ? UIColor.lightBlueBackground : UIColor.placeholderText
            cell.selectionStyle = .none
            
            return cell
            
        case (.feelingType?):
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! ActivityTableViewCell
            
            cell.titleLabel.text = "How do you feel when you are engaged in this activity?"
            cell.subtitleLabel.text = self.activity.feeling.string ?? tapToSelectText
            cell.subtitleLabel.textColor = self.activity.feeling.string != nil ? UIColor.lightBlueBackground : UIColor.placeholderText
            cell.selectionStyle = .none
            
            return cell
            
        case (.goodFeelings?):
            let cell = tableView.dequeueReusableCell(withIdentifier: "valuesCell", for: indexPath) as! ActivityTableViewCell
            
            let text = self.activity.goodValues.map{$0.name}.joined(separator: "\n")
            
            cell.titleLabel.text = self.activity.feeling.goodTitleText
            cell.subtitleLabel.text = text.characters.count > 0 ? text : tapToSelectText
            cell.subtitleLabel.textColor = text.characters.count > 0 ? UIColor.lightBlueBackground : UIColor.placeholderText
            cell.selectionStyle = .none
            
            return cell
            
        case (.badFeelings?):
            let cell = tableView.dequeueReusableCell(withIdentifier: "valuesCell", for: indexPath) as! ActivityTableViewCell
            let text = self.activity.feeling == .good ? self.activity.goodValues.map{$0.name}.joined(separator: "\n") : self.activity.badValues.map{$0.name}.joined(separator: "\n")
            cell.titleLabel.text = self.activity.feeling.badTitleText
            cell.subtitleLabel.text = text.characters.count > 0 ? text : tapToSelectText
            cell.subtitleLabel.textColor = text.characters.count > 0 ? UIColor.lightBlueBackground : UIColor.placeholderText
            cell.selectionStyle = .none
            
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.selectionStyle = .none
            return cell
        }

    }
    
}


extension EditActivityViewController: UITableViewDelegate, UIViewControllerTransitioningDelegate
{
    
    fileprivate func scrollToLastRow() {
        
        var lastSectionShown = TableSection.feelingType.rawValue
        
        if (self.activity.feeling == .lousy || self.activity.feeling == .good || self.activity.feeling == .mixed)
        {
            lastSectionShown = TableSection.badFeelings.rawValue
        }
        else
        {
            lastSectionShown = TableSection.goodFeelings.rawValue
        }
        
        let lastRow = IndexPath(row: 0, section: lastSectionShown)
        
        self.tableView.scrollToRow(at: lastRow, at: .bottom, animated: true)
    }
    
    func selectDuration()
    {
        let hours = 80.labeledArray(with: "Hour")
        let minutes = ["0 Minutes", "15 Minutes", "30 Minutes", "45 Minutes"]
        let selectedDuration = self.activity.duration
        let selectedHour = selectedDuration.asHoursMinutes.0
        let selectedMinutes = selectedDuration.asHoursMinutes.1 / 15
        
        let picker = ActionSheetMultipleStringPicker(title: "Duration", rows: [hours, minutes], initialSelection: [selectedHour, selectedMinutes], doneBlock: nil, cancel: nil, origin: UIButton())!
        
        picker.toolbarBackgroundColor = UIColor.groupTableViewBackground
        picker.toolbarButtonsColor = UIColor.darkBlueBackground
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        picker.pickerTextAttributes = [NSFontAttributeName: UIFont.muliLight(size: 18.0), NSParagraphStyleAttributeName: style]
        picker.titleTextAttributes = [NSFontAttributeName: UIFont.muliBold(size: 18.0)]
        
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
                        self.activity.duration = totalTimeMinutes
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                    case .changeHours:
                        self.selectDuration()
                    }
                    
                }
            }
            else {
                
                self.activity.duration = totalTimeMinutes
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                
            }
        }
        
        
        picker.show()
    }
    
    func selectHowItFeels() {
        let feelings = Feeling.all
        let feelingsNames = feelings.map({$0.string})
        
        let initialIndex = feelings.index(of: self.activity.feeling) ?? 0
        
        let picker = ActionSheetStringPicker(title: "How do you feel about it?", rows: feelingsNames, initialSelection: initialIndex, doneBlock: nil, cancel: nil, origin: tableView)!
        
        picker.toolbarBackgroundColor = UIColor.groupTableViewBackground
        picker.toolbarButtonsColor = UIColor.darkBlueBackground
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        picker.pickerTextAttributes = [NSFontAttributeName: UIFont.muliLight(size: 18.0), NSParagraphStyleAttributeName : style]
        picker.titleTextAttributes = [NSFontAttributeName: UIFont.muliBold(size: 14.0)]
        
        picker.onActionSheetDone = { (picker, index, name) in
            let feelingSections: [Int] = TableSection.feelings
            
            self.activity.feeling = feelings[index]
            self.tableView.reloadSections(IndexSet(feelingSections), with: .fade)
            self.scrollToLastRow()
            
        }
        
        picker.show()
        
    }
    
    func selectValues(valueType: ValueType, initialIndexes: [Int], completion: @escaping ([Value])->())
    {
        
        var values: [Value] = []
        
        switch valueType {
        case .great:
            values = Value.greatValues
        case .bad:
            values = Value.badValues
        case .good:
            values = Value.goodValues
        }
        
        let initialSelectedValues = initialIndexes.map{values[$0]}
        
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
            itemsVC.createItemTitle = "Create my own value"
            
            
            itemsVC.doneAction = { indexes in
                
                var selectedValues:[Value] = []
                for index in indexes
                {
                    let value = values[index]
                    selectedValues.append(value)
                }
                
                completion(selectedValues)
            }
            
            itemsVC.createNewItemAction = {
                
                itemsVC.dismiss(animated: true, completion: {
                    guard let customValueViewController = UIStoryboard(name: "AddCustom", bundle: nil).instantiateViewController(withIdentifier: "AddValuesViewController") as? AddValuesViewController else {
                        assertionFailure()
                        return
                    }
                    
                    customValueViewController.valueType = valueType
                    
                    let navigation = UINavigationController(rootViewController: customValueViewController)
                    self.present(navigation, animated: true, completion: nil)
                    
                    customValueViewController.dismissAction = { value in
                        //need to go back to the values selection
                        
                        var values: [Value] = []
                        
                        switch valueType {
                        case .great:
                            values = Value.greatValues
                        case .bad:
                            values = Value.badValues
                        case .good:
                            values = Value.goodValues
                        }
                        
                        var initialIndexes = values.flatMap({initialSelectedValues.index(of: $0) == nil ? nil : values.index(of: $0)})

                        if let value = value, let indexOfValue = values.index(of: value) {
                            initialIndexes.append(indexOfValue)
                        }
                        
                        self.selectValues(valueType: valueType, initialIndexes: initialIndexes, completion: completion)
                    }
                    
                })
                
            }
            
            let navigation = UINavigationController(rootViewController: itemsVC)
            navigation.transitioningDelegate = self
            navigation.modalPresentationStyle = .custom
            
            DispatchQueue.main.async {
                self.present(navigation, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //activity name
        
        switch TableSection(rawValue: indexPath.section) {
        case .duration?:
            self.selectDuration()

        case .feelingType?:
            self.selectHowItFeels()

        case .goodFeelings?:
            
            let values = Value.greatValues
            
            let initialIndexes = values.flatMap({self.activity.goodValues.index(of: $0) == nil ? nil : values.index(of: $0)})
            
            self.selectValues(valueType: .great, initialIndexes: initialIndexes, completion: { (values) in
                self.activity.removeGreatValues()
                
                for value in values
                {
                    self.activity.values.append(value)
                }
                
                self.tableView.reloadSections(IndexSet([TableSection.goodFeelings.rawValue]), with: .fade)
                self.scrollToLastRow()
                
            })
            
        case .badFeelings?:
            
            
            let values = self.activity.feeling == .good ? Value.goodValues: Value.badValues
            
            let initialIndexes = self.activity.feeling == .good ? values.flatMap({self.activity.goodValues.index(of: $0) == nil ? nil : values.index(of: $0)}) : values.flatMap({self.activity.badValues.index(of: $0) == nil ? nil : values.index(of: $0)})
            let valueType: ValueType = self.activity.feeling == .good ? ValueType.good : ValueType.bad

            self.selectValues(valueType: valueType, initialIndexes: initialIndexes, completion: { (values) in
                
                if self.activity.feeling == .good {
                    self.activity.removeGoodValues()
                } else {
                    self.activity.removeBadValues()
                }
                
                for value in values
                {
                    self.activity.values.append(value)
                }
                
                self.tableView.reloadSections(IndexSet([TableSection.badFeelings.rawValue]), with: .fade)
                self.scrollToLastRow()
                
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
