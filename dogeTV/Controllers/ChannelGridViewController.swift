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
    var channelGroups: [ChannelGroup] = []
    var location: TV = .hwtv

    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    
    @IBAction func toggleAction(_ sender: NSButton) {
        location = location.next()
        refresh()
    }
}

extension ChannelGridViewController: NSCollectionViewDelegate, NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return channelGroups.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return channelGroups[section].channels.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .init("ChannelCardView"), for: indexPath) as! ChannelCardView
        let channel = channelGroups[indexPath.section].channels[indexPath.item]
        item.textField?.stringValue = channel.name
        item.imageView?.setResourceImage(with: channel.icon, placeholder: NSImage(named: "tv") )
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        let header = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: .init("GridSectionHeader"), for: indexPath) as! GridSectionHeader
        let section = channelGroups[indexPath.section]
        header.titleLabel.stringValue = section.categoryName
        header.moreButton.isHidden = true
        return header
    }

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        let channel = channelGroups[indexPath.section].channels[indexPath.item]
        let window = AppWindowController(windowNibName: "AppWindowController")
        let content = LivePlayerViewController()
        content.channel = channel
        window.content = content
        window.window?.title = channel.name
        window.show(from: view.window)
    }
}


extension ChannelGridViewController {
    func refresh() {
        indicatorView.isHidden = false
        indicatorView.stopAnimation(nil)
        _ = APIClient.fetchTV(location).done { (groups) in
            self.channelGroups = groups
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
                self.collectionView.reloadData()
                self.indicatorView.isHidden = true
                self.indicatorView.stopAnimation(nil)
        }
    }
  
}

extension ChannelGridViewController: Initializable {}
