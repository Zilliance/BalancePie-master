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
import ZillianceShared

struct TextViewContent {
    let userActivity: UserActivity
    let type: FineTuneType
}

class AddToCalendarViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    fileprivate var zillianceTextViewController: ZillianceTextViewController!
    var preloadedNotification: ZillianceShared.Notification?
    var textViewContent: TextViewContent?

    fileprivate var pickerDates: [Date] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        
    }
    
    func setupView() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        
        // date picker

        self.datePicker.layer.cornerRadius = App.Appearance.buttonCornerRadius
        self.datePicker.layer.borderWidth = App.Appearance.borderWidth
        self.datePicker.layer.borderColor = UIColor.lightGray.cgColor

        if let preloadedNotification = preloadedNotification {
            self.zillianceTextViewController.textView.text = preloadedNotification.body
            self.datePicker.date = preloadedNotification.startDate ?? Date()
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: Any) {
        guard let body = self.zillianceTextViewController.textView.text, body.characters.count > 0 else {
            
            return
        }
        
        if let error = self.zillianceTextViewController.validation.error {
            switch error {
            case .value:
                self.showAlert(message: "Please select one or more values", title: "Select Values")
            case .placeholder:
                self.showAlert(message: "Replace the gray placeholder text with your own plan of action", title: "Enter your action plan")
            }
            
            return
        }
        
        CalendarHelper.shared.addEvent(with: body, notes: nil, date: self.datePicker.date) { (eventId, error) in
            
            guard eventId != nil else {
                switch error {
                case .notGranted?:
                    self.showAlert(message: "Please enable access calendar in app settings", title: "Unable to Access Your Calendar")
                case .errorSavingEvent?:
                    self.showAlert(message: "There was an unexpected error saving your event to calendar", title: "Unable to Schedule Event")
                default:
                    self.showAlert(message: "There was an unexpected error saving your event to calendar", title: "Unable to Schedule Event")
                }
                
                return
            }
            
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.setMaximumDismissTimeInterval(1.0)
            SVProgressHUD.showSuccess(withStatus: "The reminder has been added to your calendar")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.navigationController!.popViewController(animated: true)
            })
        }
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

extension AddToCalendarViewController: NotificationEditor {

    func getNotification() -> ZillianceShared.Notification? {
        
        let notification = (self.preloadedNotification?.detached()) ?? Notification()
        
        notification.body = self.zillianceTextViewController.textView.text
        notification.type = .calendar
        notification.startDate = self.datePicker.date
        
        return notification
        
    }
}

