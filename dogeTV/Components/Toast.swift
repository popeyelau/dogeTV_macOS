//
//  toast.swift
//  toastKit
//
//  Created by Jacob Gold on 8/11/17.
//  Copyright © 2017 Jacob Gold. All rights reserved.
//
import Cocoa

// Keep track of existing toast, if there is one
fileprivate var currentToast: NSView?

// MARK: - External calls
extension NSViewController {
    // This makes a toast with an image, message, and title
    public func toast(message: String, title: String, image: NSImage) {
        let t = makeToast(message: message, title: title, image: image)
        handleToastForDisplay(toast: t)
    }
    
    // This is a simple toast, containing only a message
    public func toast(message: String) {
        let t = makeToast(message: message)
        handleToastForDisplay(toast: t)
    }
}


//////////////////////////////////////////////
// MARK: - Internal funcs
fileprivate extension NSViewController {
    // Adds the toast to whatever view is calling it, then dismisses it
    func handleToastForDisplay(toast: NSView) {
        // Deal with existing toast, if there is one
        if let t = currentToast { t.removeFromSuperview() }
        currentToast = toast
        
        self.view.addSubview(toast)
        
        toast.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        toast.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        animateToastFade(toast)
    }
    
    // Standard toast type, with message
    func makeToast(message: String) -> NSView {
        let v = NSView()
        // Styling
        v.wantsLayer = true;
        v.layer = styleToast()
        
        // Add message
        let m = createTextLabel(message: message)
        v.addSubview(m)
        
        // Constrain the views
        m.translatesAutoresizingMaskIntoConstraints = false
        v.translatesAutoresizingMaskIntoConstraints = false
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-20-[m]-20-|", options: .alignAllTop, metrics: nil, views: ["m" : m])
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[m]-20-|", options: .alignAllTop, metrics: nil, views: ["m" : m])
        let widthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "[m(>=50,<=300)]", options: .alignAllTop, metrics: nil, views: ["m" : m])
        let heightConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[m(>=17)]", options: .alignAllTop, metrics: nil, views: ["m" : m])
        
        NSLayoutConstraint.activate(hConstraints)
        NSLayoutConstraint.activate(vConstraints)
        NSLayoutConstraint.activate(widthConstraints)
        NSLayoutConstraint.activate(heightConstraints)
        
        
        return v
    }
    
    // Toast type with image and title
    func makeToast(message: String, title: String, image: NSImage) -> NSView {
        let v = NSView()
        // Styling
        v.wantsLayer = true;
        v.layer = styleToast()
        
        // Add message
        let m = createTextLabel(message: message)
        v.addSubview(m)
        
        // Add the title
        let t = createTextLabel(message: title, fontSize: 16)
        v.addSubview(t)
        
        // Add an image
        image.size = NSSize(width: 50.0, height: 50.0)
        let i = NSImageView(image: image)
        v.addSubview(i)
        
        // Setting constraints
        m.translatesAutoresizingMaskIntoConstraints = false
        t.translatesAutoresizingMaskIntoConstraints = false
        i.translatesAutoresizingMaskIntoConstraints = false
        v.translatesAutoresizingMaskIntoConstraints = false
        
        let h1Constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[i(50)]-5-[t(>=200,<=300)]-5-|", options: .alignAllTop, metrics: nil, views: ["t" : t, "i" : i])
        let h2Constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[m(>=200,<=400)]", options: .alignAllTop, metrics: nil, views: ["m" : m])
        let v1Constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[t(17)]-1-[m(>=17)]-5-|", options: .alignAllLeft, metrics: nil, views: ["t" : t, "m" : m])
        let v2Constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=5)-[i(50)]-(>=5)-|", options: .alignAllLeft, metrics: nil, views: ["i" : i])
        
        NSLayoutConstraint.activate(h1Constraints)
        NSLayoutConstraint.activate(h2Constraints)
        NSLayoutConstraint.activate(v1Constraints)
        NSLayoutConstraint.activate(v2Constraints)
        
        return v
    }
    
    // Generate the message component of the toast
    func createTextLabel(message: String, fontSize: CGFloat = 14) -> NSTextField {
        let tf = NSTextField(frame: NSMakeRect(0, 0, 200, 17))
        tf.stringValue = message
        let stf = styleTextLabel(tf: tf, fontSize: fontSize)
        
        return stf
    }
    
    
    //////////////////////////////////////////////
    // MARK: - Aesthetics
    
    // Style the toast
    func styleToast() -> CALayer {
        let toastLayer = CALayer()
        toastLayer.backgroundColor = NSColor.black.withAlphaComponent(0.9).cgColor
        toastLayer.cornerRadius = 8
        toastLayer.opacity = 0.0
        
        return toastLayer
    }
    
    // Style the message text
    func styleTextLabel(tf: NSTextField, fontSize: CGFloat) -> NSTextField {
        // Sizing
        var f = tf.frame
        f.size.height = tf.intrinsicContentSize.height
        tf.frame = f
        

        // Basic appearance jazz
        tf.textColor = NSColor.white
        tf.drawsBackground = false
        tf.isBordered = false
        tf.focusRingType = .none
        tf.isEditable = false
        tf.isSelectable = false
        tf.alignment = .left
        tf.font = NSFont.systemFont(ofSize: fontSize)
        
        return tf
    }
    
    // Animate fade out
    func animateToastFade(_ toast: NSView) {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "opacity"
        animation.values = [0, 0.8, 0.8, 0]
        animation.keyTimes = [0, 0.01, 0.8, 1]
        animation.duration = 3.0
        animation.isAdditive = true
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            toast.removeFromSuperview()
        }
        toast.layer?.add(animation, forKey: "opacity")
        CATransaction.commit()
    }
}
