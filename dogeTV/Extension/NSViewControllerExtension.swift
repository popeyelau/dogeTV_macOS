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
        //toast(message: error.localizedDescription)
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
    func preparePlayerWindow(video: VideoDetail, episodes: [Episode]) {
        NSApplication.shared.closePlayerWindow()
        //NSApplication.shared.appDelegate?.mainWindowController?.window?.performMiniaturize(nil)
        let windowController = AppWindowController(windowNibName: "AppWindowController")
        let content = PlayerViewController()
        content.videDetail = video
        content.episodes = episodes
        windowController.content = content
        windowController.show(from: view.window)
    }
    
    
    func replacePlayerWindowIfNeeded(video: VideoDetail?, episodes: [Episode], episodeIndex: Int = 0, title: String? = nil) {
        guard !episodes.isEmpty else {
            return
        }
        NSApplication.shared.appDelegate?.mainWindowController?.window?.performMiniaturize(nil)
        let window = NSApplication.shared.windows.first {
            $0.contentViewController?.isKind(of:PlayerViewController.self) == true
        }
        
        let contentController: PlayerViewController? = window?.contentViewController as? PlayerViewController ?? PlayerViewController()
        contentController?.episodes = episodes
        contentController?.episodeIndex = episodeIndex
        contentController?.titleText = title ?? video?.info.name
        contentController?.videDetail = nil
        if let info = video?.info {
            contentController?.videDetail = VideoDetail(info: info, recommends: video?.recommends , seasons: nil)
        }
        
        if let window = window {
            contentController?.updateDataSource()
            contentController?.updatePlayingEpisodeIfNeeded()
            window.makeKeyAndOrderFront(nil)
            return
        }
        
        let windowController = AppWindowController(windowNibName: "AppWindowController")
        windowController.content = contentController
        windowController.show(from:self.view.window)
    }
    
    func showVideo(video: Video) {

        let id = video.id
        let source = video.sourceType
        showSpinning()

        switch source{
        case .other:
            attempt(maximumRetryCount: 3) {
                when(fulfilled: APIClient.fetchVideo(id: id),
                     APIClient.fetchEpisodes(id: id))
                }.done { detail, episodes in
                    self.preparePlayerWindow(video: detail, episodes: episodes)
                }.catch{ error in
                    print(error)
                    self.showError(error)
                }.finally {
                    self.removeSpinning()
            }
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
                    self.removeSpinning()
            }
        case .blueray:
            attempt(maximumRetryCount: 3) {
                APIClient.fetchBlueVideo(id: id)
                }.done { detail in
                    guard let episodes = detail.seasons?.first?.episodes else {
                        return
                    }
                    let video = VideoDetail(info: detail.info, recommends: detail.recommends, seasons: nil)
                    self.preparePlayerWindow(video: video, episodes: episodes)
                }.catch{ error in
                    print(error)
                    self.showError(error)
                }.finally {
                    self.removeSpinning()
            }
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
