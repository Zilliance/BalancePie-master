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

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weeklySwitch: UISwitch!
    @IBOutlet weak var daysSegment: MultiSelectSegmentedControl!
    
    var preloadedNotification: Notification?
    
    var textViewContent: TextViewContent?
    
    private let dateFormatter = DateFormatter()
    
    fileprivate var selectedTime: Date?

    fileprivate var zillianceTextViewController: ZillianceTextViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    private func setupView() {
        
        self.dateFormatter.dateFormat = "h:mm a"
        self.dateFormatter.amSymbol = "AM"
        self.dateFormatter.pmSymbol = "PM"
        
        self.daysSegment.tintColor = UIColor.switchBlueColor
        self.daysSegment.setTitleTextAttributes([NSFontAttributeName: UIFont.muliRegular(size: 10.0), NSForegroundColorAttributeName: UIColor.white] , for: .selected)
        self.daysSegment.setTitleTextAttributes([NSFontAttributeName: UIFont.muliRegular(size: 10.0), NSForegroundColorAttributeName: UIColor.scheduleTextColor] , for: .normal)
        self.tableView.tableFooterView = UIView()
        
        self.weeklySwitch.onTintColor = UIColor.switchBlueColor
        
        if let preloadedNotification = self.preloadedNotification, let startDate = preloadedNotification.startDate {
            self.zillianceTextViewController.textView.text = preloadedNotification.body
            self.weeklySwitch.isOn = preloadedNotification.recurrence == .weekly
            
            let days = IndexSet(Array(preloadedNotification.weekDays).map { return Int($0.internalValue.rawValue) }) as NSIndexSet
            
            self.daysSegment.selectedSegmentIndexes = days as IndexSet!
            
            self.dateLabel.text = self.dateFormatter.string(from: startDate)
            
            self.selectedTime = startDate
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.zillianceTextViewController = segue.destination as! ZillianceTextViewController
        self.zillianceTextViewController.textViewContent = self.textViewContent
    }
    

    // MARK - User Actions
    
    @IBAction func example1Action(_ sender: UIButton) {
        self.showExample(number: 0)
    }
    @IBAction func example2Action(_ sender: UIButton) {
        self.showExample(number: 1)
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

    // MARK - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == hoursRow {
          
            guard let datePicker = UIStoryboard(name: "Schedule", bundle: nil).instantiateViewController(withIdentifier: "datePicker") as? CustomDatePickerViewController else {
                    assertionFailure()
                    return
            }
            
            datePicker.date = { [unowned self] date in
                self.selectedTime = date
                self.dateLabel.text = self.dateFormatter.string(from: date)
            }
            
            let formSheet = MZFormSheetController(viewController: datePicker)
            formSheet.shouldDismissOnBackgroundViewTap = true
            formSheet.presentedFormSheetSize = CGSize(width: self.view.bounds.width, height: 300)
            formSheet.shouldCenterVertically = true
            formSheet.transitionStyle = .slideFromBottom
            
            self.mz_present(formSheet, animated: true, completionHandler: nil)
        }
    }
    
}

extension ScheduleNotificationTableViewController: NotificationEditor {
    func getNotification() -> Notification? {
        
        guard let selectedTime = selectedTime, daysSegment.selectedSegmentTitles.count > 0 else {
            return nil
        }
        
        let notification = (self.preloadedNotification?.detached()) ?? Notification()
        
        notification.body = self.zillianceTextViewController.textView.text
        notification.recurrence = weeklySwitch.isOn ? .weekly : .none
        notification.type = .local
        
        notification.weekDays.removeAll()
        
        for selectedDay in Array(daysSegment.selectedSegmentIndexes)
        {
            guard let weekDay = dayOfTheWeek(rawValue: Int32(selectedDay)) else {
                assertionFailure()
                continue
            }
            
            let day = DayObject(internalValue: weekDay)
            notification.weekDays.append(day)
        }
        
        let initialDate = selectedTime
        
        notification.startDate = Date()
        
        var startDate: Date
        
        if (initialDate > Date()) {
            startDate = initialDate
        } else {
            startDate = notification.getNextWeekDate(fromDate: initialDate) ?? initialDate
        }
        
        let nextWeek = Date().addingTimeInterval(60 * 60 * 24 * 7)
        
        if (nextWeek < startDate) {
            notification.startDate = initialDate
        } else {
            notification.startDate = startDate
        }

        return notification
        
    }
}
