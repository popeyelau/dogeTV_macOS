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
    static let dbPath = NSApplication.shared.appFolder + "/dogetv.sqlite"
    static let iconPath = NSApplication.shared.appFolder + "/logo.png"
    static let dbVersion = "1.0.2"
}


enum StaticURLs: String {
    case githubRepo
    case telegramBot
    case github

    var url: URL {
        switch self {
        case .githubRepo:
            return URL(string: "https://github.com/popeyelau/dogeTV_macOS")!
        case .telegramBot:
            return URL(string: "https://github.com/popeyelau/dogeTV_macOS")!
        case .github:
            return URL(string: "https://github.com/popeyelau")!
        }
    }

}



