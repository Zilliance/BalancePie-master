//
//  VideoPlayerViewController.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 5/1/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit
import YouTubePlayer

class VideoPlayerViewController: UIViewController {
    

    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Video"
        self.youtubePlayer.loadVideoID("df-bjimboXc")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.youtubePlayer.stop()

    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.sideMenuController?.toggle()
    }
}
