//
//  Video.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/16.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Foundation

enum VideoSource: Int, Codable {
    case other = 0
    case pumpkin
    case blueray
}

struct Video: Decodable, Equatable {
    let id: String
    let name: String
    let actor: String
    let director: String
    let cover: String
    let desc: String
    let area: String
    let year: String
    let tag: String
    let score: String
    let state: String
    let source: Int

}

struct VideoDetail: Decodable {
    let info: Video
    let recommends: [Video]?
    let seasons: [Seasons]?
}

struct Seasons: Decodable {
    let id: String
    let name: String
    let episodes: [Episode]?
}


struct VideoCategory: Decodable {
    var query: [OptionSet]?
    let items: [Video]
    
    static let sections = ["新近影视推荐", "最新开播电视剧", "最新开播综艺", "最新番动漫"]
}
