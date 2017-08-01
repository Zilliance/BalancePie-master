//
//  ScheduleViewController.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 7/11/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol NotificationEditor {
    func getNotification() -> Notification?
}

class ScheduleViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var notifyMeButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var preloadedNotification: Notification?
    
    fileprivate enum ViewControllerSegments: Int {
        case notification = 0
        case calendar
    }
    
    var textViewContent: TextViewContent?
    
    fileprivate var currentViewController: UIViewController?
    
    fileprivate var viewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadViewControllers()
        self.setupView()
        self.segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        if let preloadedNotification = preloadedNotification, preloadedNotification.type == .calendar {
            self.showViewController(controller: viewControllers.last!)
            self.segmentedControl.selectedSegmentIndex = 1
        }
        else {
            self.showViewController(controller: viewControllers.first!)
        }

    }
    
    private func loadViewControllers() {

        guard let notificationsViewController = UIStoryboard(name: "Schedule", bundle: nil).instantiateViewController(withIdentifier: "notification") as? ScheduleNotificationTableViewController,
        let calendarViewController = UIStoryboard(name: "Schedule", bundle: nil).instantiateViewController(withIdentifier: "calendar") as? AddToCalendarViewController
            else {
                assertionFailure()
            return
        }
        
        notificationsViewController.textViewContent = self.textViewContent
        calendarViewController.textViewContent = self.textViewContent
        
        notificationsViewController.preloadedNotification = self.preloadedNotification
        calendarViewController.preloadedNotification = self.preloadedNotification
        
        self.viewControllers.append(notificationsViewController)
        self.viewControllers.append(calendarViewController)
        
        
    }
    
    private func setupView() {
        
        self.segmentedControl.tintColor = UIColor.white
        self.segmentedControl.setTitleTextAttributes([NSFontAttributeName: UIFont.muliBold(size: 12.0), NSForegroundColorAttributeName: UIColor.switchBlueColor] , for: .selected)
        self.segmentedControl.setTitleTextAttributes([NSFontAttributeName: UIFont.muliBold(size: 12.0), NSForegroundColorAttributeName: UIColor.white] , for: .normal)
    }
    
    // MARK -- User Actions
    
    @objc func segmentChanged() {
        
        if self.segmentedControl.selectedSegmentIndex == ViewControllerSegments.notification.rawValue {
            self.showViewController(controller: self.viewControllers[0])
            self.notifyMeButton.setTitle("NOTIFY ME", for: .normal)
        }
        else {
            self.showViewController(controller: self.viewControllers[1])
            self.notifyMeButton.setTitle("ADD TO CALENDAR", for: .normal)
        }
        
    }
    fileprivate func showViewController(controller: UIViewController) {
        if (currentViewController != nil)
        {
            currentViewController?.willMove(toParentViewController: nil)
            currentViewController?.view.removeFromSuperview()
            currentViewController?.didMove(toParentViewController: nil)
        }
        
        controller.willMove(toParentViewController: self)
        self.containerView.addSubview(controller.view)
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
            ])
        
        controller.didMove(toParentViewController: self)
        
        currentViewController = controller
    }
    
    // MARK: - User Action

    @IBAction func notifyAction(_ sender: UIButton) {
        
        guard let notificationEditor = currentViewController as? NotificationEditor else {
            assertionFailure()
            return
        }
        
        guard let notification = notificationEditor.getNotification() else {
            self.showAlert(message: "Please fill the missing fields", title: nil)
            return
        }
        
        notification.associatedObjectId = self.textViewContent?.userActivity.id
        
        LocalNotificationsHelper.shared.requestAuthorization(inViewController: self) { (authorized) in
            
            guard authorized == true else {
                self.showAlert(message: "Please allow the app to send notifications", title: nil)
                return
            }
            
            self.notifyMeButton.isEnabled = false
            
            NotificationsManager.sharedInstance.storeNotification(notification: notification) { (notification, error) in
                
                if let error = error {
                    print(error)
                } else {
                    
                    let alert = notification?.type == .calendar ? "Added event to calendar" : "Added reminder"
                    
                    SVProgressHUD.setDefaultMaskType(.black)
                    SVProgressHUD.setMaximumDismissTimeInterval(1.0)
                    SVProgressHUD.showSuccess(withStatus: alert)
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }
            }
        }
        

        
    }
}
