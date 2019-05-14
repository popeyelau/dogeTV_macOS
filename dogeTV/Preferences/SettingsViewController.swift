//
//  SettingsViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/5/14.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {

    @IBOutlet weak var iinaBtn: NSButton!
    @IBOutlet weak var hdBtn: NSButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        iinaBtn.state = Preferences.shared.usingIINA ? .on : .off
        hdBtn.state = Preferences.shared.searchHD ? .on : .off
        
        iinaBtn.isEnabled = NSApplication.shared.isIINAInstalled
    }
    
    @IBAction func iinaBtnAction(_ sender: NSButton) {
       Preferences.shared.usingIINA = sender.state == .on
    }
    
    @IBAction func hdBtnAction(_ sender: NSButton) {
        Preferences.shared.searchHD = sender.state == .on
    }
    
    @IBAction func iinaHelpAction(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "https://iina.io/")!)
    }
}




class Preferences: NSObject {
    static let shared = Preferences()
    
    private override init() {
    }
    
    let prefs = UserDefaults.standard
    let keys = PreferenceKeys.self
    
    var usingIINA: Bool {
        get {
            return prefs.bool(forKey: PreferenceKeys.usingIINA.rawValue)
        }
        set {
            prefs.set(newValue, forKey: PreferenceKeys.usingIINA.rawValue)
        }
    }
    
    var searchHD: Bool {
        get {
            return prefs.bool(forKey: PreferenceKeys.searchHD.rawValue)
        }
        set {
            prefs.set(newValue, forKey: PreferenceKeys.searchHD.rawValue)
        }
    }
}


enum PreferenceKeys: String {
    case usingIINA
    case searchHD
}

