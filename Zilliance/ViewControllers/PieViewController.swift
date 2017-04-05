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
        
        
    }
    
    private func loadData() {
        
        let activity1 = Activity()
        activity1.name = "Test"
        //activity1.duration = 300
        
        let userActivity = UserActivity()
        userActivity.activity = activity1
        userActivity.duration = 300
        userActivity.feeling = .mixed

        let userActivity1 = UserActivity()
        userActivity1.activity = activity1
        userActivity1.duration = 600
        userActivity1.feeling = .great
        
        let activities = [userActivity, userActivity1]
        
        let totalDuration = activities.reduce(0, {$0 + $1.duration})
        
        self.pieView.load(activities: activities, availableMinutes: 140 * 60, totalDuration: totalDuration)
    }
    
    
    private func refreshHours() {
        self.hoursProgressView.availableHours = 140
        self.hoursProgressView.activeHours = 35
        self.hoursProgressView.sleepHours = 40
    }
    
    
    // MARK: - User Actions
    
    @IBAction func sliceAction(withActivity activity: UserActivity) {
//        let messages = ["Edit Slice", "Fine Tune Slice", "Delete Slice"]
//        self.showActionSheet(withMessages: messages, title: "What would you like to do?") { index in
//            print(index)
//        }
        
        let storyboard = UIStoryboard(name: "ItemsSelection", bundle: nil)
        if let itemsVC = storyboard.instantiateInitialViewController() as? ItemsSelectionViewController
        {
            itemsVC.modalPresentationStyle = .custom
            itemsVC.transitioningDelegate = self
            
            itemsVC.items = ["Item 1", "Item 2", "Item 3"]
            
            self.present(itemsVC, animated: true, completion: nil)
            
        }
        
    }
    
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let presentationController = HalfSizePresentationController(presentedViewController: presented,
                                                                   presenting: presenting)
        return presentationController
    }
}

class HalfSizePresentationController : UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        
        guard let containerView = containerView else {return CGRect()}
        
        let height = containerView.bounds.height/2
        return CGRect(x: 0, y: containerView.bounds.height/2, width: containerView.bounds.width, height: height)
    }
}

