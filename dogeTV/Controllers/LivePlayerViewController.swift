//
//  LivePlayerViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import AVKit

class LivePlayerViewController: NSViewController {
    var channel: IPTVChannel?
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var avPlayer: AVPlayerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        play()
    }

    func play() {
        guard let channel = channel, let url = URL(string: channel.url) else { return }
        titleLabel.stringValue = channel.name
        avPlayer.player = AVPlayer(url: url)
        avPlayer.player?.play()
    }
    
}
