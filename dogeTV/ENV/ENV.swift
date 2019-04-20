//
//  ENV.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/14.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Foundation

struct ENV {
    static let host = "https://tv.popeye.vip"
    static let resourceHost = "http://v.popeye.vip"
    static let dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! + "/dogetv.sqlite"
    static let dbVersion = "1.0.0"
}



