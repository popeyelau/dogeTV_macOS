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
    
    var rootViewController: RootViewController? {
       return appDelegate?.mainWindowController?.contentViewController as? RootViewController
    }

    func unlocked() {
        Preferences.shared.set(true, for: .unlocked)
    }
    
    func relaunch(afterDelay seconds: TimeInterval = 0.5) -> Never {
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "sleep \(seconds); open \"\(Bundle.main.bundlePath)\""]
        task.launch()
        self.terminate(nil)
        exit(0)
    }
    
    func launchIINA(withURL url: String) {
        guard let escapedURL = url.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
            let url = URL(string: "iina://weblink?url=\(escapedURL)") else {
                return
        }
        NSWorkspace.shared.open(url)
    }

    var isDownieInstalled: Bool {
        return NSWorkspace.shared.fullPath(forApplication: "Downie 3") != nil
    }
    
    var isIINAInstalled: Bool {
        return NSWorkspace.shared.fullPath(forApplication: "IINA") != nil
    }
}
