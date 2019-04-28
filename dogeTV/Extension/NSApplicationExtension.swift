//
//  NSApplicationExtension.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/24.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

extension NSApplication {
    func checkForUpdates(background: Bool = false) {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
        if background {
            appDelegate.updater.checkForUpdatesInBackground()
            return
        }
        appDelegate.updater.checkForUpdates(nil)
    }
    
    var appFolder: String {
       return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! + "/.dogeTV"
    }
}
