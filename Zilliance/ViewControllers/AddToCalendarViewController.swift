//
//  AddToCalendarViewController.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 3/22/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import UIKit
import SVProgressHUD
import MZFormSheetController

struct TextViewContent {
    let userActivity: UserActivity
    let type: FineTuneType
}

class AddToCalendarViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    private var zillianceTextViewController: ZillianceTextViewController!
    
    var textViewContent: TextViewContent?

    fileprivate var pickerDates: [Date] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        
    }
    
    func setupView()
    {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        
        // date picker

        self.datePicker.layer.cornerRadius = App.Appearance.buttonCornerRadius
        self.datePicker.layer.borderWidth = App.Appearance.borderWidth
        self.datePicker.layer.borderColor = UIColor.lightGray.cgColor

        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.zillianceTextViewController = segue.destination as! ZillianceTextViewController
        self.zillianceTextViewController.textViewContent = self.textViewContent
    }
    
    private func showExample(number: Int) {
        
        guard let exampleViewController = UIStoryboard(name: "ExamplePopUp", bundle: nil).instantiateInitialViewController() as? ExamplePopUpViewController else {
            assertionFailure()
            return
        }
        
        exampleViewController.textViewContent = self.textViewContent
        exampleViewController.exampleNumber = ExamplePopUpViewController.ExampleNumber(rawValue: number)!
        
        exampleViewController.doneAction = {[unowned self] text in
            self.zillianceTextViewController.setupForExample(with: text)
        }
        
        let formSheet = MZFormSheetController(viewController: exampleViewController)
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.presentedFormSheetSize = CGSize(width: 300, height: 400)
        formSheet.transitionStyle = .bounce
        
        self.mz_present(formSheet, animated: true, completionHandler: nil)

        
    }
    
    // MARK: -- User Actions
    
    @IBAction func exampleOneAction(_ sender: Any) {
        
      showExample(number: 0)
    }
    
    @IBAction func exampleTwoAction(_ sender: Any) {
        showExample(number: 1)
    }
}

