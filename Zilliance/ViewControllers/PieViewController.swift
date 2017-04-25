//
//  PieViewController.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 4/4/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit
import SideMenuController

class PieViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    private enum SliceOptions: String {
        case edit = "Edit Slice"
        case tune = "Fine Tune Slice"
        case delete = "Delete Slice"
    }

    private let statusBarBackgroundView = UIView()
    private let hoursProgressView = HoursProgressView()
    private let pieView = PieView()
    private let titleLabel = UILabel()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
    
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.backgroundColor = .lightGrayBackground
        self.title = "Balance Pie"
        
        
        self.statusBarBackgroundView.backgroundColor = .darkBlueBackground
        self.statusBarBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.statusBarBackgroundView)
        
        // Progress View
        
        self.hoursProgressView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.hoursProgressView)
        
        self.hoursProgressView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 0).isActive = true
        self.hoursProgressView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        
        // Status Bar Background

        self.statusBarBackgroundView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        self.statusBarBackgroundView.bottomAnchor.constraint(equalTo: self.hoursProgressView.bottomAnchor, constant: 0).isActive = true
        self.statusBarBackgroundView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        self.statusBarBackgroundView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        
        // Title Label
        
        self.titleLabel.text = "Your Balance Pie"
        self.titleLabel.font = .muliLight(size: 24)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.titleLabel)
        
        self.titleLabel.topAnchor.constraint(equalTo: self.hoursProgressView.bottomAnchor, constant: 20).isActive = true
        self.titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        // Pie View
        
        self.pieView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.pieView)
        
        self.pieView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.pieView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.pieView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.pieView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        self.pieView.plusButtonAction = {[unowned self] in
            self.plusAction()
        }
        
        self.pieView.sliceAction = { [weak self] index, activity in
            self?.sliceAction(with: activity)
        }
        
        let sideMenuButton = UIButton()
        self.view.addSubview(sideMenuButton)
        sideMenuButton.translatesAutoresizingMaskIntoConstraints = false
        sideMenuButton.setImage(UIImage(named: "drawer-toolbar-icon"), for: .normal)
        sideMenuButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        sideMenuButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        sideMenuButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        sideMenuButton.centerYAnchor.constraint(equalTo: self.hoursProgressView.progressTrack.centerYAnchor).isActive = true
        
        self.hoursProgressView.leftAnchor.constraint(equalTo: sideMenuButton.rightAnchor, constant: 0).isActive = true
        
        sideMenuButton.addTarget(self.sideMenuController, action: #selector(SideMenuController.toggle), for: .touchUpInside)
        
    }
    
    private func loadData() {
        let availableMinutes = Database.shared.user.availableHours * 60
        self.pieView.load(activities: Array(Database.shared.user.activities), availableMinutes: availableMinutes)
    }
    
    private func refreshHours() {
        if let user = Database.shared.user {
            self.hoursProgressView.availableHours = user.availableHours
            self.hoursProgressView.activeHours = user.currentActivitiesDuration / 60
            self.hoursProgressView.sleepHours =  user.weeklyHoursTimeSlept
        }
    }
    
    // MARK: Slice Options
    
    private func edit(_ userActivity: UserActivity) {
        let addStoryboard = UIStoryboard(name: "AddCustom", bundle: nil)
        guard let editActivtyVC = addStoryboard.instantiateViewController(withIdentifier: "EditActivityViewController") as? EditActivityViewController
            else{
                return
        }
        
        editActivtyVC.activity = userActivity
        let navigation = UINavigationController(rootViewController: editActivtyVC)
        self.present(navigation, animated: true)
    }
    
    private func fineTune(_ userActivity: UserActivity) {
        // Will depend on the feeling of the current activity
        
        let fineTuneVC = UIStoryboard(name: "FineTuneActivity", bundle: nil).instantiateInitialViewController() as! FineTuneActivityViewController
        
        fineTuneVC.zUserActivity = userActivity
        
        let navigationFineTuneVC = UINavigationController(rootViewController: fineTuneVC)
        self.present(navigationFineTuneVC, animated: true, completion: nil)
    }
    
    private func delete(_ userActivity: UserActivity) {
        let title = "Delete \(userActivity.activity!.name) Slice"
        let message = "Deleting this slice will remove it from your pie"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete Slice", style: .default) { _ in
            Database.shared.user.remove(userActivity: userActivity)
            self.loadData()
            self.refreshHours()
            alert.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - User Actions
    
    func plusAction() {
        guard let addActivityVC = UIStoryboard(name: "AddCustom", bundle: nil).instantiateViewController(withIdentifier: "AddSliceViewController") as? AddSliceViewController else{
            assertionFailure()
            return
        }
        
        let navigation = UINavigationController(rootViewController: addActivityVC)
        self.present(navigation, animated: true)
    }
    
    func sliceAction(with activity: UserActivity) {
        let title = "\(activity.activity!.name) Slice"
        let message = "What would you like to do?"
        
        let actionController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        actionController.addAction(UIAlertAction(title: SliceOptions.edit.rawValue, style: .default) { _ in
            actionController.dismiss(animated: true, completion: nil)
            self.edit(activity)
            
        })
        
        actionController.addAction(UIAlertAction(title: SliceOptions.tune.rawValue, style: .default) { _ in
            actionController.dismiss(animated: true, completion: nil)
            self.fineTune(activity)
            
        })
        
        actionController.addAction(UIAlertAction(title: SliceOptions.delete.rawValue, style: .destructive) { _ in
            actionController.dismiss(animated: true, completion: nil)
            self.delete(activity)
            
        })
        
        actionController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            actionController.dismiss(animated: true, completion: nil)
        })
        
        self.present(actionController, animated: true, completion: nil)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PartialSizePresentationController(presentedViewController: presented, presenting: presenting, height: self.view.frame.size.height / 2.0)
        return presentationController
    }

}
