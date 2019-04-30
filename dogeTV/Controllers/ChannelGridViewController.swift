//
//  ChannelGridViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import PromiseKit

class ChannelGridViewController: NSViewController{
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var indicatorView: NSProgressIndicator!
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
        let backgroundColor = NSColor(red: 0.12, green: 0.12, blue: 0.13, alpha: 1.00)
        view.layer?.backgroundColor = backgroundColor.cgColor
        searchTextField.focusRingType = .none
        searchTextField.wantsLayer = true
        searchTextField.backgroundColor = backgroundColor
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
        let window = AppWindowController(windowNibName: "AppWindowController")
        let content = LivePlayerViewController()
        content.channel = channel
        window.content = content
        window.window?.title = channel.name
        window.show(from: view.window)
    }
    
    @IBAction func searchFieldAction(_ sender: NSTextField) {
        view.window?.makeFirstResponder(nil)
        refreshDataSource()
        collectionView.reloadData()
    }
    
    @objc func onCategoryChanged(_ sender: NSMenuItem) {
        view.window?.makeFirstResponder(nil)
        guard let tid = sender.identifier?.rawValue else { return }
        searchTextField.stringValue = ""
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
        let item = collectionView.makeItem(withIdentifier: .init("ChannelCardView"), for: indexPath) as! ChannelCardView
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
        getStreamURL(channel.url)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return ChannelCardView.itemSize
    }
}


extension ChannelGridViewController {
    func refreshChannels(tid: String) {
        indicatorView.show()
        _ = APIClient.fetchIPTV(tid: tid).done { (channels) in
            self.channels = channels
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
                self.collectionView.reloadData()
                self.indicatorView.dismiss()
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
        refreshChannels(tid: category.id)
        toggleBtn.title = category.category
    }
    
    func refresh() {
        indicatorView.show()
        APIClient.fetchIPTVCategories().done { (categories) in
            self.configContentMenus(categories: categories)
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
                self.collectionView.reloadData()
                self.indicatorView.dismiss()
        }
    }
    
    func getStreamURL(_ url: String) {
        indicatorView.show()
        _ = APIClient.fetchIPTVStreamURL(url).done { (channel) in
            self.preparePlay(channel: channel)
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
                self.collectionView.reloadData()
                self.indicatorView.dismiss()
        }
    }
  
}

extension ChannelGridViewController: Initializable {}
