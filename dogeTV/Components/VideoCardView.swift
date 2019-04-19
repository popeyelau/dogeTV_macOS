//
//  VideoCardView.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/15.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class VideoCardView: NSCollectionViewItem {
    
    static let itemSize: NSSize = NSSize(width: 150, height: 240)
    static let smallSize: NSSize = NSSize(width: 150*0.75, height: 240*0.75)
    var data: Video? {
        didSet {
            guard let video = data else { return }
            textField?.stringValue = video.name
            imageView?.setResourceImage(with: video.cover)
            updatedLabel?.stringValue = video.state
        }
    }

    @IBOutlet weak var shadowView: NSView!
    @IBOutlet weak var updatedLabel: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        shadowView.wantsLayer = true
        shadowView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.35).cgColor
        shadowView.layer?.cornerRadius = 6
        shadowView.layer?.masksToBounds = true
        shadowView.layer?.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let trackingArea = NSTrackingArea(rect: view.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea)
    }

    override func mouseEntered(with event: NSEvent) {
        imageView?.alphaValue = 0.8
        textField?.textColor = .primaryColor
    }
    
    override func mouseExited(with event: NSEvent) {
        imageView?.alphaValue = 1
        textField?.textColor = .labelColor
    }

    
}
