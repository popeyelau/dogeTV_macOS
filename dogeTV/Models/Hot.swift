//
//  Hot.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Foundation

struct Hot: Decodable {
    let title: String
    let items: [Video]
}
