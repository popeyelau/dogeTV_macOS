//
//  Menu.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/28.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Foundation

enum Menus: String, CaseIterable {
    case recommended
    case tag
    case latest
    case topic
    case film
    case drama
    case variety
    case cartoon
    case documentary
    case parse
    case live
    
    var title: String {
        switch self {
        case .recommended: return "推荐"
        case .latest: return "最新"
        case .tag: return "分类"
        case .topic: return "专题"
        case .film: return "电影"
        case .drama: return "电视剧"
        case .variety: return "综艺"
        case .cartoon: return "动漫"
        case .documentary: return "纪录片"
        case .parse: return "云解析"
        case .live: return "电视直播"
        }
    }
}
