//
//  AboutWindowController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/20.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class AboutWindowController: NSWindowController {

    static let defaultController: AboutWindowController = {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("AboutWindow"), bundle:nil)
        guard let windowController = storyboard.instantiateInitialController() as? AboutWindowController else {
            fatalError("Storyboard inconsistency")
        }
        return windowController
    }()

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.isMovableByWindowBackground = true
        window?.appearance = NSAppearance(named: .darkAqua)
    }

}
