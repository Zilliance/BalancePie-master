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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.continueButton.layer.cornerRadius = App.Appearance.buttonCornerRadius
        if UIDevice.isSmallerThaniPhone6 {
            self.imageHeightContraint.constant = 175
            self.textView.font = UIFont.muliSemiBold(size: 14)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.textView.scrollRangeToVisible(NSMakeRange(0, 0))
        
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
