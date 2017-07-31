//
//  IntroViewController.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 7/6/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

fileprivate let tourURL = URL(string: "balancepie://tour")!
fileprivate let videoURL = URL(string: "balancepie://video")!

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
        
        self.linkIntroText()
    }
    
    func linkIntroText() {
        let attrText = self.textView.attributedText.mutableCopy() as! NSMutableAttributedString
        
        let tourAttributes: [String: Any] = [
            NSFontAttributeName: UIFont.muliItalic(size: 13),
            NSForegroundColorAttributeName: UIColor.lightBlueBackground,
            NSLinkAttributeName: tourURL
        ]
        let videoAttributes: [String: Any] = [
            NSFontAttributeName: UIFont.muliItalic(size: 13),
            NSForegroundColorAttributeName: UIColor.lightBlueBackground,
            NSLinkAttributeName: videoURL
        ]
        
        let tourRange = (attrText.string as NSString).range(of: "Tour")
        let videoRange = (attrText.string as NSString).range(of: "Balance Pie video")
        
        if tourRange.location != NSNotFound {
            attrText.addAttributes(tourAttributes, range: tourRange)
        } else {
            assertionFailure()
        }
        
        if videoRange.location != NSNotFound {
            attrText.addAttributes(videoAttributes, range: videoRange)
        } else {
            assertionFailure()
        }
        
        self.textView.attributedText = attrText
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
    
    @IBAction func showTour() {
        guard let onboarding = UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController() as? OnboardingPageViewController else {
            assertionFailure()
            return
        }
        
        onboarding.presentationType = .fromFaq // same as from tour
        
        let navigationController = CustomNavigationController(rootViewController: onboarding)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func showVideo() {
        guard let video  = UIStoryboard(name: "VideoPlayer", bundle: nil).instantiateInitialViewController() as? UINavigationController else {
            assertionFailure()
            return
        }
        
        (video.topViewController as? VideoPlayerViewController)?.presentationMode = .faq
        self.present(video, animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate

extension IntroViewController : UITextViewDelegate {
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if URL == tourURL {
            self.showTour()
        } else if URL == videoURL {
            self.showVideo()
        }
        
        return false
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        if URL == tourURL {
            self.showTour()
        } else if URL == videoURL {
            self.showVideo()
        }
        
        return false
    }
}
