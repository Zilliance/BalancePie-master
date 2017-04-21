//
//  AddToCalendarViewController.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 3/22/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import UIKit
import SVProgressHUD

class AddToCalendarViewController: UIViewController, UITextViewDelegate, UIViewControllerTransitioningDelegate {
    
    struct EditableText {
        var feeling: Feeling = .none
        var text: String = ""
        var type: EditTextType = .value
        var isMultipleSelection = false
        var selectedIndexes: [Int]? = []
    }
    
    enum EditTextType {
        case value
        case activity
        case text
    }
    
    var editText = EditableText(feeling: .great, text: "choose multiple good values", type: .value, isMultipleSelection: true, selectedIndexes: nil)
    var editText2 = EditableText(feeling: .lousy, text: "chooose single bad value", type: .value, isMultipleSelection: false, selectedIndexes: nil)
    
    var editableTexts: [EditableText] = []
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bodyTextView: UITextView!
    
    static let kTopLayoutSeparation: CGFloat = 41
    static let kMaxNumberOfDays = 14

    fileprivate var pickerDates: [Date] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.editableTexts = [editText, editText2]
        
        self.bodyTextView.text = nil
        self.setupTextView()
        
        let tapEdit = UITapGestureRecognizer(target: self, action: #selector(self.editTapped))
        self.bodyTextView.addGestureRecognizer(tapEdit)
        self.bodyTextView.isEditable = false

    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.bodyTextView.isEditable = false
        self.bodyTextView.dataDetectorTypes = [.all];
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
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        
//        if (text == "\n")
//        {
//            textView.resignFirstResponder()
//            return false
//        }
//        
//        return true
//    }
    
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
            
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.setMaximumDismissTimeInterval(1.0)
            SVProgressHUD.showSuccess(withStatus: "The event has been added to your calendar")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.navigationController!.popViewController(animated: true)
            })
        }
    }
}

extension AddToCalendarViewController
{
    
    func replaceTappableText(index: Int, withText text: String)
    {
        if var currentText = self.bodyTextView.text, let range = currentText.range(of: self.editableTexts[index].text)
        {
            currentText.replaceSubrange(range, with: text)
            self.bodyTextView.text = currentText
            
            if (text.characters.count == 0)
            {
                self.editableTexts.remove(at: index)
            }
            else
            {
                self.editableTexts[index].text = text
            }
            self.setupTextView()
        }
    }
    
    fileprivate func setupTextView() {
        
        var currentText: String = self.bodyTextView.text
        
        if (currentText.characters.count == 0)
        {
            currentText = "Shift my thoughts about Activity by focusing on the need(s) it fulfills: \(self.editableTexts[0].text) and another text : \(self.editableTexts[1].text)"
        }
        
        let attributedString = NSMutableAttributedString(string: currentText)
        
        for i in 0 ..< self.editableTexts.count {
            
            let range = (currentText as NSString).range(of: self.editableTexts[i].text)
            
            if (range.location != NSNotFound)
            {
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue , range: range)
            }
        }
        
        self.bodyTextView.attributedText = attributedString
        self.bodyTextView.delegate = self
    }
    
    
    func editTapped(tap: UITapGestureRecognizer) {
        
        let point = tap.location(in: self.bodyTextView)
        
        let position = self.bodyTextView.closestPosition(to: point)!
        
        let range = self.bodyTextView.textRange(from: position, to: position)
        
        self.bodyTextView.selectedTextRange = range
        
        self.bodyTextView.dataDetectorTypes = []
        self.bodyTextView.isEditable = true
        self.bodyTextView.becomeFirstResponder()
    }
    
    func tappableIndexForRange(range: NSRange) -> Int?
    {
        var range = range
        range.length = 1 // when you tap it's 0 but we need to go one to the right to know if it overlaps
        
        let stringRange = self.bodyTextView.text.range(from: range)
        
        guard let sRange = stringRange else {
            return nil
        }
        
        for (index, element) in editableTexts.enumerated()
        {
            if let tapped = self.bodyTextView.text.range(of: element.text)?.overlaps(sRange), (tapped)
            {
                return index
            }
        }
        
        return nil
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        
        let range = self.bodyTextView.selectedRange
        
        if let indexTapped = self.tappableIndexForRange(range: range)
        {
            self.handleTextEditTapped(index: indexTapped)
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n")
        {
            textView.resignFirstResponder()
            return false
        }
        
        let deleteTapped = (text.characters.count == 0 && range.length == 1)
        
        if (deleteTapped)
        {
            if let indexTapped = self.tappableIndexForRange(range: range)
            {
                //remove the tappable text
                self.replaceTappableText(index: indexTapped, withText: "")
                return false
            }
        }
        
        return true
    }
    
    func handleTextEditTapped(index: Int)
    {
        guard let itemSelectionViewController = UIStoryboard(name: "ItemsSelection", bundle: nil).instantiateInitialViewController() as? ItemsSelectionViewController
            else {
                assertionFailure()
                return
        }
        
        var editText = self.editableTexts[index]
        
        if editText.type == .value {
            
            var values: [Value] = Array(Database.shared.allValues())
            
            switch editText.feeling {
            case .great:
                values = values.filter { $0.type == .good }
            case .lousy:
                values = values.filter { $0.type == .bad }
            default:
                break
            }
            
            if let indexes = editText.selectedIndexes {
                itemSelectionViewController.selectedItemsIndexes = Set(indexes)
            }
            
            itemSelectionViewController.createItemTitle = "Create your own"
            itemSelectionViewController.items = ItemSelectionViewModel.items(from: values)
            itemSelectionViewController.isMultipleSelectionEnabled = editText.isMultipleSelection
            
            let navigationController = UINavigationController(rootViewController: itemSelectionViewController)
            navigationController.modalPresentationStyle = .custom
            navigationController.transitioningDelegate = self
            navigationController.title = "Choose Values"
            DispatchQueue.main.async {
                self.present(navigationController, animated: true, completion: nil)
            }
            
            itemSelectionViewController.createNewItemAction = {[unowned self] in
                
                itemSelectionViewController.dismiss(animated: true, completion: {
                    guard let customValueViewController = UIStoryboard(name: "AddCustom", bundle: nil).instantiateViewController(withIdentifier: "AddValue") as? UINavigationController else {
                        assertionFailure()
                        return
                    }
                    
                    self.present(customValueViewController, animated: true, completion: nil)
                })
            }
            
            itemSelectionViewController.doneAction = {[unowned self] indexes in
                
                guard indexes.count > 0 else {
                    return
                }
                
                editText.selectedIndexes = indexes
                
                var selectedValues: [Value] = []
                indexes.forEach({ (index) in
                    selectedValues.append(values[index])
                })
                
                var valuesName = selectedValues.first?.name
                selectedValues.remove(at: 0)
                
                selectedValues.forEach({ (value) in
                    valuesName = valuesName! + ", \(value.name)"
                    
                })
                
                editText.text = valuesName!
                
                self.replaceTappableText(index: index, withText: valuesName!)
                
            }
            
        }
            
        else if editText.type == .activity {
            
            // pick activity
        }
            
        else if editText.type == .text {
            // show text promp
        }
        
    }
    
}

extension String {
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location + nsRange.length, limitedBy: utf16.endIndex),
            let from = from16.samePosition(in: self),
            let to = to16.samePosition(in: self)
            else { return nil }
        return from ..< to
    }
}

