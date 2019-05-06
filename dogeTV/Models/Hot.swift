//
//  Hot.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

struct Hot: Decodable {
    let title: String
    let width: CGFloat
    let height: CGFloat
    let items: [Video]
}
