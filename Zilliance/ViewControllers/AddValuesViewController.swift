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
    @IBOutlet weak var createValueButton: UIButton!
    var dismissAction: ((Value?) -> ())?
    var valueType = ValueType.great
    
    var valueText: String? {
        if let text = self.valueTextField.text {
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return nil
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        
        self.createValueButton.layer.cornerRadius = App.Appearance.buttonCornerRadius
        
        // Cancel button
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(userDidTapCancel))
        
        // Name field

        self.valueTextField.backgroundColor = .clear
        self.valueTextField.font = .muliRegular(size: 16.0)
        self.valueTextField.attributedPlaceholder = NSAttributedString(string: "Name of value, .e.g. Happiness", attributes: [
            NSFontAttributeName : UIFont.muliRegular(size: 16.0)
        ])
    }
    
    fileprivate func saveValue(name: String) {
        let value = Value()
        value.name = name
        value.order = .highest
        value.type = self.valueType
        //TODO : move this to model
        try! Database.shared.realm.write {
            Database.shared.realm.add(value)
        }
        dismissAction?(value)
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
    
    @IBAction func createValueAction(_ sender: Any) {
        
        guard let name = self.valueText else {
            self.showAlert(message: "Please enter a name for your custom value", title: nil)
            return
        }
        if !self.nameIsValid(name) {
            self.showAlert(message: "Please enter a name for your custom value", title: nil)
            return
        } else if self.valueAlreadyExists(name: name) {
            self.showAlert(message: "A value with this name already exists", title: nil)
            return
        } else {
            self.saveValue(name: name)
            self.dismiss(animated: true, completion: nil)

        }
        
        
    }
    
    @IBAction func userDidTapCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.dismissAction?(nil)
    }
}

extension AddValuesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
