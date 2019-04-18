//
//  CloudParse.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/9.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Foundation

struct CloudParse: Decodable {
    let title: String
    let episodes: [Episode]
}
