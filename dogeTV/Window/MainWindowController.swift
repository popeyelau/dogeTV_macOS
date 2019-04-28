//
//  MainWindowController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/24.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.isMovableByWindowBackground = true
        NSApplication.shared.checkForUpdates(background: true)
    }

}
