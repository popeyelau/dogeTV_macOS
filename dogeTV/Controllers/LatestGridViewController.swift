//
//  LatestGridViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/15.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import SnapKit
import PromiseKit

class LatestGridViewController: NSViewController {
    
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var indicatorView: NSProgressIndicator!
    var hots: [Hot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
}

extension LatestGridViewController: NSCollectionViewDelegate,  NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return hots.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return hots[section].items.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .init("VideoCardView"), for: indexPath) as! VideoCardView
        let video = hots[indexPath.section].items[indexPath.item]
        item.data = video
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        let header = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: .init("GridSectionHeader"), for: indexPath) as! GridSectionHeader
        let section = hots[indexPath.section]
        header.titleLabel.stringValue = section.title
        header.onMore = {
            NotificationCenter.default.post(name: .init(rawValue: "com.dogetv.more"), object: section.title)
        }
        return header
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        let video = hots[indexPath.section].items[indexPath.item]
        showVideo(id: video.id, indicatorView: indicatorView)
    }
}

extension LatestGridViewController {
    func refresh() {
        indicatorView.isHidden = false
        indicatorView.startAnimation(nil)
        attempt(maximumRetryCount: 3) {
            when(fulfilled: APIClient.fetchTopics(),
                 APIClient.fetchHome())
            }.done { _, hots in
                self.hots = hots
            }.catch{ error in
                print(error)
                self.showError(error)
            }.finally {
                self.collectionView.reloadData()
                self.indicatorView.isHidden = true
                self.indicatorView.stopAnimation(nil)
        }
    }
}


extension LatestGridViewController: Initializable {}
