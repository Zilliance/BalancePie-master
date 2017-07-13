//
//  ScheduleViewController.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 7/11/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var notifyMeButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    fileprivate enum ViewControllerSegments: Int {
        case notification = 0
        case calendar
    }
    
    fileprivate var currentViewController: UIViewController?
    
    fileprivate var viewControllers: [UIViewController] = [UIStoryboard(name: "Schedule", bundle: nil).instantiateViewController(withIdentifier: "notification"), UIStoryboard(name: "Schedule", bundle: nil).instantiateViewController(withIdentifier: "calendar")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.showViewController(controller: viewControllers.first!)
        self.segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
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

    @IBAction func notifyAction(_ sender: UIButton) {
    }
}