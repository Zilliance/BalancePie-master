//
//  String+Extensions.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 3/10/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import Foundation

extension String {
    
    var minutes: Minutes {
        let components = self.components(separatedBy: ":")
        
        guard components.count == 2 else {
            assertionFailure()
            return 0
        }
        
        let hours = Int(components[0])!
        let minutes = Int(components[1])!
        
        return hours * 60 + minutes
    }

}
