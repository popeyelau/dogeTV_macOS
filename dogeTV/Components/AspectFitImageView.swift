//
//  AspectFitImageView.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/18.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class AspectFitImageView: NSImageView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    override var image: NSImage? {
        set {
            self.layer = CALayer()
            self.layer?.contentsGravity = .resizeAspectFill
            self.layer?.contents = newValue
            self.layer?.cornerRadius = 6
            self.layer?.masksToBounds = true
            self.layer?.backgroundColor = NSColor.black.cgColor
            super.image = newValue
        }

        get {
            return super.image
        }
    }
    
}
