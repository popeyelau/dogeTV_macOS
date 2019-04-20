//
//  EmptyView.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/20.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class EmptyView: NSView, LoadableNib {

    @IBOutlet var contentView: NSView!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        setup()
    }

    func setup() {

    }
    
}
