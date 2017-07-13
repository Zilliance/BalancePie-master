//
//  ScheduleNotificationTableViewController.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 7/12/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

class ScheduleNotificationTableViewController: UITableViewController {
    
    private let hoursRow = 2

    @IBOutlet weak var textView: KMPlaceholderTextView!
    @IBOutlet weak var weeklySwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    private func setupView() {
        
        self.tableView.tableFooterView = UIView()
        self.weeklySwitch.onTintColor = UIColor.switchBlueColor
        
        self.textView.layer.cornerRadius = App.Appearance.buttonCornerRadius
        self.textView.layer.borderWidth = App.Appearance.borderWidth
        self.textView.layer.borderColor = UIColor.lightGray.cgColor
        
        self.textView.placeholder = "Reduce the amount of time spent on social media by doing this: e.g picking up a book every time I am tempted to look at social media"
        
    }

    // MARK - User Actions
    
    @IBAction func exampleAction(_ sender: UIButton) {
        
    }
    
    // MARK - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == hoursRow {
            // show date picker
            
        }
    }
    
}

