//
//  ChannelCardView.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class ChannelCardView: NSCollectionViewItem {
    
    static let itemSize: NSSize = NSSize(width: 135, height: 100)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.cornerRadius = 10
        view.layer?.borderWidth = 1
        view.layer?.borderColor = NSColor.white.withAlphaComponent(0.1).cgColor
        
        let trackingArea = NSTrackingArea(rect: view.bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect, .assumeInside], owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea)
    }
    
    override func mouseEntered(with event: NSEvent) {
        view.layer?.borderColor = NSColor.white.withAlphaComponent(0.2).cgColor
    }
    
    override func mouseExited(with event: NSEvent) {
        view.layer?.borderColor = NSColor.white.withAlphaComponent(0.1).cgColor
    }
}
