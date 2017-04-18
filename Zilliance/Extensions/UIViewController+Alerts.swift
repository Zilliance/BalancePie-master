//
//  UIViewController+Alerts.swift
//  Zilliance
//
//  Created by Philip Dow on 4/18/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

// MARK: - Alerts Duration

protocol AlertsDuration {
    func showDurationAlert(completion: ((DurationAlertAction)->())?)
}

extension AlertsDuration where Self: UIViewController {
    func showDurationAlert(completion: ((DurationAlertAction)->())?=nil) {
        let alertController = UIAlertController(title: "More Hours Than Available", message: "You've exceeded the number of hours available in a week. Would you like to change the duration or keep it?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Keep It", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            completion?(.allowHours)
        })
        
        
        alertController.addAction(UIAlertAction(title: "Change Duration", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            completion?(.changeHours)
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
}
