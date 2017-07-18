//
//  CustomDatePickerViewController.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 7/13/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

class CustomDatePickerViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    var date: ((Date) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datePicker.datePickerMode = .time
    }

    @IBAction func cancelAction(_ sender: Any) {
        self.mz_dismissFormSheetController(animated: true, completionHandler: nil)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        self.date?(self.datePicker.date)
        self.mz_dismissFormSheetController(animated: true, completionHandler: nil)
    }
}
