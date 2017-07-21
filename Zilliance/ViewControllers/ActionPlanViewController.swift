//
//  ActionPlanViewController.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 11-07-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit
import SVProgressHUD

class ActionPlanViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate var notifications: [NotificationTableItemViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80
        self.tableView.separatorColor = UIColor.color(forRed: 249, green: 249, blue: 250, alpha: 1)
//        addTestingNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.notifications = NotificationsManager.sharedInstance.getNextNotifications()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addTestingNotifications() {

        SVProgressHUD.show(withStatus: "Loading test notifications")

        //first let's purge them all...
        
        let waitingGroup = DispatchGroup()
        
        //calendar notifications
                
        NotificationsManager.sharedInstance.purgeNotifications()
        
        waitingGroup.enter()

        let notification = Notification()
        notification.body = "Reduce the amount of time spent on social media by reading a book instead."
        notification.startDate = Date().addingTimeInterval(60 * 60 * 24 * 2)
        notification.type = .calendar
        
        NotificationsManager.sharedInstance.storeNotification(notification: notification) { (newNotification, error) in
//            waitingGroup.leave()
//
//            
//            waitingGroup.enter()
            
            let notificationC2 = Notification()
            notificationC2.body = "Plan a new trip."
            notificationC2.startDate = Date().addingTimeInterval(60 * 60 * 24 * 5)
            notificationC2.type = .calendar
            
            NotificationsManager.sharedInstance.storeNotification(notification: notificationC2) { (newNotification, error) in
                waitingGroup.leave()
                
            }
            
        }
        

        //local notifications

        
        waitingGroup.enter()

        LocalNotificationsHelper.shared.requestAuthorization(inViewController: self) { (authorized) in
            guard authorized else {
                waitingGroup.leave()

                return
            }
            
            let notificationL = Notification()
            notificationL.body = "Spend more time with my family"
            notificationL.startDate = Date().addingTimeInterval(60 * 60 * 24 * 3)
            notificationL.type = .local
            
            NotificationsManager.sharedInstance.storeNotification(notification: notificationL) { (newNotification, error) in
                
                waitingGroup.leave()
            }
            
            
            waitingGroup.enter()

            let notificationL2 = Notification()
            notificationL2.body = "Go the gym"
            notificationL2.startDate = Date().addingTimeInterval(-60 * 60 * 24 * 10)
            notificationL2.type = .local
            notificationL2.weekDays.append(DayObject(internalValue: .mon))
            notificationL2.weekDays.append(DayObject(internalValue: .wed))
            notificationL2.weekDays.append(DayObject(internalValue: .fri))
            notificationL2.recurrence = .weekly
            
            NotificationsManager.sharedInstance.storeNotification(notification: notificationL2) { (newNotification, error) in
                
                waitingGroup.leave()
            }
            
        }
        
        
        //let's wait, get the latest ones, and reload the table
        
        waitingGroup.notify(queue: DispatchQueue.main) { 
            
            SVProgressHUD.dismiss()
            
            self.notifications = NotificationsManager.sharedInstance.getNextNotifications()
            self.tableView.reloadData()
            
        }
        
    }
    
    @IBAction func close(_ sender: Any) {
        
        self.dismiss(animated: true)
        
    }


}

extension ActionPlanViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MeditationPlanCell", for: indexPath)
            return cell
            
        }
        else {
            
            let item = notifications[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActionPlanCell", for: indexPath) as! ActionPlanCell
            cell.configure(item: item)
            
            return cell
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : self.notifications.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            let notification = notifications[indexPath.row]
            NotificationsManager.sharedInstance.removeNotification(withId: notification.notificationId)
            
            self.notifications = NotificationsManager.sharedInstance.getNextNotifications()
            self.tableView.reloadData()
            
        }
    }
    
}

extension ActionPlanViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.section == 1 else {
            return
        }
        
        guard let notification = NotificationsManager.sharedInstance.getNotification(withId: notifications[indexPath.row].notificationId) else {
            assertionFailure()
            return
        }
        
        showNotificationView(notification: notification)

    }
    
    private func showNotificationView(notification: Notification) {
        
        guard let scheduler = UIStoryboard(name: "Schedule", bundle: nil).instantiateInitialViewController() as? ScheduleViewController else {
            assertionFailure()
            return
        }
        
        scheduler.preloadedNotification = notification
                
        self.navigationController!.pushViewController(scheduler, animated: true)
        
    }
}
