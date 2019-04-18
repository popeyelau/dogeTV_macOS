//
//  QueryOptionView.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/16.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class QueryOptionView: NSCollectionViewItem {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.wantsLayer = true
        view.layer?.cornerRadius = 12
        
    }
    
    override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            if enabled {
                updateColor()
            }
        }
    }
    
    var enabled: Bool = true
    
    func updateColor() {
        if isSelected {
            textField?.textColor = .primaryColor
            view.layer?.backgroundColor = NSColor(srgbRed:0.31, green:0.31, blue:0.33, alpha:1.00).cgColor
        } else {
            textField?.textColor = .labelColor
            view.layer?.backgroundColor = NSColor.clear.cgColor
        }
    }
    
}
