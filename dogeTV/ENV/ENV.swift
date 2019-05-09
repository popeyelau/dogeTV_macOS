//
//  ENV.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/14.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

struct ENV {
    static let host = "https://tv.popeye.vip"
    static let iconPath = NSApplication.shared.appFolder + "/logo.png"
}


enum StaticURLs: String {
    case githubRepo
    case telegramBot
    case github
    case telegram

    var url: URL {
        switch self {
        case .githubRepo:
            return URL(string: "https://github.com/popeyelau/dogeTV_macOS")!
        case .telegramBot:
            return URL(string: "https://t.me/dogeTVBot")!
        case .github:
            return URL(string: "https://github.com/popeyelau")!
        case .telegram:
            return URL(string: "https://t.me/popeyelau")!
        }
    }
}


extension NSNotification.Name {
    static let playStatusChanged = NSNotification.Name.init("PlayStatusChanged")
}


