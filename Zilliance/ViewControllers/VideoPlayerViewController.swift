//
//  VideoPlayerViewController.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 5/1/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class VideoPlayerViewController: UIViewController {
    
    private var videoPlayer: AVPlayerViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Video"
        self.configureVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoPlayer.player?.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
        self.videoPlayer.player?.pause()
    }
    
    private func configureVideo() {
        let url = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        if let movieURL = url {
            self.videoPlayer.player = AVPlayer(url: movieURL)
            self.videoPlayer.player?.play()
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.videoPlayer = segue.destination as! AVPlayerViewController
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.sideMenuController?.toggle()
    }
}
