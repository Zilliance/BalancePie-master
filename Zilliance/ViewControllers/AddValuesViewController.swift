//
//  AddValuesViewController.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 2/10/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import UIKit

class AddValuesViewController: UIViewController {
    @IBOutlet weak var valueTextField: UITextField!
    
    var valueText: String? {
        if let text = self.valueTextField.text {
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.valueTextField.becomeFirstResponder()
    }
    
    fileprivate func setupViews() {
        self.title = "Custom Value"
        
        // Cancel button
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(userDidTapCancel))
        
        // Name field

        self.valueTextField.backgroundColor = .clear
        self.valueTextField.font = .zillianceRegularFont(ofSize: 16.0)
        self.valueTextField.attributedPlaceholder = NSAttributedString(string: "Name of value, .e.g. Happiness", attributes: [
            NSFontAttributeName : UIFont.zillianceRegularFont(ofSize: 16.0)
        ])
    }
    
    fileprivate func saveValue(name: String) {
        let activity = Value()
        activity.name = name
        //TODO : move this to model
        try! Database.shared.realm.write {
            Database.shared.realm.add(activity)
        }
    }
    
    fileprivate func valueAlreadyExists(name: String) -> Bool {
        // TODO: update (don´t intanciate database directly)
        if Database.shared.realm.objects(Value.self).filter("name == %@", name).count > 0 {
            return true
        } else {
            return false
        }
    }
    
    fileprivate func nameIsValid(_ name: String?) -> Bool {
        if let name = name, name.characters.count > 0 {
            return true
        } else {
            return false
        }
    }
        
    // MARK: User Actions
    
    @IBAction func userDidTapCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension AddValuesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let name = self.valueText else {
            self.showAlert(message: "Please enter a name for your custom value", title: nil)
            return false
        }
        if !self.nameIsValid(name) {
            self.showAlert(message: "Please enter a name for your custom value", title: nil)
            return false
        } else if self.valueAlreadyExists(name: name) {
            self.showAlert(message: "A value with this name already exists", title: nil)
            return false
        } else {
            self.saveValue(name: name)
            textField.resignFirstResponder()
            self.dismiss(animated: true, completion: nil)
            return true
        }
    }
}
