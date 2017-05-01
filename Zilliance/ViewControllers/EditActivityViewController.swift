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
            
            if (self.activity.feeling == .lousy || self.activity.feeling == .neutral)
            {
                return 0
            }
            
            return max(self.activity.goodValues.count, 1)
        case TableSection.badFeelings.rawValue:
            
            if (self.activity.feeling == .great)
            {
                return 0
            }
            
            return max(self.activity.badValues.count, 1)
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (TableSection(rawValue: indexPath.section), indexPath.row) {
        
        case (.duration?, _):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "activitySubtitleCell", for: indexPath) as! ActivityTableViewCell
            cell.titleLabel.text = "About how many hours a week do you spend on this activity now?"
            cell.subtitleLabel.text = self.activity.duration.userFriendlyText
            cell.selectionStyle = .none
            return cell
            
        case (.feelingType?, _):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "activitySubtitleCell", for: indexPath) as! ActivityTableViewCell
            cell.titleLabel.text = "How do you feel when you are engaged in this activity now?"
            cell.subtitleLabel.text = self.activity.feeling.string
            cell.selectionStyle = .none
            return cell

        case (.goodFeelings?, 0):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "activitySubtitleCell", for: indexPath) as! ActivityTableViewCell
            cell.titleLabel.text = "This activity feels good because of:"
            if (self.activity.goodValues.count == 0) {
                cell.subtitleLabel.text = ""
            } else {
                cell.subtitleLabel.text = self.activity.goodValues[indexPath.row].name
            }
            cell.selectionStyle = .none
            return cell

        case (.badFeelings?, 0):

            let cell = tableView.dequeueReusableCell(withIdentifier: "activitySubtitleCell", for: indexPath) as! ActivityTableViewCell
            cell.titleLabel.text = "This activity feels lousy because of:"
            if (self.activity.badValues.count == 0) {
                cell.subtitleLabel.text = ""
            } else {
                cell.subtitleLabel.text = self.activity.badValues[indexPath.row].name
            }
            cell.selectionStyle = .none
            return cell
            
        case (.goodFeelings?, _):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell")!
            cell.textLabel?.text = self.activity.goodValues[indexPath.row].name
            cell.selectionStyle = .none
            return cell

        case (.badFeelings?, _):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell")!
            cell.textLabel?.text = self.activity.badValues[indexPath.row].name
            cell.selectionStyle = .none
            return cell

        default:
            assertionFailure()
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell")!
            cell.selectionStyle = .none
            return cell
        }
    }
    
}


extension EditActivityViewController: UITableViewDelegate, UIViewControllerTransitioningDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // return 100
        switch indexPath.section {
        case (0..<4):
            return 100
        default:
            return 34
        }
    }
    
    func selectDuration()
    {
        let hours = 80.labeledArray(with: "Hour")
        let minutes = ["0 Minutes", "15 Minutes", "30 Minutes", "45 Minutes"]
        let selectedDuration = self.activity.duration
        let selectedHour = selectedDuration.asHoursMinutes.0
        let selectedMinutes = selectedDuration.asHoursMinutes.1 / 15
        
        let picker = ActionSheetMultipleStringPicker(title: "Duration", rows: [hours, minutes], initialSelection: [selectedHour, selectedMinutes], doneBlock: nil, cancel: nil, origin: UIButton())!
        
        picker.toolbarBackgroundColor = UIColor.lightGray
        picker.toolbarButtonsColor = UIColor.black
        picker.pickerTextAttributes = [NSFontAttributeName: UIFont.muliLight(size: 18.0)]
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
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                    case .changeHours:
                        self.selectDuration()
                    }
                    
                }
            }
            else {
                
                self.activity.duration = totalTimeMinutes
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                
            }
        }
        
        
        picker.show()
    }
    
    func selectHowItFeels() {
        let feelings = Feeling.all
        let feelingsNames = feelings.map({$0.string})
        
        let initialIndex = feelings.index(of: self.activity.feeling) ?? 0
        
        ActionSheetStringPicker.show(withTitle: "How do you feel about it ?", rows: feelingsNames, initialSelection: initialIndex, doneBlock: { (picker, index, name) in
            let feelingSections: [Int] = TableSection.feelings
            
            self.activity.feeling = feelings[index]
            self.tableView.reloadSections(IndexSet(feelingSections), with: .fade)
            self.tableView.endUpdates()
            
        }, cancel: { (picker) in
            
        }, origin: tableView)
    }
    
    func selectValues(values: [Value], initialIndexes: [Int], completion: @escaping ([Int])->()) {
        if let itemsVC = UIStoryboard(name: "ItemsSelection", bundle: nil).instantiateInitialViewController() as? ItemsSelectionViewController {
            
            itemsVC.selectedItemsIndexes = Set(initialIndexes)
            
            let valuesNames = values.map({$0.name})
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
            
            let navigation = UINavigationController(rootViewController: itemsVC)
            navigation.transitioningDelegate = self
            navigation.modalPresentationStyle = .custom
            
            self.present(navigation, animated: true, completion: nil)
            
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
            let values = Value.goodValues
            let selectedValues = values.flatMap({self.activity.goodValues.index(of: $0) == nil ? nil : values.index(of: $0)})
            
            self.selectValues(values: values, initialIndexes: selectedValues, completion: { (indexes) in
                self.activity.removeGoodValues()
                
                for index in indexes
                {
                    let value = values[index]
                    self.activity.values.append(value)
                }
                
                self.tableView.reloadSections(IndexSet([TableSection.goodFeelings.rawValue]), with: .fade)
            })

        case .badFeelings?:
            let values = Value.badValues
            let selectedValues = values.flatMap({self.activity.badValues.index(of: $0) == nil ? nil : values.index(of: $0)})
            
            self.selectValues(values: values, initialIndexes: selectedValues, completion: { (indexes) in
                self.activity.removeBadValues()
                
                for index in indexes
                {
                    let value = values[index]
                    self.activity.values.append(value)
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
