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

final class EditActivityViewController: UIViewController{
    
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
        
        var cell: UITableViewCell!
        switch (TableSection(rawValue: indexPath.section), indexPath.row) {
        case (.duration?, _):
            
            cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell")!
            cell.textLabel?.text = "About how long now?"
            cell.detailTextLabel?.text = self.activity.duration.userFriendlyText
            
        case (.feelingType?, _):
            
            cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell")!
            cell.textLabel?.text = "How do you feel now?"
            cell.detailTextLabel?.text = self.activity.feeling.string

        case (.goodFeelings?, 0):
            
            cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell")!
            cell.textLabel?.text = "Feels good because"
            if (self.activity.goodValues.count == 0)
            {
                cell.detailTextLabel?.text = ""
                break
            }
            cell.detailTextLabel?.text = self.activity.goodValues[indexPath.row].name

        case (.badFeelings?, 0):

            cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell")!
            cell.textLabel?.text = "Feels bad because"
            if (self.activity.badValues.count == 0)
            {
                cell.detailTextLabel?.text = ""
                break
            }
            cell.detailTextLabel?.text = self.activity.badValues[indexPath.row].name
            
        case (.goodFeelings?, _):
            
            cell = tableView.dequeueReusableCell(withIdentifier: "basicCell")!
            cell.textLabel?.text = self.activity.goodValues[indexPath.row].name

        case (.badFeelings?, _):
            
            cell = tableView.dequeueReusableCell(withIdentifier: "basicCell")!
            cell.textLabel?.text = self.activity.badValues[indexPath.row].name

        default:
            assertionFailure()
            break
        }
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
}


extension EditActivityViewController: UITableViewDelegate, UIViewControllerTransitioningDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 64 : 44
    }
    
    func selectDuration()
    {
        let hours = 80.labeledArray(with: "Hour")
        let minutes = ["0 Minutes", "15 Minutes", "30 Minutes", "45 Minutes"]
        let selectedDuration = self.activity.duration
        let selectedHour = selectedDuration.asHoursMinutes.0
        let selectedMinutes = selectedDuration.asHoursMinutes.1 / 15
        
        ActionSheetMultipleStringPicker.show(withTitle: "Duration", rows: [hours, minutes], initialSelection: [selectedHour, selectedMinutes], doneBlock: { (picker, indexes, values) in
            
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
            
        }, cancel: { (picker) in
            
        }, origin: UIButton())
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
    
}
