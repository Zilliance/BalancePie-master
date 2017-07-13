//
//  ScheduleNotificationTableViewController.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 7/12/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit
import MultiSelectSegmentedControl
import MZFormSheetController

class ScheduleNotificationTableViewController: UITableViewController {
    
    private let hoursRow = 2

    @IBOutlet weak var weeklySwitch: UISwitch!
    @IBOutlet weak var daysSegment: MultiSelectSegmentedControl!
    
    var textViewContent: TextViewContent?
    

    private var zillianceTextViewController: ZillianceTextViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    private func setupView() {
        
        self.daysSegment.tintColor = UIColor.switchBlueColor
        self.daysSegment.setTitleTextAttributes([NSFontAttributeName: UIFont.muliRegular(size: 10.0), NSForegroundColorAttributeName: UIColor.white] , for: .selected)
        self.daysSegment.setTitleTextAttributes([NSFontAttributeName: UIFont.muliRegular(size: 10.0), NSForegroundColorAttributeName: UIColor.scheduleTextColor] , for: .normal)
        self.tableView.tableFooterView = UIView()
        
        self.weeklySwitch.onTintColor = UIColor.switchBlueColor
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.zillianceTextViewController = segue.destination as! ZillianceTextViewController
        self.zillianceTextViewController.textViewContent = self.textViewContent
    }
    

    // MARK - User Actions
    
    @IBAction func exampleAction(_ sender: UIButton) {
        
        
        guard let exampleViewController = UIStoryboard(name: "ExamplePopUp", bundle: nil).instantiateInitialViewController() as? ExamplePopUpViewController else {
            assertionFailure()
            return
        }
        
        exampleViewController.textViewContent = self.textViewContent
        exampleViewController.exampleNumber = ExamplePopUpViewController.ExampleNumber(rawValue: 0)!
        
        exampleViewController.doneAction = {[unowned self] text in
            self.zillianceTextViewController.setupForExample(with: text)
        }
        
        let formSheet = MZFormSheetController(viewController: exampleViewController)
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.presentedFormSheetSize = CGSize(width: 300, height: 400)
        formSheet.transitionStyle = .bounce
        
        self.mz_present(formSheet, animated: true, completionHandler: nil)

        
    }
    
    // MARK - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == hoursRow {
            // show date picker
            
        }
    }
    
}

