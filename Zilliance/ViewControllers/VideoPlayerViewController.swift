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
    
    private func configureVideo() {
        let url = URL(string: "https://r4---sn-xuc-cvb6.googlevideo.com/videoplayback?ipbits=0&pl=22&sparams=dur,ei,expire,id,initcwndbps,ip,ipbits,itag,lmt,mime,mm,mn,ms,mv,pcm2,pl,ratebypass,requiressl,source,upn&id=o-AIcgTwf-lDMgBQFIs9Y3mAH3R74zZGpU_dSiNgJXG-G4&dur=841.189&itag=22&pcm2=no&key=cms1&ei=CJIHWeqqFemx-AOq8qDYCg&signature=549977E1742D21CC6D4A6ECCAF51ACBF25194931.8380980EC36BAA0E5551978C2D7CBE17CCCBC1C4&ip=201.244.241.160&upn=caVhb7-ztaM&source=youtube&requiressl=yes&mime=video%2Fmp4&expire=1493689960&ratebypass=yes&lmt=1472132367397935&cms_redirect=yes&mm=31&mn=sn-xuc-cvb6&ms=au&mt=1493668233&mv=m")
        if let movieURL = url {
            self.videoPlayer.player = AVPlayer(url: movieURL)
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.videoPlayer = segue.destination as! AVPlayerViewController
    }
}
