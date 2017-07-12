//
//  IntroViewController.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 7/6/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {

    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageHeightContraint: NSLayoutConstraint!
    
    var didLayout = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.continueButton.layer.cornerRadius = App.Appearance.buttonCornerRadius
        if UIDevice.isSmallerThaniPhone6 {
            self.imageHeightContraint.constant = 175
            self.textView.font = UIFont.muliSemiBold(size: 14)
        }
    }
    
    
    // Fix text view not starting with text at top (!)
    // http://stackoverflow.com/questions/33979214/uitextview-text-starts-from-the-middle-and-not-the-top
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.didLayout == false {
            self.textView.setContentOffset(CGPoint.zero, animated: false)
            self.didLayout = true
        }
    }
    
    @IBAction func continueAction(_ sender: UIButton) {
        
        guard let viewController = UIStoryboard(name: "FavoriteActivity", bundle: nil).instantiateInitialViewController()
            else {
                assertionFailure()
                return
        }
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
}
