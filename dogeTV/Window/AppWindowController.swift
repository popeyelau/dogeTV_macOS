//
//  AppWindowController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/16.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class AppWindowController: NSWindowController {

    var videDetail: VideoDetail?
    var episodes: [Episode]?

    var content: NSViewController?
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }

    func show(from: NSWindow? = nil) {
        //window?.backgroundColor = NSColor.black
        window?.isMovableByWindowBackground = true
        contentViewController = content
        if let from = from {
            window?.setFrame(from.frame, display: true)
        }
        window?.orderFront(nil)
    }
    
}
