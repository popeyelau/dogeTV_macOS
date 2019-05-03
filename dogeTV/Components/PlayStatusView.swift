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
    case playing(title: String)
}

class PlayStatusView: NSView, LoadableNib {
    @IBOutlet var contentView: NSView!
    @IBOutlet weak var playBtn: NSButton!
    @IBOutlet weak var nameLabel: NSTextField!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        setup()
    }

    override func mouseDown(with event: NSEvent) {
        NSApplication.shared.openPlayerWindow()
    }

    func setup() {
        wantsLayer = true
        layer?.cornerRadius = 15
        layer?.masksToBounds = true
        layer?.backgroundColor = NSColor.activedBackgroundColor.cgColor
        playBtn.contentTintColor = .primaryColor
    }
}


