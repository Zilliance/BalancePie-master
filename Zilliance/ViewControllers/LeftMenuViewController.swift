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

final class LeftMenuViewController: UIViewController {
    enum Row: Int {
        case howItWorks = 0
        case tour
        case videos
        case faq
        case spacer
        case about
        case company
    }
    
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .darkBlueBackground
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? UITableViewController {
            self.tableView = vc.tableView
            self.tableView.backgroundColor = .darkBlueBackground
            self.tableView.tableFooterView = UIView()
            self.tableView.delegate = self
        }
    }
    
    func showHTMLView(htmlFile: String, title: String) {
        let htmlFilePath = Bundle.main.path(forResource: htmlFile, ofType: "html")
        let url = URL(fileURLWithPath: htmlFilePath!)
        
        if let webController = UIStoryboard(name: "WebView", bundle: nil).instantiateInitialViewController() as? WebViewController {
            webController.title = title
            webController.url = url
            
            let navigationController = UINavigationController(rootViewController: webController)
            
            self.sideMenuController?.embed(centerViewController: navigationController)
        }
    }
    
    var showingPie: Bool {
        guard let currentNavigation = self.sideMenuController?.centerViewController as? UINavigationController, currentNavigation.viewControllers.first is PieViewController else {
            return false
        }
        
        return true
    }
    
    func showPieView() {
        guard let sideMenu = self.sideMenuController else {
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
    
    @IBAction func pieButtonTapped() {
        self.showPieView()
    }
    
    @IBAction func privacyPolicyTapped(_ sender: Any) {
        showHTMLView(htmlFile: "zilliance privacy policy", title: "Privacy Policy")
    }
    
    @IBAction func termsOfServicesTapped(_ sender: Any) {
        showHTMLView(htmlFile: "zilliance terms of service", title: "Terms Of Service")
    }
}

// MARK: - Table View Delegate

extension LeftMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch Row(rawValue: indexPath.row) {
        case .howItWorks?: fallthrough
        case .about?:
            return 30
        case .spacer?:
            return 20
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch Row(rawValue: indexPath.row) {
        case .howItWorks?: fallthrough
        case .about?: fallthrough
        case .spacer?:
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, tableView.frame.size.width)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
