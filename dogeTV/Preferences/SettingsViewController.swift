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
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.backgroundColor.cgColor

        iinaBtn.state = Preferences.shared.get(key: .usingIINA, default: false) ? .on : .off
        hdBtn.state = Preferences.shared.get(key: .searchHD, default: false) ? .on : .off
        iinaBtn.isEnabled = NSApplication.shared.isIINAInstalled
    }
    
    @IBAction func iinaBtnAction(_ sender: NSButton) {
       Preferences.shared.set(sender.state == .on, for: .usingIINA)
    }
    
    @IBAction func hdBtnAction(_ sender: NSButton) {
        Preferences.shared.set(sender.state == .on, for: .searchHD)
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
    
    
    func get<T>(key: PreferenceKeys, default: T) -> T {
        return prefs.value(forKey: key.rawValue) as? T ?? `default`
    }
    
    func set<T>(_ value: T, for key: PreferenceKeys) {
        prefs.setValue(value, forKey: key.rawValue)
        prefs.synchronize()
    }
    
    /*
    var usingIINA: Bool {
        get {
            return get(key: .usingIINA, default: false)
        }
        set {
            set(newValue, for: .usingIINA)
        }
    }
    
    var searchHD: Bool {
        get {
            return get(key: .searchHD, default: false)
        }
        set {
            set(newValue, for: .searchHD)
        }
    }

    var unlocked: Bool {
        get {
            return get(key: .unlocked, default: false)
        }
        set {
            set(newValue, for: .unlocked)
        }
    }*/
}


enum PreferenceKeys: String {
    case usingIINA
    case searchHD
    case unlocked = "UNLOCKED"
}

