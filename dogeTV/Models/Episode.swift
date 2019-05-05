//
//  Episode.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Foundation

let videoStreamExtensions = ["m3u8", "mp4", "avi", "mov", "mkv"]

struct Episode: Decodable, Equatable {
    let title: String
    var url: String
    
    var canPlay: Bool {
        guard let fileExtension = URL(string: url)?.pathExtension else {
            return false
        }
        return videoStreamExtensions.contains(fileExtension)
    }
    
    static func == (lhs: Episode, rhs: Episode) -> Bool {
        return lhs.url == rhs.url
    }
}

struct VideoSource: Equatable, Hashable {
    let source: Int
    let isSelected: Bool
}
