//
//  ExamplePopUpViewController.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 5/8/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

class ExamplePopUpViewController: UIViewController {
    
    enum ExampleNumber: Int {
        case one
        case two
    }
    
    var doneAction: ((String) -> ())?
    var textViewContent: TextViewContent?
    var exampleNumber: ExampleNumber = .one
    
    private var text = ""

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var exampleTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    private func setupView() {
        self.titleLabel.text = "Example \(self.exampleNumber.rawValue + 1)"
        if let textContent = self.textViewContent {
            
            self.text = (TextImprovementsExamples.instance.getImprovementExamplesFor(feeling: textContent.userActivity.feeling, improvementType: textContent.type)?[self.exampleNumber.rawValue])!
        }
        self.exampleTextView.text = self.text
    }
    
    //MARK - User Actions

    @IBAction func okAction(_ sender: Any) {
        self.doneAction?(self.text)
        self.mz_dismissFormSheetController(animated: true, completionHandler: nil)
    }
   
    @IBAction func closeAction(_ sender: Any) {
         self.mz_dismissFormSheetController(animated: true, completionHandler: nil)
    }
}
