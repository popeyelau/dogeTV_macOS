//
//  Episode.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Foundation

struct Episode: Decodable, Equatable {
    let title: String
    let url: String
    
    var canPlay: Bool {
        return url.hasSuffix(".m3u8")
            || url.hasSuffix(".m3u")
            || url.hasSuffix(".mp4")
            || url.hasSuffix(".avi")
    }
    
    static func == (lhs: Episode, rhs: Episode) -> Bool {
        return lhs.url == rhs.url
    }
}

struct VideoSource: Equatable, Hashable {
    let source: Int
    let isSelected: Bool
}
