//
//  Analytics+BalancePie.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 10/17/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import Foundation
import ZillianceShared

class BalancePieAnalytics: ZillianceAnalytics {
    
    enum BalancePieEvent: String, AnalyticEvent {
        
        // onboarding
        case enterTour
        case favoriteActivitySelected
        
        // slices
        
        case didAddSlice
        case didEditSlice
        case didDeleteSlice
        
    }
    
}
