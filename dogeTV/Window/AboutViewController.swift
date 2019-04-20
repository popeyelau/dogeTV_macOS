//
//  AboutViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/20.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {
    @IBOutlet weak var appNameLabel: NSTextField!
    @IBOutlet weak var appVersionLabel: NSTextField!
    @IBOutlet weak var appIconButton: NSButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        appIconButton.image = NSApp.applicationIconImage
        if let infoDictionary = Bundle.main.infoDictionary {
            if let name = infoDictionary["CFBundleName"] as? String {
                appNameLabel.stringValue = name
            }
            if let version = infoDictionary["CFBundleShortVersionString"] as? String {
                appVersionLabel.stringValue = "Version \(version)"
            }
        }

        let trackingArea = NSTrackingArea(rect: appIconButton.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        appIconButton.addTrackingArea(trackingArea)
    }

    override func mouseEntered(with event: NSEvent) {
        appIconButton.rotate360Degrees()
    }

    @IBAction func openURL(_ sender: NSButton) {
        guard let identifier = sender.identifier?.rawValue,
            let url = URL(string: identifier) else { return }
        NSWorkspace.shared.open(url)
    }
}
