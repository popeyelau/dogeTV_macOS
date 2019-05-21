//
//  GridSectionHeader.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/15.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class GridSectionHeader: NSView {
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var subTitleLabel: NSTextField!
    @IBOutlet weak var backBtn: NSButton!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        wantsLayer = true
        backBtn.isHidden = true
        layer?.backgroundColor = NSColor.backgroundColor.cgColor
    }
    
    @IBAction func backAction(_ sender: NSButton) {
        NSApplication.shared.rootViewController?.back()
    }
}
