//
//  PieViewController.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 4/4/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

class PieViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    private enum SliceOptions: String {
        case edit = "Edit Slice"
        case tune = "Fine Tune Slice"
        case delete = "Delete Slice"
    }
    
    private let statusBarBackgroundView = UIView()
    private let hoursProgressView = HoursProgressView()
    
    private let pieView = PieView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
        self.refreshHours()
    }

    private func setupViews() {
    
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.title = "Balance Pie"
        
        // Pie View
        
        self.pieView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.pieView)
        
        self.pieView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.pieView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.pieView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.pieView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        
        self.pieView.sliceAction = { [weak self] index, activity in
            self?.sliceAction(withActivity: activity)
        }
        
        // Progress View
        
        self.hoursProgressView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.hoursProgressView)
        
        self.hoursProgressView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 0).isActive = true
        self.hoursProgressView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        self.hoursProgressView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        
        // Status Bar Background
        
        self.statusBarBackgroundView.backgroundColor = .darkBackgroundBlue
        self.statusBarBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.statusBarBackgroundView)
        
        self.statusBarBackgroundView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        self.statusBarBackgroundView.bottomAnchor.constraint(equalTo: self.hoursProgressView.topAnchor, constant: 0).isActive = true
        self.statusBarBackgroundView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        self.statusBarBackgroundView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        
        
        //activities test button
        let showActivitiesButton = UIButton()
        showActivitiesButton.setTitle("Tap to select activities", for: .normal)
        self.view.addSubview(showActivitiesButton)
        showActivitiesButton.sizeToFit()
        showActivitiesButton.translatesAutoresizingMaskIntoConstraints = false
        showActivitiesButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        showActivitiesButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20).isActive = true
        
        showActivitiesButton.addTarget(self, action: #selector(testActivitiesSelectionTapped), for: .touchUpInside)
        
    }
    
    private func loadData() {
        
        
        let availableMinutes = Database.shared.user.availableHours * 60
        
        self.pieView.load(activities: Array(Database.shared.user.activities), availableMinutes: availableMinutes)
    }
    
    
    private func refreshHours() {
        
        if let user = Database.shared.user
        {
            self.hoursProgressView.availableHours = user.availableHours
            self.hoursProgressView.activeHours = 35 // TODO: take it from the DB after we start to work with the DB = user?.currentActivitiesDuration / 60
            
            self.hoursProgressView.sleepHours = user.timeSlept / 60
            
        }
        
    }
    
    // MARK: Slice Options
    
    private func edit(userActivity: UserActivity) {
        
    }
    
    private func fineTune(userActivity: UserActivity) {

        //fine tune setup example. It should use other view controllers
        let addStoryboard = UIStoryboard(name: "AddCustom", bundle: nil)

        let fineTuneStoryboard = UIStoryboard(name: "FineTuneActivity", bundle: nil)
        
        guard let addActivityVC = addStoryboard.instantiateViewController(withIdentifier: "AddActivityViewController") as? AddActivityViewController,
            let addValueVC = addStoryboard.instantiateViewController(withIdentifier: "AddValuesViewController") as? AddValuesViewController,
            let fineTuneVC = fineTuneStoryboard.instantiateInitialViewController() as? FineTuneActivityViewController
        else
        {
            return
        }
        
        let fineTuneItem0 = FineTuneItem(title: "Activity", image: UIImage(named: "btnPlus")!, viewController: addActivityVC)
        let fineTuneItem1 = FineTuneItem(title: "Value", image: UIImage(named: "btnPlus")!, viewController: addValueVC)
        
        let items = [fineTuneItem0, fineTuneItem1]
        
        fineTuneVC.items = items
        
        self.navigationController?.isNavigationBarHidden = false
        
        self.navigationController?.pushViewController(fineTuneVC, animated: true)
        //present(fineTuneVC, animated: true, completion: nil)
        
        
    }
    
    private func delete(userActivity: UserActivity) {
        
        let alert = UIAlertController(title: "Delete Slice", message: "Deleting a slice will remove it from your pie", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete Slice", style: .default) { _ in
            Database.shared.user.remove(userActivity: userActivity)
            self.loadData()
            alert.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
        })
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - User Actions
    
    func sliceAction(withActivity activity: UserActivity) {
        
        let actionController = UIAlertController(title: "What would you like to do?", message: nil, preferredStyle: .actionSheet)
        
        actionController.addAction(UIAlertAction(title: SliceOptions.edit.rawValue, style: .default) { _ in
            actionController.dismiss(animated: true, completion: nil)
            self.edit(userActivity: activity)
            
        })
        
        actionController.addAction(UIAlertAction(title: SliceOptions.tune.rawValue, style: .default) { _ in
            actionController.dismiss(animated: true, completion: nil)
            self.fineTune(userActivity: activity)
            
        })
        
        actionController.addAction(UIAlertAction(title: SliceOptions.delete.rawValue, style: .destructive) { _ in
            actionController.dismiss(animated: true, completion: nil)
            self.delete(userActivity: activity)
            
        })
        
        actionController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            actionController.dismiss(animated: true, completion: nil)
        })
        
        self.present(actionController, animated: true, completion: nil)
        
    }
    
    
    //Mark: Items Selection Presentation with DB Activities:
    
    @IBAction func testActivitiesSelectionTapped()
    {
        let storyboard = UIStoryboard(name: "ItemsSelection", bundle: nil)
        if let itemsVC = storyboard.instantiateInitialViewController() as? ItemsSelectionViewController
        {
            itemsVC.modalPresentationStyle = .custom
            itemsVC.transitioningDelegate = self
            
            let allActivities = Database.shared.allActivities()
            for activity in allActivities
            {
                var activityIcon = activity.iconName != nil ? UIImage(named: activity.iconName!) : nil
                
                // just for testing adding the btnPlus
                if (activityIcon == nil)
                {
                    activityIcon = UIImage(named: "btnPlus")
                }
                
                let itemModel = ItemSelectionViewModel(title: activity.name, image:activityIcon)
                itemsVC.items.append(itemModel)
            }
            
            self.present(itemsVC, animated: true, completion: nil)
            
            itemsVC.createItemTitle = "Create a new Activity"
            itemsVC.createNewItemAction = {
                print("this should launch a controller to show the activity creation")
            }
            
        }
    }
    
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let presentationController = PartialSizePresentationController(presentedViewController: presented,
                                                                       presenting: presenting, height: self.view.frame.size.height / 2.0)
        return presentationController
    }
}


