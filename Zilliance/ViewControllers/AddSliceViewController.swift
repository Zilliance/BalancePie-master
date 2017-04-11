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

struct EmbeddedFeelingTableViewModel
{
    var initialSection = 0
    var userActivity: UserActivity
    
    //return the sections that are part of this table
    func sections() -> [Int]
    {
        switch self.userActivity.feeling {
        case .mixed:
            return [self.initialSection, self.initialSection + 1]
        default:
            return [self.initialSection]
        }
    }
    
    func rows() -> [IndexPath]
    {
        var rows: [IndexPath] = []
        for section in self.sections()
        {
            for row in 0..<self.numberOfRows(section: section)
            {
                rows.append(IndexPath(row: row, section: section))
            }
        }
        return rows
    }
    
    func insideOfTable(section: Int) -> Bool
    {
        return section >= self.initialSection && section < self.sections().count + self.initialSection
    }
    
    func numberOfSections() -> Int
    {
        return self.sections().count
    }
    
    func numberOfRows(section: Int) -> Int
    {
        if (self.userActivity.feeling == .none)
        {
            return 1
        }

        let internalSection = self.initialSection - section
        switch (internalSection, self.userActivity.feeling) {
        case (0, .great), (0, .mixed):
            return max(self.userActivity.goodValues.count, 1)
        default:
            return max(self.userActivity.badValues.count, 1)
        }
    }
    
    func titleForIndexPath(index : IndexPath) -> String
    {
        if (self.userActivity.feeling == .none)
        {
            return ""
        }
        
        let internalSection = self.initialSection - index.section
        switch (internalSection, self.userActivity.feeling) {
        case (0, .great), (0, .mixed):
            let goodValues = self.userActivity.goodValues
            return goodValues.count > 0 ? self.userActivity.goodValues[index.row].name : "Tap to select"
        default:
            let badValues = self.userActivity.badValues
            return badValues.count > 0 ? self.userActivity.badValues[index.row].name : "Tap to select"
        }
    }
    
    func availableValuesForSection(section: Int) -> [Value]
    {
        if (self.userActivity.feeling == .none)
        {
            return []
        }
        
        let internalSection = self.initialSection - section
        switch (internalSection, self.userActivity.feeling) {
        case (0, .great), (0, .mixed):
            return Value.goodValues
        default:
            return Value.badValues
        }
    }
    
    func selectedValuesIndexes(section: Int) -> [Int]
    {
        if (self.userActivity.feeling == .none)
        {
            return []
        }
        
        let values = availableValuesForSection(section: section)
        
        let internalSection = self.initialSection - section
        switch (internalSection, self.userActivity.feeling) {
        case (0, .great), (0, .mixed):
            let selection = values.flatMap({self.userActivity.goodValues.index(of: $0) == nil ? nil : values.index(of: $0)})
            return selection
        default:
            let selection = values.flatMap({self.userActivity.badValues.index(of: $0) == nil ? nil : values.index(of: $0)})
            return selection
        }
    }
    
    func deleteValuesForSection(section: Int)
    {
        if (self.userActivity.feeling == .none)
        {
        }
        
        let values = availableValuesForSection(section: section)
        
        values.forEach
        {
            if let index = self.userActivity.values.index(of: $0)
            {
                self.userActivity.values.remove(objectAtIndex: index)
            }
        }
    
    }
    
    func titleForSection(section: Int) -> String?
    {
        switch self.userActivity.feeling {
        case .none:
            return nil
        case .great:
            return "Feels good because"
        case .lousy:
            return "Feels bad because"
        case .mixed:
            if (section - initialSection == 0)
            {
                return "Good values"
            }
            else
            {
                return "Bad values"
            }
        case .neutral:
            return "Feels neutral because"
        }
        
    }
    
}

final class AddSliceViewController: UIViewController
{
    
    fileprivate static let initialRowFeelingsTable: Int = 3
    
    @IBOutlet fileprivate weak var tableView: UITableView!

    var newActivity = UserActivity()

    fileprivate var feelingInternalTableModel: EmbeddedFeelingTableViewModel!
    
    fileprivate weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feelingInternalTableModel = EmbeddedFeelingTableViewModel(initialSection: AddSliceViewController.initialRowFeelingsTable, userActivity: newActivity)
        
        self.selectActivityName()
        
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        //save activity
        
        self.saveActivity()
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func saveActivity()
    {
        Database.shared.user.add(userActivity: self.newActivity)
    }
    
}

extension AddSliceViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 + self.feelingInternalTableModel.numberOfSections()
    } 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.feelingInternalTableModel.insideOfTable(section: section))
        {
            return self.feelingInternalTableModel.numberOfRows(section: section)
        }
        
        return 1

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleCell")!
        var title = ""
        
        if (self.feelingInternalTableModel.insideOfTable(section: indexPath.section))
        {
            title = self.feelingInternalTableModel.titleForIndexPath(index: indexPath)
            cell.textLabel?.text = title
            
            return cell

        }
        
        else
        {
            title = ""
            switch indexPath.section {
            case 0:
                if let activity = self.newActivity.activity
                {
                    title = activity.name
                }
                
            case 1:
                title = self.newActivity.duration.userFriendlyText

            case 2:
                title = self.newActivity.feeling.string()

            default:
                break
            }
        }
        
        cell.textLabel?.text = title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        if (self.feelingInternalTableModel.insideOfTable(section: section))
        {
            return self.feelingInternalTableModel.titleForSection(section: section) ?? ""
        }
        
        switch section {
        case 0:
            return "Name of this activity"
        case 1:
            return "About how long"
        case 2:
            return "How do you feel"
        default:
            break
        }
        
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (self.feelingInternalTableModel.insideOfTable(section: section))
        {
            let title = self.feelingInternalTableModel.titleForSection(section: section)
            
            if (title == nil)
            {
                return 0
            }
        }
        return 44
    }
    
}

extension AddSliceViewController: UITableViewDelegate, UIViewControllerTransitioningDelegate
{
    
    func selectActivityName()
    {
        let activities = Database.shared.allActivities()
        let activitiesNames: [String] = activities.map { $0.name }
        
        var initialIndex = 0
        
        if (self.newActivity.activity != nil)
        {
            initialIndex = activitiesNames.index(of: self.newActivity.activity.name)!
        }
        
        ActionSheetStringPicker.show(withTitle: "Activity", rows: activitiesNames, initialSelection: initialIndex, doneBlock: { (picker, index, name) in
            
            self.newActivity.activity = activities[index]
            
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            
            self.selectDuration()
            
        }, cancel: { (picker) in
            return
        }, origin: tableView)
    
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
            
            self.selectHowItFeels()
            
        }, cancel: { (picker) in
            
        }, origin: UIButton())
    }
    
    func selectHowItFeels()
    {
        let feelings = Feeling.allFeelings
        let feelingsNames = feelings.map({$0.string()})
        
        let initialIndex = feelings.index(of: self.newActivity.feeling) ?? 0
        
        ActionSheetStringPicker.show(withTitle: "How do you feel about it ?", rows: feelingsNames, initialSelection: initialIndex, doneBlock: { (picker, index, name) in
            
            
            self.tableView.beginUpdates()
            
            
            self.tableView.deleteSections(IndexSet(self.feelingInternalTableModel.sections()), with: .fade)
            //self.tableView.deleteRows(at: self.feelingInternalTableModel.rows(), with: .fade)
            
            self.newActivity.feeling = feelings[index]
            
            self.tableView.insertSections(IndexSet(self.feelingInternalTableModel.sections()), with: .fade)
            
            //self.tableView.insertRows(at: self.feelingInternalTableModel.rows(), with: .fade)
            
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .fade)
            
            self.tableView.endUpdates()
            
            self.selectValues(forSection: AddSliceViewController.initialRowFeelingsTable)
            
            return
        }, cancel: { (picker) in
            return
        }, origin: tableView)
    }
    
    func selectValues(forSection section: Int)
    {
        let values = self.feelingInternalTableModel.availableValuesForSection(section: section)
        let initialIndexes = self.feelingInternalTableModel.selectedValuesIndexes(section: section)
        
        let storyboard = UIStoryboard(name: "ItemsSelection", bundle: nil)
        if let itemsVC = storyboard.instantiateInitialViewController() as? ItemsSelectionViewController
        {
            //itemsVC.modalPresentationStyle = .custom
            //itemsVC.transitioningDelegate = self
            
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
            
            itemsVC.title = self.feelingInternalTableModel.titleForSection(section: section)
            
            itemsVC.doneAction = { indexes in
                
                self.feelingInternalTableModel.deleteValuesForSection(section: section)
                
                for index in indexes
                {
                    let value = values[index]
                    self.newActivity.values.append(value)
                }
                
                self.tableView.reloadSections(IndexSet([section]), with: .fade)
                
                let nextSection = section + 1
                if (self.feelingInternalTableModel.insideOfTable(section: nextSection))
                {
                    self.selectValues(forSection: nextSection)
                }
                else
                {
                    let lastSection = self.tableView.numberOfSections - 1
                    let lastRowIndex = IndexPath(row: self.tableView.numberOfRows(inSection: lastSection) - 1, section: lastSection)
                    self.tableView.scrollToRow(at: lastRowIndex, at: .bottom, animated: true)
                }
                
            }

            let navigation = UINavigationController(rootViewController: itemsVC)
            navigation.transitioningDelegate = self
            navigation.modalPresentationStyle = .custom
            
            self.present(navigation, animated: true, completion: nil)

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //activity name
        if (indexPath.section == 0)
        {
            self.selectActivityName()
        }
        
        if (indexPath.section == 1)
        {
            self.selectDuration()
        }
        
        if (indexPath.section == 2)
        {
            self.selectHowItFeels()
        }
        
        if (self.feelingInternalTableModel.insideOfTable(section: indexPath.section))
        {
            self.selectValues(forSection: indexPath.section)
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

