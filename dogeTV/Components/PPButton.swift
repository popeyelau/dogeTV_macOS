//
//  PPButton.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/16.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class PPButton: NSButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        focusRingType = .none
        let trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
        font = NSFont.systemFont(ofSize: 15)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if isSelected {
            let linePath = NSBezierPath()
            linePath.move(to: .zero)
            linePath.line(to: NSPoint(x: 0, y: dirtyRect.height))
            linePath.lineWidth = 5
            NSColor.primaryColor.set()
            linePath.stroke()
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            updateColor()
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        setAttributedString(title, color: .primaryColor)
    }
    
    override func mouseExited(with event: NSEvent) {
        updateColor()
    }

    func updateColor() {
        setAttributedString(title, color:  isSelected ? .primaryColor :  .secondaryLabelColor)
    }
}
