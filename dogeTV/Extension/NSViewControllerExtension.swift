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
    func showVideo(id: String, history: History? = nil, indicatorView: NSProgressIndicator? = nil) {
        indicatorView?.isHidden = false
        indicatorView?.startAnimation(nil)

        let source = history?.source ?? 0
        
        attempt(maximumRetryCount: 3) {
            when(fulfilled: APIClient.fetchVideo(id: id),
                 APIClient.fetchEpisodes(id: id, source: source))
            }.done { detail, episodes in
                let window = AppWindowController(windowNibName: "AppWindowController")
                let content = PlayerViewController()
                content.videDetail = detail
                content.episodes = episodes
                content.history = history
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

    func dialogOKCancel(question: String, text: String, handler: @escaping ((Bool) -> Void)) {
        let alert = NSAlert()
        alert.messageText = text
        alert.informativeText = question
        alert.alertStyle = .warning
        alert.addButton(withTitle: "确定")
        alert.addButton(withTitle: "取消")
        alert.beginSheetModal(for: view.window!) { (returnCode) in
            handler(returnCode == .alertFirstButtonReturn)
        }
    }

    func openURL(with sender: NSButton) {
        guard let identifier = sender.identifier?.rawValue,
            let url = URL(string: identifier) else { return }
        NSWorkspace.shared.open(url)
    }

}
