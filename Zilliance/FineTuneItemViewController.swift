//
//  FineTuneItemViewController.swift
//  Zilliance
//
//  Created by Philip Dow on 4/14/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

class FineTuneItemViewController: UIViewController {
    @IBOutlet var textView: UITextView!
    var didLayout = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Fix text view not starting with text at top (!)
    // http://stackoverflow.com/questions/33979214/uitextview-text-starts-from-the-middle-and-not-the-top
    
    override func viewDidLayoutSubviews() {
        if self.didLayout == false {
            self.textView.setContentOffset(CGPoint.zero, animated: false)
            self.didLayout = true
        }
    }
}
