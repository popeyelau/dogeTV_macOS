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
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "确定")
        alert.addButton(withTitle: "取消")
        alert.beginSheetModal(for: view.window!) { (returnCode) in
            handler(returnCode == .alertFirstButtonReturn)
        }
    }

    func openURL(with sender: NSButton) {
        guard let identifier = sender.identifier?.rawValue,
            let url = StaticURLs(rawValue: identifier)?.url else { return }
        NSWorkspace.shared.open(url)
    }

}


// video handle
extension NSViewController {
    func preparePlayerWindow(video: VideoDetail, episodes: [Episode], history: History? = nil) {
        NSApplication.shared.appDelegate?.mainWindowController?.window?.performMiniaturize(nil)
        let playerWindow = NSApplication.shared.windows.first {
            $0.contentViewController?.isKind(of:PlayerViewController.self) == true
        }
        if let window = playerWindow, let controller = window.contentViewController as? PlayerViewController {
            controller.replace(id: video.info.id)
            window.makeKeyAndOrderFront(nil)
            return
        }
        let windowController = AppWindowController(windowNibName: "AppWindowController")
        let content = PlayerViewController()
        content.videDetail = video
        content.episodes = episodes
        content.history = history
        windowController.content = content
        windowController.show(from: view.window)
    }
    
    func showVideo(id: String, source: VideoSource = .other,  history: History? = nil, indicatorView: NSProgressIndicator? = nil) {
        indicatorView?.isHidden = false
        indicatorView?.startAnimation(nil)

        switch source {
        case .other:
            let source = history?.source ?? 0
            attempt(maximumRetryCount: 3) {
                when(fulfilled: APIClient.fetchVideo(id: id),
                     APIClient.fetchEpisodes(id: id, source: source))
                }.done { detail, episodes in
                    self.preparePlayerWindow(video: detail, episodes: episodes, history: history)
                }.catch{ error in
                    print(error)
                    self.showError(error)
                }.finally {
                    indicatorView?.dismiss()
            }
            break
        case .pumpkin:
            attempt(maximumRetryCount: 3) {
                APIClient.fetchPumpkin(id: id)
                }.done { detail in
                    guard let episodes = detail.seasons?.first?.episodes else {
                        self.fetchPumpkinStreamURL(video: detail)
                        return
                    }
                    self.preparePlayerWindow(video: detail, episodes: episodes)
                }.catch{ error in
                    print(error)
                    self.showError(error)
                }.finally {
                    indicatorView?.dismiss()
            }
            break
            
        }
    }

    private func fetchPumpkinStreamURL(video: VideoDetail) {
        attempt(maximumRetryCount: 3) {
            APIClient.fetchPumpkinEpisodes(id: video.info.id)
            }.done { episodes in
                self.preparePlayerWindow(video: video, episodes: episodes)
            }.catch{ error in
                print(error)
                self.showError(error)
            }.finally {
        }
    }
}
