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

    static var usingnPlayer: Bool {
        get { return UserDefaults.standard.bool(forKey: "nPlayer") }
        set { UserDefaults.standard.set(newValue, forKey: "nPlayer") }
    }

}



