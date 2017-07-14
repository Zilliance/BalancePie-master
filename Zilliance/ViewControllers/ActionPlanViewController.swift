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

        // Do any additional setup after loading the view.
        addTestingNotifications()
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
        
        NotificationsManager.sharedInstance.realmDB = Database.shared.realm
        
        NotificationsManager.sharedInstance.purgeNotifications()
        
        waitingGroup.enter()

        let notification = Notification()
        notification.body = "Reduce the amount of time spent on social media by reading a book instead."
        notification.startDate = Date().addingTimeInterval(180)
        notification.type = .calendar
        
        NotificationsManager.sharedInstance.storeNotification(notification: notification) { (newNotification, error) in
            waitingGroup.leave()

        }
        
        //local notifications

        
        waitingGroup.enter()

        LocalNotificationsHelper.shared.requestAuthorization(inViewController: self) { (authorized) in
            guard authorized else {
                waitingGroup.leave()

                return
            }
            
            let notification2 = Notification()
            notification2.body = "Spend more time with my family"
            notification2.startDate = Date().addingTimeInterval(-60 * 60 * 24 * 14)
            notification2.dateAdded = Date().addingTimeInterval(-60 * 60 * 24 * 14)
            notification2.type = .local
            notification2.weekDays.append(DayObject(internalValue: .mon))
            notification2.weekDays.append(DayObject(internalValue: .tue))
            notification2.recurrence = .weekly
            
            NotificationsManager.sharedInstance.storeNotification(notification: notification2) { (newNotification, error) in
                
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
        return self.notifications.count == 0 ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : self.notifications.count
    }
}
