//
//  Helpers.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/15.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

func attempt<T>(maximumRetryCount: Int = 3, delayBeforeRetry: DispatchTimeInterval = .seconds(2), _ body: @escaping () -> Promise<T>) -> Promise<T> {
    var attempts = 0
    func attempt() -> Promise<T> {
        attempts += 1
        return body().recover { error -> Promise<T> in
            guard attempts < maximumRetryCount else { throw error }
            return after(delayBeforeRetry).then(on: nil, attempt)
        }
    }
    return attempt()
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
    static let playStatusChanged = NSNotification.Name("PlayStatusChanged")
    static let webPlayerStartPlay =  NSNotification.Name("AVOutputDeviceDiscoverySessionAvailableOutputDevicesDidChangeNotification")
}

extension NSStoryboard.Name {
    static let main = "Main"
    static let about = "AboutWindow"
    static let preferences = "Preferences"
}

extension NSUserInterfaceItemIdentifier {
    static let queryOptionView = NSUserInterfaceItemIdentifier(rawValue: "QueryOptionView")
    static let queryOptionsKeyView = NSUserInterfaceItemIdentifier(rawValue: "QueryOptionsKeyView")
    static let videoCardView = NSUserInterfaceItemIdentifier(rawValue: "VideoCardView")
    static let gridSectionHeader = NSUserInterfaceItemIdentifier(rawValue: "GridSectionHeader")
    static let episodeItemView = NSUserInterfaceItemIdentifier(rawValue: "EpisodeItemView")
    static let videoIntroView = NSUserInterfaceItemIdentifier(rawValue: "VideoIntroView")
    static let channelCardView = NSUserInterfaceItemIdentifier(rawValue: "ChannelCardView")
    static let topicCardView = NSUserInterfaceItemIdentifier(rawValue: "TopicCardView")


    
    
}
