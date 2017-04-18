//
//  UIViewController+Extensions.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 3/1/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(message: String, title: String?, completion: (()->Void)?=nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            completion?()
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showDurationAlert(completion: ((DurationAlertAction)->())?=nil) {
        let alertController = UIAlertController(title: "More Hours Than Available", message: "You've exceeded the number of hours available in a week. Would you like to change the duration or keep it", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Allow Anyway", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            completion?(.allowHours)
        })
        
        
        alertController.addAction(UIAlertAction(title: "Change Hours", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            completion?(.changeHours)
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}
