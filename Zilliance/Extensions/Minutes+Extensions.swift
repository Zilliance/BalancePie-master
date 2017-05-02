//
//  Minutes+Extensions.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 2/20/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import Foundation

extension Minutes {
    
    var asHoursMinutes: (Int, Int) {
        return (self/60, self % 60)
    }
    
    var timeText: String {
        return self < 10 ? "0\(self)" : "\(self)"
    }
    
    /// Returns the HH:MM String
    var hhmmText: String {
        return "\(self.asHoursMinutes.0.timeText):\(self.asHoursMinutes.1.timeText)"
    }
    
    var userFriendlyText: String? {
        
        guard self > 0 else {
            return nil
        }
        
        var hourText = ""
        var minText = ""
        if self >= 60 {
            hourText =  self.asHoursMinutes.0 == 1 ? "\(self.asHoursMinutes.0) hour" : "\(self.asHoursMinutes.0) hours"
        }
        
        if self.asHoursMinutes.1 != 0 {
            minText = self.asHoursMinutes.1 == 1 ? "\(self.asHoursMinutes.1) min" : "\(self.asHoursMinutes.1) mins"
        }
        
        return hourText + " \(minText)"
    }
}
