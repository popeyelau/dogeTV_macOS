//
//  DisablableScrollView.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/18.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class DisablableScrollView: NSScrollView {
    var isEnabled: Bool = true
    
    override func scrollWheel(with event: NSEvent) {
        if isEnabled {
            super.scrollWheel(with: event)
        }
        else {
            nextResponder?.scrollWheel(with: event)
        }
    }
}


class InvisibleScroller: NSScroller {

    override class var isCompatibleWithOverlayScrollers: Bool {
        return true
    }

    override class func scrollerWidth(for controlSize: NSControl.ControlSize, scrollerStyle: NSScroller.Style) -> CGFloat {
        return .leastNormalMagnitude
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        scrollerStyle = .overlay
        alphaValue = 0
    }
}
