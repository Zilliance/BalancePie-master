//
//  String+Extensions.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 3/10/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import Foundation

extension String {
    
    func toMinutes() -> Minutes {
        guard self.characters.count > 0 else {
            return 0
        }
        let newString = self.components(separatedBy: ":")
        let hours = Int(newString[0])!
        let minutes = Int(newString[1])!
        return hours * 60 + minutes
    }

}
