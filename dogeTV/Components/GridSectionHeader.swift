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
    @IBOutlet weak var indicatorView: NSView!
    @IBOutlet weak var moreButton: NSButton!
    
    var onMore: (() -> Void)?
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        wantsLayer = true
        layer?.backgroundColor = NSColor(srgbRed:0.12, green:0.12, blue:0.13, alpha:0.75).cgColor
        titleLabel.textColor = .labelColor
        
        
        indicatorView.wantsLayer = true
        indicatorView.layer?.backgroundColor = NSColor(srgbRed:0.88, green:0.88, blue:0.88, alpha:1.00).cgColor
    }
    
    @IBAction func moreAction(_ sender: NSButton) {
        onMore?()
    }
}
