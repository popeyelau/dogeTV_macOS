//
//  EpisodeItemView.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/16.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class EpisodeItemView: NSCollectionViewItem {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.wantsLayer = true
        view.layer?.cornerRadius = 15
        view.layer?.masksToBounds = true
    }

    override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            updateColor()
        }
    }
    
    func updateColor() {
        if isSelected {
            textField?.textColor = .primaryColor
            view.layer?.backgroundColor = NSColor(red:0.18, green:0.19, blue:0.20, alpha:1.00).cgColor
        } else {
            textField?.textColor = .labelColor
            view.layer?.backgroundColor = NSColor.clear.cgColor
        }
    }

}
