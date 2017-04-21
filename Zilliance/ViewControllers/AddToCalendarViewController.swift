//
//  AddToCalendarViewController.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 3/22/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import UIKit
import SVProgressHUD

class EditableTextView: UITextView
{
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

struct TextViewContent {
    let userActivity: UserActivity
    let type: FineTuneType
}

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
    
    var textViewContent: TextViewContent?
    
    fileprivate var editableTexts: [EditableText] = []
    fileprivate var grayTexts: [String] = []
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bodyTextView: UITextView!
    
    static let kTopLayoutSeparation: CGFloat = 41
    static let kMaxNumberOfDays = 14

    fileprivate var pickerDates: [Date] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        
        self.bodyTextView.text = nil
        
        let tapEdit = UITapGestureRecognizer(target: self, action: #selector(self.editTapped))
        self.bodyTextView.addGestureRecognizer(tapEdit)
        self.bodyTextView.isEditable = false
        
        if let textViewContent = self.textViewContent {
            self.text(for: textViewContent)
        }

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
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PartialSizePresentationController(presentedViewController: presented, presenting: presenting, height: self.view.frame.size.height / 2.0)
        return presentationController
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
    
    func setupTextView() {
        
        var currentText: String = self.bodyTextView.text
        
        if (currentText.characters.count == 0)
        {
            currentText = "Shift my thoughts about Activity by focusing on the need(s) it fulfills: \(self.editableTexts[0].text) and another text : \(self.editableTexts[1].text)"
        }
        
        let attributedString = NSMutableAttributedString(string: currentText, attributes: [
            NSFontAttributeName : UIFont.muliRegular(size: 15.0)
            ])
        
        for i in 0 ..< self.editableTexts.count {
            
            let range = (currentText as NSString).range(of: self.editableTexts[i].text)
            
            if (range.location != NSNotFound)
            {
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue , range: range)
            }
        }
        
        var ranges: [NSRange] = []
        
        for gText in self.grayTexts {
            ranges.append((currentText as NSString).range(of: gText)
            )
        }
        for range in ranges {
            
            attributedString.addAttributes([NSForegroundColorAttributeName : UIColor.gray], range: range)
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
    
    // MARK : --
    
    fileprivate func text(for textView: TextViewContent) {
        switch (textView.userActivity.feeling, textView.type) {
        case (.great, .pleasure):
            
            var valuesString = textView.userActivity.values.first?.name
            
            let values = textView.userActivity.values.dropFirst()
            
            values.forEach({ (value) in
                valuesString = valuesString! + ", \(value.name)"
            })
            
            self.bodyTextView.text = "Remind myself that I love \((textView.userActivity.activity?.name)!) because of the \(valuesString!)"
        case (.great, .prioritize):
            self.bodyTextView.text = "Prioritze \((textView.userActivity.activity?.name)!)"
        case (.great, .gratitude):
            self.bodyTextView.text = "Give thanks for \((textView.userActivity.activity?.name)!). Acknowledge the gifts and blessings"
        case (.great, .giving):
            self.bodyTextView.text = "Do one act of kindness while engaged in \((textView.userActivity.activity?.name)!)"
        case (.great, .values):
            let editText = EditableText(feeling: .great, text: "choose values", type: .value, isMultipleSelection: true, selectedIndexes: nil)
            self.editableTexts = [editText]
            self.bodyTextView.text = "Bring more \(self.editableTexts[0].text) to \((textView.userActivity.activity?.name)!)"
            self.setupTextView()
        case (.lousy, .replace):
            self.bodyTextView.text = "Replace \((textView.userActivity.activity?.name)!) with this better feeling activity: e.g. reading a book"
            self.grayTexts = ["e.g. reading a book"]
            self.setupTextView()
        case (.lousy, .reduce):
            self.bodyTextView.text = "Reduce the amount of time I spend on \((textView.userActivity.activity?.name)!) by doing this: e.g. picking up a book every time I am tempted to look at social media"
            self.grayTexts = ["e.g. picking up a book every time I am tempted to look at social media"]
            self.setupTextView()
        case (.lousy, .shift):
            let editText = EditableText(feeling: .great, text: "choose values", type: .value, isMultipleSelection: true, selectedIndexes: nil)
            self.editableTexts = [editText]
            self.bodyTextView.text = "Shift my thoughts about \((textView.userActivity.activity?.name)!) by focusing on the need(s) it fulfills: \(self.editableTexts[0].text) "
            self.setupTextView()
        case (.lousy, .values):
            let editText = EditableText(feeling: .great, text: "choose positive value", type: .value, isMultipleSelection: false, selectedIndexes: nil)
            self.editableTexts = [editText]
            self.bodyTextView.text = "Bring \(self.editableTexts[0].text) to \((textView.userActivity.activity?.name)!) by: e.g. listening to podcasts or audiobooks."
            self.grayTexts = ["e.g. listening to podcasts or audiobooks."]
            self.setupTextView()
        case (.lousy, .need):
            self.bodyTextView.text = "What I need to feel better about \((textView.userActivity.activity?.name)!) that is in my control is: e.g. more adventure. To meet this need, I will take this action step: e.g. ask my friends to go mountain climbing with me"
            self.grayTexts = ["e.g. more adventure", "e.g. ask my friends to go mountain climbing with me"]
            self.setupTextView()
        case (.neutral, .replace):
            self.bodyTextView.text = "Replace or move towards replacing \((textView.userActivity.activity?.name)!) by: taking an online class about entrepreneurship"
            self.grayTexts = ["taking an online class about entrepreneurship"]
        case (.neutral, .reduce):
            self.bodyTextView.text = "Reduce the amount of time I spend on  \((textView.userActivity.activity?.name)!) by doing this feel-good activity instead, even for just a few minutes: Do two minutes of sit-ups every hour"
            self.grayTexts = ["Do two minutes of sit-ups every hour"]
            self.setupTextView()
        case (.neutral, .shift):
            let editText = EditableText(feeling: .great, text: "choose values", type: .value, isMultipleSelection: true, selectedIndexes: nil)
            self.editableTexts = [editText]
            self.bodyTextView.text = "Shift my thoughts about \((textView.userActivity.activity?.name)!) by focusing on the need(s) it fulfills: \(self.editableTexts[0].text) "
            self.setupTextView()
        case (.neutral, .values):
            let editText = EditableText(feeling: .great, text: "choose positive value", type: .value, isMultipleSelection: false, selectedIndexes: nil)
            self.editableTexts = [editText]
            self.bodyTextView.text = "Bring \(self.editableTexts[0].text) to \((textView.userActivity.activity?.name)!) by: e.g. listening to podcasts or audiobooks."
            self.grayTexts = ["e.g. listening to podcasts or audiobooks."]
            self.setupTextView()
        case (.neutral, .need):
            self.bodyTextView.text = "What I need to feel better about \((textView.userActivity.activity?.name)!) that is in my control is: e.g. more adventure. To meet this need, I will take this action step: e.g. ask my friends to go mountain climbing with me"
            self.grayTexts = ["e.g. more adventure", "e.g. ask my friends to go mountain climbing with me"]
            self.setupTextView()
        case (.mixed, .reduce):
            self.bodyTextView.text = "Reduce the amount of time I spend on not-so-good feeling parts of \((textView.userActivity.activity?.name)!) by doing this instead: taking a 15 minute walk in the afternoon"
            self.grayTexts = ["taking a 15 minute walk in the afternoon"]
            self.setupTextView()
        case (.mixed, .gratitude):
            self.bodyTextView.text = "Give thanks for the aspects of \((textView.userActivity.activity?.name)!) that I'm greatful for. Acknowledge the gifts and blessings"
        case (.mixed, .shift):
            let editText = EditableText(feeling: .great, text: "choose values", type: .value, isMultipleSelection: true, selectedIndexes: nil)
            self.editableTexts = [editText]
            self.bodyTextView.text = "Shift my thoughts about the non-so-good feelings parts of \((textView.userActivity.activity?.name)!) by focusing on the need(s) it fulfills: \(self.editableTexts[0].text) "
            self.setupTextView()
        case (.mixed, .values):
            let editText = EditableText(feeling: .great, text: "choose positive value", type: .value, isMultipleSelection: false, selectedIndexes: nil)
            let editText2 = EditableText(feeling: .great, text: "choose positive values", type: .value, isMultipleSelection: false, selectedIndexes: nil)
            self.editableTexts = [editText, editText2]
            self.bodyTextView.text = "Bring more \(self.editableTexts[0].text) to the good-feeling parts of \((textView.userActivity.activity?.name)!) by: e.g. listening to podcasts or audiobooks. \nBring more \(self.editableTexts[1].text) to the not-so-good feeling parts by: e.g. …"
            self.grayTexts = ["e.g. listening to podcasts or audiobooks.", "e.g. …"]
            self.setupTextView()
        case (.mixed, .need):
            self.bodyTextView.text = "What I need to feel better about \((textView.userActivity.activity?.name)!) that is in my control is: e.g. more adventure. To meet this need, I will take this action step: e.g. ask my friends to go mountain climbing with me"
            self.grayTexts = ["e.g. more adventure", "e.g. ask my friends to go mountain climbing with me"]
            self.setupTextView()
        default:
            break
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

