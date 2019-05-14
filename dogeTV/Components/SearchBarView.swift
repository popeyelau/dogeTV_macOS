//
//  SearchBarView.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa


class SearchBarView: NSView, LoadableNib {
    @IBOutlet var contentView: NSView!
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var hdBtn: NSButton!
    @IBOutlet weak var searchBtn: NSButton!
    
    var onSearchAction: ((String) -> Void)?
    var onTopRatedAction: (() -> Void)?

    var isHD: Bool {
       return hdBtn?.state == .on
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    @IBAction func commitAction(_ sender: NSTextField) {
        window?.makeFirstResponder(nil)
        guard !sender.stringValue.isEmpty else { return }
        onSearchAction?(sender.stringValue)
    }
    
    @IBAction func topRatedAction(_ sender: NSButton) {
        window?.makeFirstResponder(nil)
        onTopRatedAction?()
    }
    
    @IBAction func searchAction(_ sender: NSButton) {
        window?.makeFirstResponder(nil)
        guard !textField.stringValue.isEmpty else { return }
        onSearchAction?(textField.stringValue)
    }
    
    @IBAction func hdBtnAction(_ sender: NSButton) {
        guard !textField.stringValue.isEmpty else { return }
        onSearchAction?(textField.stringValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        setup()
    }
    
    func setup() {
        wantsLayer = true
        layer?.cornerRadius = 15
        layer?.masksToBounds = true
        layer?.backgroundColor = NSColor.black.cgColor
        textField.focusRingType = .none
        textField.backgroundColor = .clear
        let attr = NSAttributedString(string: "搜索电影/电视剧/综艺/影人", attributes: [.foregroundColor: NSColor.lightGray, .font: textField.font!])
        textField.placeholderAttributedString = attr
        searchBtn.contentTintColor = .primaryColor
    }
}
