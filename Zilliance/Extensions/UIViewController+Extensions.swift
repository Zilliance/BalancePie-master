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
    
    func showActionSheet(withMessages messages:[String], title: String, completion: ((Int) -> ())?=nil) {
        let actionController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        for i in 0 ..< messages.count {
            let style: UIAlertActionStyle = (i == messages.count-1) ? .destructive : .default
            actionController.addAction(UIAlertAction(title: messages[i], style: style) { _ in
                actionController.dismiss(animated: true, completion: nil)
                completion?(i)
            })
        }
        
        actionController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            actionController.dismiss(animated: true, completion: nil)
        })
        
        self.present(actionController, animated: true, completion: nil)
    }
}
