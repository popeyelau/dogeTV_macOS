//
//  AppDelegate.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/15.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import GitHubUpdates
import AVKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var updater: GitHubUpdater!
    var mainWindowController: MainWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        Repository.createTables()
    }



    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NSApp.activate(ignoringOtherApps: false)
        if mainWindowController == nil {
            let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle:nil)
            guard let controller = storyboard.instantiateInitialController() as? MainWindowController else {
                fatalError("加载失败")
            }
            mainWindowController = controller
        }
        mainWindowController?.window?.makeKeyAndOrderFront(self)
        return true
    }

    @IBAction func about(_ sender: Any) {
        AboutWindowController.defaultController.window?.makeKeyAndOrderFront(self)
    }
    
    @IBAction func help(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/popeyelau/dogeTV_macOS")!)
    }


}

