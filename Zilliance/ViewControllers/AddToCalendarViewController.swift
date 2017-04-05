//
//  AddToCalendarViewController.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 3/22/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import UIKit

class AddToCalendarViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var viewTopLayout: NSLayoutConstraint!
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
        
        //setup width and corner radius
        for view in [subjectTextField, bodyTextView, doneButton] as [UIView]
        {
            view.layer.cornerRadius = 6
            view.layer.borderWidth = 0.5
            view.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        //subject
        subjectTextField.delegate = self
        subjectTextField.returnKeyType = .next
        
        //body
        bodyTextView.delegate = self
        bodyTextView.returnKeyType = .done
        
        //keyboard functionality
        NotificationCenter.default.addObserver(self, selector: #selector(AddToCalendarViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddToCalendarViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    fileprivate func formatDate(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE MMMM, d"
        return dateFormatter.string(from: date)
    }
    
    fileprivate func formatTime(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }
    
    
    
    func keyboardWillShow(notification: NSNotification) {
        
        if (!bodyTextView.isFirstResponder)
        {
            return // this should only work for the body view
        }
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            viewTopLayout.constant = -keyboardSize.height
            
            UIView.animate(withDuration: duration.doubleValue, animations: {[unowned self] in
                self.view.layoutIfNeeded()
                
            })
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        guard viewTopLayout.constant != AddToCalendarViewController.kTopLayoutSeparation, let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber  else
        {
            return
        }
        
        viewTopLayout.constant = AddToCalendarViewController.kTopLayoutSeparation
        
        UIView.animate(withDuration: duration.doubleValue, animations: {[unowned self] in
            self.view.layoutIfNeeded()
        })
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        DispatchQueue.main.async {[weak self] in
            self?.bodyTextView.becomeFirstResponder()
        }
        
        return true
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
    
    @IBAction func onDone(_ sender: Any)
    {
        
        guard let subject = subjectTextField.text, let body = bodyTextView.text, subject.characters.count > 0, body.characters.count > 0 else
        {
            if (subjectTextField.text?.characters.count == 0)
            {
                self.showAlert(message: "Please include a title", title: "Error")
                return
            }
            //is this needed?
            if (bodyTextView.text.characters.count == 0)
            {
                self.showAlert(message: "Please include a note", title: "Error")
                return
            }
            
            return
        }
        
        CalendarHelper.addEvent(with: subject, notes: body, date: self.datePicker.date) { (success, error) in
            
            guard success else {
                if let calendarError = error {
                    switch calendarError {
                    case .notGranted:
                        self.showAlert(message: "Calendar not authorized, please enable calendar in app settings", title: "Error")
                    case .errorSavingEvent:
                        self.showAlert(message: "There was an error saving your event to calendar", title: "Error")
                        
                    }
                }
            return
            }
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }

}
