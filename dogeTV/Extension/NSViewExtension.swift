//
//  NSViewExtension.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

protocol LoadableNib {
    var contentView: NSView! { get }
}

extension LoadableNib where Self: NSView {
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = NSNib(nibNamed: .init(String(describing: type(of: self))), bundle: bundle)!
        _ = nib.instantiate(withOwner: self, topLevelObjects: nil)
        
        let contentConstraints = contentView.constraints
        contentView.subviews.forEach({ addSubview($0) })
        for constraint in contentConstraints {
            let firstItem = (constraint.firstItem as? NSView == contentView) ? self : constraint.firstItem
            let secondItem = (constraint.secondItem as? NSView == contentView) ? self : constraint.secondItem
            addConstraint(NSLayoutConstraint(item: firstItem as Any,
                                             attribute: constraint.firstAttribute,
                                             relatedBy: constraint.relation,
                                             toItem: secondItem,
                                             attribute: constraint.secondAttribute,
                                             multiplier: constraint.multiplier,
                                             constant: constraint.constant))
        }
    }
}



extension NSView {
    func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: CAAnimationDelegate? = nil) {
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        if let delegate = completionDelegate {
            rotate.delegate = delegate
        }
        rotate.fromValue = 0.0
        rotate.toValue = CGFloat(.pi * 2.0)
        rotate.duration = duration
        self.layer?.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.layer?.add(rotate, forKey: nil)
    }
    
    static var defaultAnimationDuration: TimeInterval {
        return 0.5
    }
    
    static var defaultAnimationTimingFunction: CAMediaTimingFunction {
        return CAMediaTimingFunction(name: .easeInEaseOut)
    }
    
    static func animate(duration: TimeInterval = defaultAnimationDuration,
                        timingFunction: CAMediaTimingFunction = defaultAnimationTimingFunction,
                        animations: () -> Void,
                        completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup({ context in
            context.allowsImplicitAnimation = true
            
            context.duration = duration
            context.timingFunction = timingFunction
            
            animations()
        }, completionHandler: completion)
    }
    
    // Convenience method for trailing closure syntax without completion handler
    static func animate(duration: TimeInterval = defaultAnimationDuration,
                        timingFunction: CAMediaTimingFunction = defaultAnimationTimingFunction,
                        animations: () -> Void) {
        animate(duration: duration, timingFunction: timingFunction, animations: animations, completion: nil)
    }
    
    
    @discardableResult func setTrackingArea(to rect: NSRect,
                                                   options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeInKeyWindow])
        -> NSTrackingArea {
            resetTrackingAreas()
            
            let trackingArea = NSTrackingArea(rect: rect, options: options, owner: self, userInfo: nil)
            
            addTrackingArea(trackingArea)
            
            return trackingArea
    }
    
    func resetTrackingAreas() {
        trackingAreas.forEach { removeTrackingArea($0) }
    }
        
}


extension NSProgressIndicator {
    func show() {
        isHidden = false
        startAnimation(nil)
    }

    func dismiss() {
        isHidden = true
        stopAnimation(nil)
    }
}
