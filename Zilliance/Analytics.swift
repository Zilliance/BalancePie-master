//
//  Analytics.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 10/17/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import Foundation
import Fabric
import Answers
import Amplitude_iOS
import ZillianceShared

final class Analytics: AnalyticsService {
    
    static let shared = Analytics()
    
    func initialize() {
        
        //Fabric
        Fabric.with([Answers.self])
        
        //Amplitude
        Amplitude.instance().initializeApiKey("73314cf65e614adhb6504fd607d91c30")
        
        ZillianceAnalytics.initialize(projectName: "Balance.Pie.", analyticsService: self)
        
    }
    
    func send(event: AnalyticEvent) {
        
        Answers.logCustomEvent(withName: event.name, customAttributes: event.data)
        
        Amplitude.instance().logEvent(event.name, withEventProperties: event.data)
        
    }
    
}
