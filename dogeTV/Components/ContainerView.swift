//
//  ContainerView.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/18.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class ContainerView: NSView {
    override func addSubview(_ view: NSView) {
        super.addSubview(view)
        view.snp.remakeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
