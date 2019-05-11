//
//  TopicsViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/18.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import PromiseKit

class TopicsViewController: NSViewController, Initializable {

    var topics: [TopicDetail] = []
    @IBOutlet weak var collectionView: NSCollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.backgroundColor.cgColor
        collectionView.backgroundColors = [.backgroundColor]
        // Do view setup here.
    }
}


extension TopicsViewController: NSCollectionViewDelegate,  NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return topics.count
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return topics[section].items.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .videoCardView, for: indexPath) as! VideoCardView
        let video = topics[indexPath.section].items[indexPath.item]
        item.data = video
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        let header = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: .gridSectionHeader, for: indexPath) as! GridSectionHeader
        header.titleLabel.stringValue = topics[indexPath.section].topic.title
        header.subTitleLabel.isHidden = true
        return header
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        collectionView.deselectItems(at: indexPaths)
        let video = topics[indexPath.section].items[indexPath.item]
        showVideo(video: video)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return VideoCardView.itemSize
    }
}


extension TopicsViewController {
    func refresh() {
        showSpinning()
        _ = APIClient.fetchTopics()
            .thenMap(refreshTopicVideos)
            .done { (topics) in
                self.topics.append(contentsOf: topics)
            }.catch{ (error) in
            }.finally {
                self.collectionView.reloadData()
                self.removeSpinning()
        }
    }
    
    func refreshTopicVideos(topic: Topic) -> Promise<TopicDetail> {
        return APIClient.fetchTopic(id: topic.id)
    }
}
