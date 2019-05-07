//
//  Hot.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

enum ContentItemType: String, Decodable {
    case normal
    case series
    case topic

    var itemSize: NSSize {
        switch self {
        case .normal, .topic:
            return VideoCardView.itemSize
        case .series:
            return NSSize(width: 200, height: 100)
        }
    }
}

struct Hot: Decodable {
    let title: String
    let width: CGFloat
    let height: CGFloat
    let type: ContentItemType?
    let items: [Video]
}
