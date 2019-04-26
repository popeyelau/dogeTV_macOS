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
    static let dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! + "/dogetv.sqlite"
    static let iconPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! + "/logo.png"
    static let dbVersion = "1.0.0"
}



