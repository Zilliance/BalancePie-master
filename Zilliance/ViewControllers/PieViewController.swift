//
//  PieViewController.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 4/4/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit
import SideMenuController
import ActionSheetPicker_3_0

class PieViewController: UIViewController {
    
    private enum SliceOptions: String {
        case edit = "Update Slice"
        case tune = "Improve Slice"
        case delete = "Delete Slice"
    }

    private let actionPlanButton = UIButton()
    private let statusBarBackgroundView = UIView()
    private let hoursProgressView = HoursProgressView()
    private let pieView = PieView()
    private let titleLabel = UILabel()
    private let legend1 = PieLegendView(legends: [
        Legend(text: "I feel great", color: .feelingGreat),
        Legend(text: "I feel mixed", color: .feelingMixed),
        ]
    )
    private let legend2 = PieLegendView(legends:  [
        Legend(text: "I feel good", color: .feelingNeutral),
        Legend(text: "I feel lousy", color: .feelingLousy),
        ]
    )
    
    @available(*, deprecated)
    private let hintView = PieHintView()
    private var improveHint: OnboardingPopover?
    private let learnMoreLabel = UILabel()
    
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
        self.showImproveHint()
    }

    private func setupViews() {
    
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.backgroundColor = .lightGrayBackground
        self.title = "Balance Pie"
        
        
        self.statusBarBackgroundView.backgroundColor = .darkBlueBackground
        self.statusBarBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.statusBarBackgroundView)
        
        // Pie View
        
        self.pieView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.pieView)
        
        self.pieView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.pieView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.pieView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.pieView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: UIDevice.isSmallerThaniPhone6 ? -10 : -40).isActive = true
        
        self.pieView.plusButtonAction = {[unowned self] in
            self.plusAction()
        }
        
        self.pieView.sliceAction = { [weak self] index, activity in
            self?.sliceAction(with: activity)
        }
        
        // Legends
        
        self.view.addSubview(self.legend1)
        self.legend1.translatesAutoresizingMaskIntoConstraints = false
        self.legend1.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: UIDevice.isSmallerThaniPhone6 ? -120 : -150).isActive = true
        self.legend1.heightAnchor.constraint(equalToConstant: 20).isActive = true
        self.legend1.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.legend1.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        self.view.addSubview(self.legend2)
        self.legend2.translatesAutoresizingMaskIntoConstraints = false
        self.legend2.topAnchor.constraint(equalTo: self.legend1.bottomAnchor).isActive = true
        self.legend2.heightAnchor.constraint(equalToConstant: 20).isActive = true
        self.legend2.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.legend2.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        // Hint View
        
//        self.hintView.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addSubview(self.hintView)
//        self.hintView.topAnchor.constraint(equalTo: self.legend2.bottomAnchor, constant: UIDevice.isSmallerThaniPhone6 ? 10 : 20).isActive = true
//        self.hintView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
//        self.hintView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        // Learn More Label
        
        self.learnMoreLabel.font = .muliItalic(size: 14)
        self.learnMoreLabel.textColor = .lightBlueBackground
        self.learnMoreLabel.text = "Learn More"
        self.learnMoreLabel.textAlignment = .center
        self.learnMoreLabel.isUserInteractionEnabled = true
        
        self.learnMoreLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.learnMoreLabel)
        
        self.learnMoreLabel.topAnchor.constraint(equalTo: self.legend2.bottomAnchor, constant: UIDevice.isSmallerThaniPhone6 ? 10 : 20).isActive = true
        self.learnMoreLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.learnMoreLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        self.learnMoreLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showLearnMoreHint)))
        
        // Progress View
        
        self.hoursProgressView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.hoursProgressView)
        
        self.hoursProgressView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 0).isActive = true
        self.hoursProgressView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        
        self.hoursProgressView.action = { [unowned self] in
            self.selectHoursSlept()
        }
        
        // Status Bar Background
        
        self.statusBarBackgroundView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        self.statusBarBackgroundView.bottomAnchor.constraint(equalTo: self.hoursProgressView.bottomAnchor, constant: 0).isActive = true
        self.statusBarBackgroundView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        self.statusBarBackgroundView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        
        // Title Label
        
        self.titleLabel.text = "My Balance Pie"
        self.titleLabel.font = .muliLight(size: 24)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.titleLabel)
        
        self.titleLabel.topAnchor.constraint(equalTo: self.hoursProgressView.bottomAnchor, constant: 20).isActive = true
        self.titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        // Side Menu
        
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
        
        // Action Plan Button
        
        self.actionPlanButton.addTarget(self, action: #selector(showActionPlan), for: .touchUpInside)
        self.actionPlanButton.backgroundColor = .lightBlueBackground
        self.actionPlanButton.layer.cornerRadius = App.Appearance.buttonCornerRadius
        self.actionPlanButton.setTitle("See Action Plan", for: .normal)
        self.actionPlanButton.titleLabel?.font = UIFont.muliRegular(size: 20)
        
        self.view.addSubview(self.actionPlanButton)
        
        self.actionPlanButton.translatesAutoresizingMaskIntoConstraints = false
        self.actionPlanButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        self.actionPlanButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        self.actionPlanButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20).isActive = true
        self.actionPlanButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
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
    
    private func showImproveHint() {
        if Database.shared.user.activities.count >= 4 && !UserDefaults.standard.bool(forKey: "ImproveHintShown") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                guard let ss = self, ss.view.window != nil else {
                    return
                }
                
                var center = ss.view.center
                center.y += 80
                
                ss.improveHint = OnboardingPopover()
                
                ss.improveHint?.title = "Great job building your pie! \n\nDon't forget to start improving your slices. Tap a slice and select Improve Slice."
                ss.improveHint?.hasShadow = true
                ss.improveHint?.shadowColor = UIColor(white: 0, alpha: 0.4)
                ss.improveHint?.present(in: ss.view, at: center, from: .below)
                
                UserDefaults.standard.set(true, forKey: "ImproveHintShown")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
                    self?.dismissImproveHint()
                }
            }
        }
    }
    
    private func dismissImproveHint() {
        self.improveHint?.dismiss()
    }
    
    @objc private func showLearnMoreHint() {
        print("show learn more hint")
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
        
        alert.addAction(UIAlertAction(title: "Delete Slice", style: .destructive) { _ in
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
    
    @objc func showActionPlan() {
    
    }
    
    func plusAction() {
        self.dismissImproveHint()
        
        guard let addActivityVC = UIStoryboard(name: "AddCustom", bundle: nil).instantiateViewController(withIdentifier: "AddSliceViewController") as? AddSliceViewController else{
            assertionFailure()
            return
        }
        
        let navigation = UINavigationController(rootViewController: addActivityVC)
        self.present(navigation, animated: true)
    }
    
    func sliceAction(with activity: UserActivity) {
        self.dismissImproveHint()

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
    
    private func selectHoursSlept() {
        self.dismissImproveHint()
        
        let hours = Array(1...12)
        let minutes = [0,15,30,45]
        
        let hoursTexts = hours.labeledArray(with: "Hour")
        let minutesTexts = minutes.labeledArray(with: "Minute")
        let initialHours = Database.shared.user.timeSlept / 60
        let initialMinutes = Database.shared.user.timeSlept % 60
        
        let indexHours = hours.index(of: initialHours) ?? 0
        let indexMinutes = minutes.index(of: initialMinutes) ?? 0
        
        let picker = ActionSheetMultipleStringPicker(title: "Duration", rows: [hoursTexts, minutesTexts], initialSelection: [indexHours, indexMinutes], doneBlock: nil, cancel: nil, origin: UIButton())!
        
        picker.toolbarBackgroundColor = UIColor.groupTableViewBackground
        picker.toolbarButtonsColor = UIColor.darkBlueBackground
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        picker.pickerTextAttributes = [NSFontAttributeName: UIFont.muliLight(size: 18.0), NSParagraphStyleAttributeName: style]
        picker.titleTextAttributes = [NSFontAttributeName: UIFont.muliBold(size: 18.0)]
        
        picker.onActionSheetDone = { (picker, indexes, values) in
            guard let hourIndex = indexes?[0] as? Int, let minuteIndex = indexes?[1] as? Int else {
                assertionFailure()
                return
            }
            
            let hoursSelected = hours[hourIndex]
            let minutesSelected = minutes[minuteIndex]
            
            Database.shared.user.saveTimeSlept(hours: hoursSelected, minutes: minutesSelected)
            
            self.refreshHours()
        }
    
        picker.show()
    }
}
