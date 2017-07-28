//
//  FineTuneItemViewController.swift
//  Zilliance
//
//  Created by Philip Dow on 4/14/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit
import MZFormSheetController

class FineTuneItemViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView?
    
    var zUserActivity: UserActivity?
    var item: FineTuneItem?
    
    @available(*,deprecated)
    @IBOutlet var textView: UITextView?
    @available(*,deprecated)
    var didLayout = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Fix text view not starting with text at top (!)
    // http://stackoverflow.com/questions/33979214/uitextview-text-starts-from-the-middle-and-not-the-top
    
    @available(*,deprecated)
    override func viewDidLayoutSubviews() {
        if self.didLayout == false {
            self.textView?.setContentOffset(CGPoint.zero, animated: false)
            self.didLayout = true
        }
    }
    
    // MARK: -
    
    @IBAction func showFirstExample(_ sender: Any?) {
        self.showExample(0)
    }
    
    @IBAction func showSecondExample(_ sender: Any?) {
        self.showExample(1)
    }
    
    private func showExample(_ number: Int) {
        guard let exampleViewController = UIStoryboard(name: "ExamplePopUp", bundle: nil).instantiateInitialViewController() as? ExamplePopUpViewController else {
            assertionFailure()
            return
        }
        
        guard let item = item, let userActivity = self.zUserActivity else {
            assertionFailure()
            return
        }
        
        exampleViewController.textViewContent = TextViewContent(userActivity: userActivity, type: item.type)
        exampleViewController.exampleNumber = ExamplePopUpViewController.ExampleNumber(rawValue: number)!
        
        let formSheet = MZFormSheetController(viewController: exampleViewController)
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.presentedFormSheetSize = CGSize(width: 300, height: 400)
        formSheet.transitionStyle = .bounce
        
        self.mz_present(formSheet, animated: true, completionHandler: nil)
    }
}
