//
//  NSImageViewExtension.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/15.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import AppKit
import Kingfisher

extension NSImageView {
    func setResourceImage(with url: String, placeholder: NSImage? = NSImage(named: "404")) {
        self.kf.setImage(with: URL(string: url.hasPrefix("http") ? url : "\(ENV.resourceHost)\(url)"),
                         placeholder: placeholder)
    }
}
