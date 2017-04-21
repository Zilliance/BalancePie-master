//
//  AddToCalendarViewController.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 3/22/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import UIKit

class AddToCalendarViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bodyTextView: UITextView!
    
    static let kTopLayoutSeparation: CGFloat = 41
    static let kMaxNumberOfDays = 14

    fileprivate var pickerDates: [Date] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()

    }
    
    func setupView()
    {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        //setup width and corner radius
 
        self.bodyTextView.layer.cornerRadius = App.Appearance.buttonCornerRadius
        self.bodyTextView.layer.borderWidth = App.Appearance.borderWidth
        self.bodyTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        self.doneButton.layer.cornerRadius = App.Appearance.buttonCornerRadius
        
        // date picker

        self.datePicker.layer.cornerRadius = App.Appearance.buttonCornerRadius
        self.datePicker.layer.borderWidth = App.Appearance.borderWidth
        self.datePicker.layer.borderColor = UIColor.lightGray.cgColor
        
        //body
        self.bodyTextView.delegate = self
        self.bodyTextView.returnKeyType = .done
        
    }
    
    //simple way to hide the textview
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if (text == "\n")
        {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: Any) {
        guard let body = bodyTextView.text, body.characters.count > 0 else {
            //is this needed?
            if (bodyTextView.text.characters.count == 0) {
                self.showAlert(message: "Your event text will help remind you to take this action", title: "Please Add Event Text")
                return
            }
            
            return
        }
        
        CalendarHelper.addEvent(with: body, notes: nil, date: self.datePicker.date) { (success, error) in
            
            guard success else {
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
            
            // TODO: show an alert that we've scheduled the event
            
            self.navigationController!.popViewController(animated: true)
        }
    }
}
