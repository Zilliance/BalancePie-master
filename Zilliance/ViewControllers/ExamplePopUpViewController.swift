//
//  ExamplePopUpViewController.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 5/8/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

class ExamplePopUpViewController: UIViewController {
    
    

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var exampleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK - User Actions

    @IBAction func okAction(_ sender: Any) {
         self.mz_dismissFormSheetController(animated: true, completionHandler: nil)
    }
   
    @IBAction func closeAction(_ sender: Any) {
         self.mz_dismissFormSheetController(animated: true, completionHandler: nil)
    }
}
