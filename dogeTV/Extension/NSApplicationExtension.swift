//
//  NSApplicationExtension.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/24.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

extension NSApplication {

    var appDelegate: AppDelegate? {
        return NSApplication.shared.delegate as? AppDelegate
    }

    func checkForUpdates(background: Bool = false) {
        guard let appDelegate = appDelegate else { return }
        if background {
            appDelegate.updater.checkForUpdatesInBackground()
            return
        }
        appDelegate.updater.checkForUpdates(nil)
    }

    func openMainWindow() {
        appDelegate?.mainWindowController?.window?.makeKeyAndOrderFront(nil)
    }

    func openPlayerWindow(isLive: Bool = false) {
        let type = isLive ? LivePlayerViewController.self : PlayerViewController.self
        let playerWindow = NSApplication.shared.windows.first {
            $0.contentViewController?.isKind(of: type) == true
        }
        playerWindow?.makeKeyAndOrderFront(nil)
    }

    func closePlayerWindow(isLive: Bool = false) {
        let type = isLive ? LivePlayerViewController.self : PlayerViewController.self
        let playerWindow = NSApplication.shared.windows.first {
            $0.contentViewController?.isKind(of: type) == true
        }
        playerWindow?.close()
    }
    
    var appFolder: String {
       return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! + "/.dogeTV"
    }
}
