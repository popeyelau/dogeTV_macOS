//
//  ChannelGridViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import PromiseKit

let userAgent = ["User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36"]

class ChannelGridViewController: NSViewController{
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var searchTextField: NSTextField!
    @IBOutlet weak var toggleBtn: NSButton!

    var dataSource: [IPTVChannel] = []
    var channels: [IPTVChannel] = [] {
        didSet {
            refreshDataSource()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.backgroundColor.cgColor
        collectionView.backgroundColors = [.backgroundColor]
        searchTextField.focusRingType = .none
        refresh()
    }

    @IBAction func toggleAction(_ sender: NSButton) {
        view.window?.makeFirstResponder(nil)
        view.menu?.popUp(positioning: nil, at: sender.frame.origin, in: view)
    }
    @IBAction func searchBtnAction(_ sender: Any) {
        searchTextField.becomeFirstResponder()
    }
    
    func preparePlay(channel: IPTVChannel) {
        if Preferences.shared.get(key: .usingIINA, default: false) {
            NSApplication.shared.launchIINA(withURL: channel.url)
            return
        }
        
        NSApplication.shared.appDelegate?.mainWindowController?.window?.performMiniaturize(nil)
        let playerWindow = NSApplication.shared.windows.first {
            $0.contentViewController?.isKind(of: LivePlayerViewController.self) == true
        }

        if let window = playerWindow, let controller = window.contentViewController as? LivePlayerViewController {
            controller.channel = channel
            window.title = channel.name
            controller.play()
            window.makeKeyAndOrderFront(nil)
            return
        }
        
        let window = AppWindowController(windowNibName: "AppWindowController")
        let content = LivePlayerViewController()
        content.channel = channel
        window.content = content
        window.window?.title = channel.name
        window.show(from: view.window)
    }
    
    @objc func onCategoryChanged(_ sender: NSMenuItem) {
        view.window?.makeFirstResponder(nil)
        guard let tid = sender.identifier?.rawValue else { return }
        refreshChannels(tid: tid)
        toggleBtn.title = sender.title
    }
    
    func refreshDataSource() {
        let keywords = searchTextField.stringValue.uppercased()
        if keywords.isEmpty {
            dataSource = channels
        } else {
            dataSource = channels.filter { $0.name.contains(keywords) }
        }
    }
}

extension ChannelGridViewController: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .channelCardView, for: indexPath) as! ChannelCardView
        let channel = dataSource[indexPath.item]
        item.textField?.stringValue = channel.name
        item.imageView?.image = NSImage(named: "tv")
        return item
    }

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        view.window?.makeFirstResponder(nil)
        guard let indexPath = indexPaths.first else { return }
        collectionView.deselectItems(at: indexPaths)
        let channel = dataSource[indexPath.item]
        getStreamURL(channel: channel)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return ChannelCardView.itemSize
    }
}



extension ChannelGridViewController {
    func refreshChannels(tid: String) {
        showSpinning()
        _ = APIClient.fetchIPTV(tid: tid).done { (channels) in
            self.channels = channels
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
                self.collectionView.reloadData()
                self.removeSpinning()
        }
    }
    
    func configContentMenus(categories: [IPTV]) {
        guard !categories.isEmpty else { return }
        let menu = NSMenu(title: "直播源")
        menu.items = categories.map {
            let menuItem = NSMenuItem(title: $0.category, action: #selector(onCategoryChanged(_:)), keyEquivalent: "")
            menuItem.identifier = .init($0.id)
            menuItem.target = self
            return menuItem
        }
        view.menu = menu
        let category = categories[0]
        toggleBtn.title = category.category
    }
    
    func refresh() {
        showSpinning()
        APIClient.fetchIPTVCategories()
            .get(configContentMenus)
            .compactMap { $0.first?.id }
            .then(APIClient.fetchIPTV)
            .done { (channels) in
                self.channels = channels
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
                self.collectionView.reloadData()
                self.removeSpinning()
        }
    }
    
    func getStreamURL(channel: IPTVChannel) {
        guard let channelURL = URL(string: channel.url) else {
            return
        }

        var result: IPTVChannel = channel
        showSpinning()
        APIClient.fetchIPTVStreamURL(channelURL.absoluteString)
            .get { result.schedule = $0.schedule }
            .map { _ in channelURL }
            .then(getHTMLBody)
            .map { ($0, "<option+.*?</option>") }
            .then(extractURL)
            .then(getHTMLBody)
            .map { ($0, "url: '(.*?)'") }
            .then(extractURL)
            .done({ (url) in
                result.url = url.absoluteString
                self.preparePlay(channel: result)
            }).catch { (err) in
                print(err)
            }.finally {
                self.removeSpinning()
        }
    }
    
    func extractURL(from body: String, regex: String) -> Promise<URL> {
        return Promise<URL> { resolver in
            guard let url = self.firstMatch(for: regex, in: body)?.extractURLs().first else{
                resolver.reject(E.decodeFaild)
                return
            }
            resolver.fulfill(url)
        }
    }
    
    func getHTMLBody(from url: URL) -> Promise<String> {
        return AlamofireManager.shared.request(url, method: .get, headers: userAgent)
            .responseString()
            .map { $0.string }
    }
    
    func firstMatch(for regex: String, in text: String) -> String? {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            guard let result = regex.firstMatch(in: text,
                                                range: NSRange(text.startIndex..., in: text)) else {
                                                    return nil
            }
            return String(text[Range(result.range, in: text)!])
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return nil
        }
    }
  
}

extension ChannelGridViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField, textField == searchTextField else { return }
        refreshDataSource()
        collectionView.reloadData()
    }
}


extension ChannelGridViewController: Refreshable {}
