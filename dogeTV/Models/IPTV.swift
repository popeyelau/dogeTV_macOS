//
//  IPTV.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/30.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Foundation

struct IPTV: Decodable {
    let id: String
    let category: String
}

struct IPTVChannel: Decodable {
    let name: String
    let url: String
    let schedule: [String]?
}
