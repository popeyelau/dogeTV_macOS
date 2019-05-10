//
//  PumpkinViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/5/6.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import PromiseKit


class PumpkinViewController: NSViewController {

    enum SourceType {
        case home
        case category(category: String)
    }

    
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var indicatorView: NSProgressIndicator!
    var hots: [Hot] = []
    var sourceType: SourceType = .home

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.backgroundColor.cgColor
        collectionView.backgroundColors = [.backgroundColor]
        refresh()
    }
}

extension PumpkinViewController: NSCollectionViewDelegate,  NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
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
            item.shadowView.isHidden = true
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
            showVideo(video: video, indicatorView: indicatorView)
            return
        }
        NSApplication.shared.rootViewController?.showSeries(id: video.id, title: video.name)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let type = hots[indexPath.section].type ?? .normal
        return type.itemSize
    }
    
}

extension PumpkinViewController {
    func refresh() {
        switch sourceType {
        case .home:
            refreshHome()
        case .category(let category):
            refreshCategory(category: category)
        }
    }

    func refreshHome() {
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

    func refreshCategory(category: String) {
        indicatorView.show()
        attempt(maximumRetryCount: 3) {
            APIClient.fetchPumpkinCategoryVideo(category: category)
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


extension PumpkinViewController: Initializable {}



