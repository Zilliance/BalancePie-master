//
//  LeftMenuViewController.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 17-04-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import Foundation
import UIKit
import SideMenuController

enum TableViewRow: Int
{
    case howItWorks = 0
    case tour
    case videos
    
    func title(row: TableViewRow) -> String
    {
        switch self {
        case .howItWorks:
            return "How it works"
        case .tour:
            return "Tour"
        case .videos:
            return "Videos"
        }
    }
    
    static var count: Int{
        return 3
    }
}

final class LeftMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableViewRow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell")!
        
        if let row = TableViewRow(rawValue: indexPath.row)
        {
            cell.textLabel?.text = row.title(row: row)
            
            //add images
            cell.imageView?.image = UIImage(named: "driving")
            
        }
        
        return cell
    }
    
    func showHTMLView(htmlFile: String, title: String)
    {
        let htmlFilePath = Bundle.main.path(forResource: htmlFile, ofType: "html")
        let url = URL(fileURLWithPath: htmlFilePath!)
        
        if let webController = UIStoryboard(name: "WebView", bundle: nil).instantiateInitialViewController() as? WebViewController
        {
            webController.title = title
            webController.url = url
            
            let navigationController = UINavigationController(rootViewController: webController)
            
            self.sideMenuController?.embed(centerViewController: navigationController)
        }
    }
    
    var showingPie: Bool {
        guard let currentNavigation = self.sideMenuController?.centerViewController as? UINavigationController, currentNavigation.viewControllers.first is PieViewController
        else
        {
            return false
        }
        
        return true
    }
    
    func showPieView()
    {
        guard let sideMenu = self.sideMenuController else
        {
            assertionFailure()
            return
        }
        
        guard !self.showingPie else {
            self.sideMenuController?.toggle()
            return
        }
        
        let pieNavController = UIStoryboard(name: "Pie", bundle: nil).instantiateInitialViewController() as! UINavigationController
        
        sideMenu.embed(centerViewController: pieNavController, cacheIdentifier: "PieViewController")
    }
    
    @IBAction func pieButtonTapped()
    {
        showPieView()
    }
    
    @IBAction func privacyPolicyTapped(_ sender: Any) {
        showHTMLView(htmlFile: "zilliance privacy policy", title: "Privacy Policy")
    }
    
    @IBAction func termsOfServicesTapped(_ sender: Any) {
        showHTMLView(htmlFile: "zilliance terms of service", title: "Terms Of Service")
    }
    
    
}
