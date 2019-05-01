//
//  AppWindowController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/16.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class AppWindowController: NSWindowController {


    var content: NSViewController?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        let customToolbar = NSToolbar()
        customToolbar.showsBaselineSeparator = false
        window?.titlebarAppearsTransparent = true
        window?.titleVisibility = .hidden
        window?.toolbar = customToolbar
    }

    func show(from: NSWindow? = nil) {
        window?.isMovableByWindowBackground = true
        contentViewController = content
        if let from = from {
            window?.setFrame(from.frame, display: true)
        }
        window?.makeKeyAndOrderFront(self)
    }
    

}
