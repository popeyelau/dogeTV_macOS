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

    // This is a simple toast, containing only a message
    public func showSpinning(message: String? = nil) {
        let t = makeSpinningToast(message: message)
        handleSpinningForDisplay(toast: t)
    }

    public func removeSpinning() {
        currentToast?.removeFromSuperview()
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
        toast.snp.makeConstraints { $0.center.equalToSuperview() }
        animateToastFade(toast)
    }

    func handleSpinningForDisplay(toast: NSView) {
        if let t = currentToast { t.removeFromSuperview() }
        currentToast = toast
        self.view.addSubview(toast)
        toast.snp.makeConstraints { $0.center.equalToSuperview() }
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

        m.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
            $0.width.greaterThanOrEqualTo(50)
            $0.width.lessThanOrEqualTo(300)
        }
        return v
    }

    func makeSpinningToast(message: String? = nil) -> NSView {
        let v = NSView()
        // Styling
        v.wantsLayer = true;
        v.layer = styleToast()
        v.layer?.opacity = 1
        v.translatesAutoresizingMaskIntoConstraints = false

        // Add message
        let m = createSpinning()
        m.translatesAutoresizingMaskIntoConstraints = false


        if let msg = message, !msg.isEmpty {
            let label = createTextLabel(message: msg)
            let vStack = NSStackView()
            vStack.orientation = .vertical
            vStack.alignment = NSLayoutConstraint.Attribute.centerX
            vStack.addArrangedSubview(m)
            vStack.addArrangedSubview(label)
            vStack.spacing = 8
            v.addSubview(vStack)
            label.snp.makeConstraints {
                $0.width.lessThanOrEqualTo(300)
                $0.width.greaterThanOrEqualTo(100)
            }
            vStack.snp.makeConstraints {
                $0.edges.equalToSuperview().inset(20)
            }

        } else {
            v.addSubview(m)
            m.snp.makeConstraints {
                $0.edges.equalToSuperview().inset(30)
            }
        }



        return v
    }
    
    // Toast type with image and title
    func makeToast(message: String, title: String, image: NSImage) -> NSView {
        let v = NSView()
        // Styling
        v.wantsLayer = true;
        v.layer = styleToast()
        
        let m = createTextLabel(message: message)
        let t = createTextLabel(message: title, fontSize: 16)
        image.size = NSSize(width: 50.0, height: 50.0)

        let i = NSImageView(image: image)

        // Setting constraints
        m.translatesAutoresizingMaskIntoConstraints = false
        t.translatesAutoresizingMaskIntoConstraints = false
        i.translatesAutoresizingMaskIntoConstraints = false
        v.translatesAutoresizingMaskIntoConstraints = false

        let hStack = NSStackView()
        hStack.orientation = .horizontal
        hStack.alignment = NSLayoutConstraint.Attribute.centerY
        hStack.distribution = .fill
        hStack.addArrangedSubview(i)
        i.snp.makeConstraints { $0.size.equalTo(36) }

        let vStack = NSStackView()
        vStack.orientation = .vertical
        vStack.alignment = NSLayoutConstraint.Attribute.left
        vStack.addArrangedSubview(t)
        vStack.addArrangedSubview(m)
        t.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(100)
            $0.width.lessThanOrEqualTo(300)
        }
        m.snp.makeConstraints {
            $0.width.lessThanOrEqualTo(300)
        }
        hStack.addArrangedSubview(vStack)

        v.addSubview(hStack)
        hStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
        return v
    }
    
    // Generate the message component of the toast
    func createTextLabel(message: String, fontSize: CGFloat = 14) -> NSTextField {
        let tf = NSTextField(frame: NSMakeRect(0, 0, 200, 17))
        tf.stringValue = message
        let stf = styleTextLabel(tf: tf, fontSize: fontSize)
        
        return stf
    }

    func createSpinning() -> NSProgressIndicator {
        let sp = NSProgressIndicator()
        sp.style = .spinning
        sp.startAnimation(nil)
        return sp
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
