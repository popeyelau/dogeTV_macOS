//
//  GradientView.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/5/2.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class GradientView: NSView {

    var colors: [NSColor] = [.backgroundColor, NSColor.black.withAlphaComponent(0.65)] {
        didSet {
            needsDisplay = true
        }
    }

    var angle: CGFloat = 90 {
        didSet {
            needsDisplay = true
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let gradient = NSGradient(colors: colors)
        gradient?.draw(in: dirtyRect, angle: angle)
        // Drawing code here.
    }
    
}
