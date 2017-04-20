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
            
            self.present(navigationController, animated: true)
        }
    }
    
    @IBAction func privacyPolicyTapped(_ sender: Any) {
        showHTMLView(htmlFile: "zilliance privacy policy", title: "Privacy Policy")
    }
    
    @IBAction func termsOfServicesTapped(_ sender: Any) {
        showHTMLView(htmlFile: "zilliance privacy policy", title: "Waiting for HTML")
    }
    
    
}
