//
//  NSButtonExtension.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/16.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import AppKit

extension NSButton {
    func setAttributedString(_ string: String, color: NSColor) {
        attributedTitle = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: color])
    }
}
