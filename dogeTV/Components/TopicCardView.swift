//
//  TopicCardView.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/5/6.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class TopicCardView: NSCollectionViewItem {

    override func viewDidLoad() {
        super.viewDidLoad()
        let trackingArea = NSTrackingArea(rect: imageView!.bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect, .assumeInside], owner: self, userInfo: nil)
        imageView?.addTrackingArea(trackingArea)
    }
    
    override func mouseEntered(with event: NSEvent) {
        imageView?.alphaValue = 0.8
    }
    
    override func mouseExited(with event: NSEvent) {
        imageView?.alphaValue = 1
    }
    
}
