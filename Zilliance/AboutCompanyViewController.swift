//
//  AboutCompanyViewController.swift
//  Zilliance
//
//  Created by Philip Dow on 4/28/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

class AboutCompanyViewController: UIViewController {
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        
        let attributes: [String: Any] = [
            NSParagraphStyleAttributeName : style,
            NSFontAttributeName: self.textView.font!,
            NSForegroundColorAttributeName: UIColor.darkBlueBackground
        ]
        
        self.textView.attributedText = NSAttributedString(string: self.textView.text, attributes:attributes)
        self.textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
        self.textView.backgroundColor = .lightGrayBackground
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backTapped() {
        self.sideMenuController?.toggle()
    }

}
