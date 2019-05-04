//
//  PlayStatusView.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/5/2.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

enum PlayStatus {
    case idle
    case playing(title: String, isLive: Bool)
}

class PlayStatusView: NSView, LoadableNib {
    @IBOutlet var contentView: NSView!
    @IBOutlet weak var playBtn: NSButton!
    @IBOutlet weak var closeBtn: NSButton!
    @IBOutlet weak var scrollTextLabel: ScrollingTextView!
    var status: PlayStatus = .idle {
        didSet {
            switch status {
            case .idle:
                scrollTextLabel.setup(string: "")
                isHidden = true
                break
            case .playing(let title, _):
                isHidden = false
                scrollTextLabel.setup(string: title)
                break
            }
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        setup()
    }

    override func mouseDown(with event: NSEvent) {
        openPlayerWindow()
    }
    @IBAction func playBtnAction(_ sender: NSButton) {
        openPlayerWindow()
    }

    func openPlayerWindow() {
        if case let PlayStatus.playing(_, isLive) = status {
            NSApplication.shared.openPlayerWindow(isLive: isLive)
        }
    }

    func setup() {
        wantsLayer = true
        layer?.cornerRadius = 15
        layer?.masksToBounds = true
        layer?.backgroundColor = NSColor.activedBackgroundColor.cgColor
        playBtn.contentTintColor = .primaryColor
        closeBtn.contentTintColor = .primaryColor
        scrollTextLabel.setup(string: "")
        scrollTextLabel.spacing = 10
        setTrackingArea(to: bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect, .assumeInside])
    }

    @IBAction func stopAction(_ sender: NSButton) {
        if case let PlayStatus.playing(_, isLive) = status {
            NSApplication.shared.closePlayerWindow(isLive: isLive)
        }
    }

    override func mouseEntered(with event: NSEvent) {
        NSCursor.pointingHand.set()
    }

    override func mouseExited(with event: NSEvent) {
        NSCursor.arrow.set()
    }
}


