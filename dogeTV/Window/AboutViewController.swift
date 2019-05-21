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
        appIconButton.focusRingType = .none
        appIconButton.image = NSApp.applicationIconImage
        if let infoDictionary = Bundle.main.infoDictionary {
            if let name = infoDictionary["CFBundleName"] as? String {
                appNameLabel.stringValue = name
            }
            if let version = infoDictionary["CFBundleShortVersionString"] as? String, let build = infoDictionary[String(kCFBundleVersionKey)] as? String {
                appVersionLabel.stringValue = "Version \(version)(\(build))"
            }
        }

    }
    
    @IBAction func openURL(_ sender: NSButton) {
        openURL(with: sender)
    }
}


extension NSCollectionView {
    open override var mouseDownCanMoveWindow: Bool {
        return true
    }
}
