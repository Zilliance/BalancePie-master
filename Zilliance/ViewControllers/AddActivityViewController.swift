//
//  AddActivityViewController.swift
//  Balance Pie
//
//  Created by ricardo hernandez  on 2/10/17.
//  Copyright © 2017 Phil Dow. All rights reserved.
//

import UIKit

class AddActivityViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{

    @IBOutlet weak var activityTextField: UITextField!
    @IBOutlet weak var selectAnIconLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var createActivityButton: UIButton!

    var dismissAction: ((Activity?) -> ())?

    private var selectedIconName: String?
    
    private let iconNames = ["chores", "driving", "exercise", "familyTime", "hobbies", "leisureTime", "quietTime", "reading", "romance", "socialNetworking", "spiritualPractice", "talkingOnPhone", "timeWithFriends", "treatment", "tv", "volunterring", "work"]
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.activityTextField.becomeFirstResponder()
    }
    
    private func setupViews() {
        
        self.title = "Custom Activity"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeView))
        
        self.selectAnIconLabel.text = "Select an Icon"
        self.selectAnIconLabel.font = UIFont.muliSemiBold(size: 16.0)
        self.selectAnIconLabel.textColor = .darkBlueBackground
        
        self.createActivityButton.layer.cornerRadius = App.Appearance.buttonCornerRadius
        
        self.collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10)
        
        self.createActivityButton.setTitle("Create Activity", for: .normal)
        self.createActivityButton.setTitleColor(UIColor.white, for: .normal)
        self.createActivityButton.titleLabel?.font = UIFont.muliRegular(size: 16.0)
        
        self.activityTextField.attributedPlaceholder = NSAttributedString(string: "Name of activity, e.g. Sports", attributes:[
            NSFontAttributeName : UIFont.muliRegular(size: 16.0)
        ])
    }
    
    private func saveActivity() {
        
        if self.checkIfActivityAlreadyExists(withName: self.activityTextField.text!) {
            self.showAlert(message: "Activity already exists", title: nil)
            return
        }
        
        let activity = Activity()
        activity.name = self.activityTextField.text!
        activity.iconName = selectedIconName!
        activity.order = .highest
        
        //TODO: move this to the model
        try! Database.shared.realm.write {
            Database.shared.realm.add(activity)
        }
        
        self.dismiss(activity: activity)
    }
    
    private func dismiss(activity: Activity?)
    {
        self.dismiss(animated: true, completion: nil)
        self.dismissAction?(activity)
    }
    
    private func checkIfActivityAlreadyExists(withName name:String) -> Bool {
        //TODO: update this
        let result = Database.shared.realm.objects(Activity.self).filter("name == %@", name)
        if  result.count > 0 {
            return true
        }
        return false
    }
    
    private func checkValues() -> Bool {
        
        switch ((self.activityTextField.text?.characters.count)! > 0, self.selectedIconName != nil) {
        case (true, true):
            return true
        case (true, false):
            self.showAlert(message: "Please select an icon", title: nil)
            return false
        case (false, _):
            self.showAlert(message: "Please add an activity name", title: nil)
            return false
        default:
            return false
        }
    }
    
    // MARK: Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconCell", for: indexPath) as! IconCollectionViewCell
        cell.iconImageView.image = UIImage(named: iconNames[indexPath.row])?.tinted(color: .darkBlueBackground)
        cell.backgroundColor = UIColor.unselectedIcon
        return cell
    }
    
    // MARK: CollectionView Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIconName = iconNames[indexPath.row]
    }
    

    // MARK: User Actions
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(activity: nil)
    }
    
    @IBAction func createActivity(_ sender: Any) {
        guard self.checkValues() else {
            return
        }
        
        Analytics.shared.send(event: BalancePieAnalytics.BalancePieEvent.customActivityAdded)

        self.saveActivity()
    }
    
}

extension AddActivityViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
