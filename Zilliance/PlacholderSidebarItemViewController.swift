//
//  PlacholderSidebarItemViewController.swift
//  Zilliance
//
//  Created by Philip Dow on 4/28/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

class PlacholderSidebarItemViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backTapped() {
        self.sideMenuController?.toggle()
    }

}
