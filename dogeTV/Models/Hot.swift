//
//  Hot.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

enum HomeSectionType: String, Decodable {
    case normal
    case series
    case topic

    var itemSize: NSSize {
        switch self {
        case .normal:
            return VideoCardView.itemSize
        case .series:
            return NSSize(width: 250, height: 125)
        case .topic:
            return NSSize(width: 120, height: 240)
        }
    }
}

struct Hot: Decodable {
    let title: String
    let width: CGFloat
    let height: CGFloat
    let type: HomeSectionType?
    let items: [Video]
}
