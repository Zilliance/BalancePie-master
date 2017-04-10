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

enum FeelingTableViewModelType
{
    case none
    case good([Value])
    case bad([Value])
    case mixed(([Value],[Value]))
    
    func numberOfSections() -> Int
    {
        switch self {
        case .mixed(_):
            return 2
        default:
            return 1
        }
    }
    
    func numberOfItems(section: Int = 0) -> Int
    {
        switch self {
        case .none:
            return 0
        case .good(let values):
            return values.count
        case .bad(let values):
            return values.count
        case .mixed(let mixedModel):
            if (section == 0)
            {
                return mixedModel.0.count
            }
            else
            {
                return mixedModel.1.count
            }
        }
    }
    
    func titleForItem(item: Int, section: Int = 0) -> String
    {
        switch self {
        case .none:
            return ""
        case .good(let values):
            return values[item].name
        case .bad(let values):
            return values[item].name
        case .mixed(let goodValues, let badValues):
            if (section == 0)
            {
                return goodValues[item].name
            }
            else
            {
                return badValues[item].name
            }
        }
    }
    
}

func ==(lhs: FeelingTableViewModelType, rhs: FeelingTableViewModelType) -> Bool {
    switch (lhs, rhs) {
    case ( .good(_), .good(_)):
        return true
        
    case ( .bad(_),  .bad(_)):
        return true
        
    case ( .mixed(_),  .mixed(_)):
        return true

    case ( .none,  .none):
        return true
        
    default:
        return false
    }
}


struct EmbeddedFeelingTableViewModel
{
    var initialSection = 0
    var feelingTypeTable = FeelingTableViewModelType.none
    
    //return the sections that are part of this table
    func sections() -> [Int]
    {
        switch self.feelingTypeTable {
        case .mixed(_):
            return [self.initialSection, self.initialSection + 1]
        default:
            return [self.initialSection]
        }
    }
    
    func insideOfTable(section: Int) -> Bool
    {
        return section >= self.initialSection && section < self.feelingTypeTable.numberOfSections() + self.initialSection
    }
    
    func numberOfSections() -> Int
    {
        return self.feelingTypeTable.numberOfSections()
    }
    
    func numberOfRows(section: Int) -> Int
    {
        return self.feelingTypeTable.numberOfItems(section:section - self.initialSection)
    }
    
    func titleForIndexPath(index : IndexPath) -> String
    {
        return self.feelingTypeTable.titleForItem(item: index.row, section: index.section - self.initialSection)
    }
    
    func titleForSection(section: Int) -> String?
    {
        switch self.feelingTypeTable {
        case .none:
            return nil
        case .good(_):
            return "Feels good because"
        case .bad(_):
            return "Feels bad because"
        case .mixed(_):
            if (section == 0)
            {
                return "Good values"
            }
            else
            {
                return "Bad values"
            }
        }
    }
    
}

final class AddSliceViewController: UIViewController
{
    
    fileprivate static let rowStartOfFeelingsTable: Int = 3
    
    @IBOutlet fileprivate weak var tableView: UITableView!

    var newActivity = UserActivity()

    fileprivate var feelingInternalTableModel = EmbeddedFeelingTableViewModel(initialSection: AddSliceViewController.rowStartOfFeelingsTable, feelingTypeTable: .none)
    
    fileprivate weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

extension AddSliceViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //activity name
        if (indexPath.section == 0)
        {
            let activities = Database.shared.allActivities()
            let activitiesNames: [String] = activities.map { $0.name }
            
            var initialIndex = 0
            
            if (self.newActivity.activity != nil)
            {
                initialIndex = activitiesNames.index(of: self.newActivity.activity.name)!
            }
            
            ActionSheetStringPicker.show(withTitle: "Activities", rows: activitiesNames, initialSelection: initialIndex, doneBlock: { (picker, index, name) in
                
                self.newActivity.activity = activities[index]
                
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                
                return
            }, cancel: { (picker) in
                return
            }, origin: tableView)
        }
        
        if (indexPath.section == 2)
        {
            let feelings = Feeling.allFeelings
            let feelingsNames = feelings.map({$0.string()})
            
            let initialIndex = feelings.index(of: self.newActivity.feeling) ?? 0
            
            ActionSheetStringPicker.show(withTitle: "Activities", rows: feelingsNames, initialSelection: initialIndex, doneBlock: { (picker, index, name) in
                
                self.newActivity.feeling = feelings[index]
                
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .fade)
                
                //modify internal table model
                switch self.newActivity.feeling
                {
                case .great:
                    self.feelingInternalTableModel.feelingTypeTable = .good([])
                case .lousy:
                    self.feelingInternalTableModel.feelingTypeTable = .bad([])
                case .mixed:
                    self.feelingInternalTableModel.feelingTypeTable = .mixed(([], []))
                case .neutral:
                    self.feelingInternalTableModel.feelingTypeTable = .good([])
                }
                
                let indices = IndexSet(self.feelingInternalTableModel.sections())
                
                self.tableView.reloadSections(indices, with: .fade)
                
                return
            }, cancel: { (picker) in
                return
            }, origin: tableView)
        }
        
    }

    
    
}

