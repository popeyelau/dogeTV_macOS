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
        
//        if event.phase == .none {
//            nextResponder?.scrollWheel(with: event)
//            return
//        }
//        // Not horizontal
//        if abs(event.scrollingDeltaX) <= abs(event.scrollingDeltaY) {
//            nextResponder?.scrollWheel(with: event)
//            return
//        }
//
        if isEnabled {
            super.scrollWheel(with: event)
        }
        else {
            nextResponder?.scrollWheel(with: event)
        }
    }
    
    override func wantsScrollEventsForSwipeTracking(on axis: NSEvent.GestureAxis) -> Bool {
        return axis == .horizontal
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
