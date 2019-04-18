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
    @IBOutlet weak var incdicatorView: NSProgressIndicator!
    @IBOutlet weak var collectionView: NSCollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        // Do view setup here.
    }
    
    func showVideo(id: String) {
        incdicatorView.isHidden = false
        incdicatorView.startAnimation(nil)
        attempt(maximumRetryCount: 3) {
            when(fulfilled: APIClient.fetchVideo(id: id),
                 APIClient.fetchEpisodes(id: id))
            }.done { detail, episodes in
                let window = AppWindowController(windowNibName: "AppWindowController")
                let content = PlayerViewController()
                content.videDetail = detail
                content.episodes = episodes
                window.content = content
                window.show(from:self.view.window)
            }.catch{ error in
                print(error)
            }.finally {
                self.incdicatorView.stopAnimation(nil)
                self.incdicatorView.isHidden = true
        }
    }
    
}


extension TopicsViewController: NSCollectionViewDelegate,  NSCollectionViewDataSource {
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return topics.count
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return topics[section].items.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .init("VideoCardView"), for: indexPath) as! VideoCardView
        let video = topics[indexPath.section].items[indexPath.item]
        item.data = video
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        let header = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: .init("GridSectionHeader"), for: indexPath) as! GridSectionHeader
        header.titleLabel.stringValue = topics[indexPath.section].topic.title
        header.moreButton.isHidden = true
        return header
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        collectionView.deselectItems(at: indexPaths)
        let video = topics[indexPath.section].items[indexPath.item]
        showVideo(id: video.id)
    }
}


extension TopicsViewController {
    func refresh() {
        _ = APIClient.fetchTopics().done { (topics) in
            topics.forEach {
                self.refreshTopicVideos(id: $0.id)
            }
            }.catch({ (error) in
                print(error)
            }).finally {
        }
    }
    
    func refreshTopicVideos(id: String) {
        APIClient.fetchTopic(id: id).done { (topic) in
            self.topics.append(topic)
            }.catch{ (error) in
            }.finally {
                self.collectionView.reloadData()
        }
    }
}
