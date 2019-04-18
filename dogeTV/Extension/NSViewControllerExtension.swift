//
//  NSViewControllerExtension.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import PromiseKit

extension NSViewController {
    func showVideo(id: String, indicatorView: NSProgressIndicator? = nil) {
        indicatorView?.isHidden = false
        indicatorView?.startAnimation(nil)
        attempt(maximumRetryCount: 3) {
            when(fulfilled: APIClient.fetchVideo(id: id),
                 APIClient.fetchEpisodes(id: id))
            }.done { detail, episodes in
                let window = AppWindowController(windowNibName: "AppWindowController")
                let content = PlayerViewController()
                content.videDetail = detail
                content.episodes = episodes
                window.content = content
                window.show(from:self.view.window)
            }.catch{ error in
                print(error)
                self.showError(error)
            }.finally {
                indicatorView?.stopAnimation(nil)
                indicatorView?.isHidden = true
        }
    }

    func showError(_ error: Error) {
        /*
        let alert: NSAlert = NSAlert()
        alert.messageText = "出错啦"
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()*/
    }
}
