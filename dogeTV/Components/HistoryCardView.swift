//
//  HistoryCardView.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/20.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class HistoryCardView: NSCollectionViewItem {
    static let itemSize: NSSize = NSSize(width: 135, height: 216)
    static let smallSize: NSSize = NSSize(width: 112.5, height: 180)
    var data: History? {
        didSet {
            guard let history = data else { return }
            textField?.stringValue = "\(history.name)(\(history.episodeName))"
            imageView?.setResourceImage(with: history.cover)
            updatedLabel.stringValue = secondsToTimeString(seconds: Int(history.currentTime))
            imageView?.toolTip = textField?.stringValue
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
    
    func secondsToTimeString(seconds : Int) -> String {
        if seconds < 60 {
            return "观看不足一分钟"
        }
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 {
            return "观看至\(hours)小时\(minutes)分钟"
        }
        return "观看至\(minutes)分钟"
    }
}
