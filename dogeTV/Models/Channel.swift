//
//  Channel.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/3.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Foundation

struct Channel: Decodable {
    let name: String
    let icon: String
    let url: String
}

struct ChannelGroup: Decodable {
    let categoryName: String
    let channels: [Channel]
}


enum TV: Int, CaseIterable {
    case iptv
    case hwtv

    var title: String {
        switch self {
        case .iptv:
            return "联通IPTV"
        case .hwtv:
            return "华文电视"
        }
    }

    var key: String {
        switch self {
        case .iptv:
            return "iptv"
        case .hwtv:
            return "hwtv"
        }
    }
    
    func next() -> TV {
        var next = rawValue + 1
        if next > TV.allCases.last!.rawValue { next = 0 }
        return TV(rawValue: next)!
    }
}
