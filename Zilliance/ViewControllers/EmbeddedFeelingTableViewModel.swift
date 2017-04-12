//
//  EmbeddedFeelingTableViewModel.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 12-04-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import Foundation

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
            return
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
