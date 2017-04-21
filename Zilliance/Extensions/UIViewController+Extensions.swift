//
//  UIViewController+Extensions.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 3/1/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // TODO: title should be first and message second
    
    func showAlert(message: String, title: String?, completion: (()->Void)?=nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            completion?()
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
}
