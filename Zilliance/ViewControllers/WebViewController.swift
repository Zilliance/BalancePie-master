//
//  WebViewController.swift
//  Zilliance
//
//  Created by mac on 19-04-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import Foundation
import UIKit

final class WebViewController: UIViewController
{
    var url: URL! // this is to be set before loading the controller and it's not optional
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.loadRequest(URLRequest(url: self.url))
    }
    
    @IBAction func backTapped() {
        self.sideMenuController?.toggle()
    }
    
}
