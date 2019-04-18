//
//  Topic.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Foundation

struct Topic: Decodable, Equatable {
    let id: String
    let title: String
    let cover: String
    let tag: String
    let desc: String
    let updateAt: String
}

struct TopicDetail: Decodable {
    let topic: Topic
    let items: [Video]
}
