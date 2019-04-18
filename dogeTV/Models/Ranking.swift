//
//  Ranking.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Foundation

struct Ranking: Decodable, Equatable {
    let id: String
    let index: String
    let name: String
    let score: String
    let episode: String
    let hot: String
    let updateAt: String
    let url: String
}
