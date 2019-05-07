//
//  HomeViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/5/6.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import PromiseKit


class HomeViewController: NSViewController {
    
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var indicatorView: NSProgressIndicator!
    var hots: [Hot] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColors = [.backgroundColor]
        refresh()
    }
    
    func showPumpkinVideo(id: String, indicatorView: NSProgressIndicator? = nil) {
        indicatorView?.show()
        attempt(maximumRetryCount: 3) {
            APIClient.fetchPumpkinEpisodes(id: id)
            }.done { episodes in
                self.showPlayer(with: episodes)
            }.catch{ error in
                print(error)
                self.showError(error)
            }.finally {
                indicatorView?.dismiss()
        }
    }
    
    func showPlayer(with episodes: [Episode]) {
        guard !episodes.isEmpty else {
            return
        }
        let window = AppWindowController(windowNibName: "AppWindowController")
        let content = PlayerViewController()
        content.episodes = episodes
        content.episodeIndex = 0
        window.content = content
        window.show(from:self.view.window)
    }
    
    
}

extension HomeViewController: NSCollectionViewDelegate,  NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return hots.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return hots[section].items.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let type = hots[indexPath.section].type ?? .normal
        switch type {
        case .normal:
            let item = collectionView.makeItem(withIdentifier: .init("VideoCardView"), for: indexPath) as! VideoCardView
            let video = hots[indexPath.section].items[indexPath.item]
            item.data = video
            return item
        case .series, .topic:
            let item = collectionView.makeItem(withIdentifier: .init("TopicCardView"), for: indexPath) as! TopicCardView
            let video = hots[indexPath.section].items[indexPath.item]
            item.imageView?.setResourceImage(with: video.cover, placeholder: NSImage(named: "404_series"))
            return item
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        let header = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: .init("GridSectionHeader"), for: indexPath) as! GridSectionHeader
        let section = hots[indexPath.section]
        header.titleLabel.stringValue = section.title
        return header
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        collectionView.deselectItems(at: indexPaths)
        guard let indexPath = indexPaths.first else { return }
        let section = hots[indexPath.section]
        let type = section.type ?? .normal
        let video = section.items[indexPath.item]
        
        if type == .normal {
            showVideo(id: video.id, source: .pumpkin, indicatorView: indicatorView)
            return
        }
        NSApplication.shared.rootViewController?.showSeries(id: video.id, title: video.name)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let type = hots[indexPath.section].type ?? .normal
        return type.itemSize
    }
}

extension HomeViewController {
    func refresh() {
        indicatorView.show()
        attempt(maximumRetryCount: 3) {
            APIClient.fetchHome()
            }.done { hots in
                self.hots = hots
            }.catch{ error in
                print(error)
                self.showError(error)
            }.finally {
                self.collectionView.reloadData()
                self.collectionView.scroll(.zero)
                self.indicatorView.dismiss()
        }
    }
}


extension HomeViewController: Initializable {}



