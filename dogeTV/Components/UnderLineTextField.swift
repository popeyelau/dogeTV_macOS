//
//  UnderLineTextField.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/5/10.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class UnderLineTextField: NSTextField {
    override func draw(_ dirtyRect: NSRect) {

        let bottomLine = NSBezierPath()
        var point = NSPoint.zero
        
        point.y = bounds.height - 0.5
        bottomLine.move(to: point)
        
        point.x += bounds.width
        bottomLine.line(to: point)
        
        bottomLine.lineWidth = 0.5
        NSColor.separatorColor.withAlphaComponent(0.1).set()
        bottomLine.stroke()
        
        super.draw(dirtyRect)

    }
}
