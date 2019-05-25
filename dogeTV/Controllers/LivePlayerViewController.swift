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
    @IBOutlet weak var titleView: NSView!

    @IBOutlet weak var guidesBtn: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.window?.delegate = self
        titleView.wantsLayer = true
        titleView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.75).cgColor
        play()
    }

    func play() {
        guard let channel = channel, let url = URL(string: channel.url) else { return }
        titleLabel.stringValue = channel.name
        if avPlayer.player == nil {
            avPlayer.player = AVPlayer(url: url)
        } else {
            avPlayer.player?.replaceCurrentItem(with: nil)
            avPlayer.player?.replaceCurrentItem(with: AVPlayerItem(url: url))
        }
        guidesBtn.isHidden = channel.schedule?.isEmpty == true
        avPlayer.player?.play()
        let status = PlayStatus.playing(title: channel.name, isLive: true)
        NotificationCenter.default.post(name: .playStatusChanged, object: status)
    }

    @IBAction func openMainWindowAction(_ sender: NSButton) {
        NSApplication.shared.openMainWindow()
    }
    
    @IBAction func guidesBtnActon(_ sender: NSButton) {
        guard let guides = channel?.schedule, !guides.isEmpty else {
            return
        }
        let target = ChannelGuidesViewController(guides: guides)
        present(target, asPopoverRelativeTo: sender.bounds, of: sender, preferredEdge: .maxY, behavior: .transient)
    }
}

extension LivePlayerViewController: NSWindowDelegate {
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.delegate = self
    }
    
    func windowWillClose(_ notification: Notification) {
        avPlayer.player?.replaceCurrentItem(with: nil)
        NotificationCenter.default.post(name: .playStatusChanged, object: PlayStatus.idle)
        NSApplication.shared.openMainWindow()
    }
}
