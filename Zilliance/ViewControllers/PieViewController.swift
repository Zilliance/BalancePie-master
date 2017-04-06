//
//  PieViewController.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 4/4/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

class PieViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
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
        
        let activity1 = Activity()
        activity1.name = "Test"
        
        let userActivity = UserActivity()
        userActivity.activity = activity1
        userActivity.duration = 300
        userActivity.feeling = .mixed

        let activity2 = Activity()
        activity2.name = "Test"
        
        let userActivity1 = UserActivity()
        userActivity1.activity = activity2
        userActivity1.duration = 600
        userActivity1.feeling = .great
        
        let activities = [userActivity, userActivity1]
        
        let totalDuration = activities.reduce(0, {$0 + $1.duration})
        
        let availableMinutes = Database.shared.user.availableHours * 60
        
        self.pieView.load(activities: activities, availableMinutes: availableMinutes, totalDuration: totalDuration)
    }
    
    
    private func refreshHours() {
        
        if let user = Database.shared.user
        {
            self.hoursProgressView.availableHours = user.availableHours
            self.hoursProgressView.activeHours = 35 // TODO: take it from the DB after we start to work with the DB = user?.currentActivitiesDuration / 60
            
            self.hoursProgressView.sleepHours = user.timeSlept / 60
            
        }
        
    }
    
    // MARK: - User Actions
    
    func sliceAction(withActivity activity: UserActivity) {
        let messages = ["Edit Slice", "Fine Tune Slice", "Delete Slice"]
        let actionController = UIAlertController(title: "What would you like to do?", message: nil, preferredStyle: .actionSheet)
        for i in 0 ..< messages.count {
            let style: UIAlertActionStyle = (i == messages.count-1) ? .destructive : .default
            actionController.addAction(UIAlertAction(title: messages[i], style: style) { _ in
                actionController.dismiss(animated: true, completion: nil)
                print(i)
            })
        }
        
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
                let activityIcon = activity.iconName != nil ? UIImage(named: activity.iconName!) : nil
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


