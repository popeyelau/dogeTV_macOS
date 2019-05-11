//
//  BlueRayGridViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/5/8.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import Cocoa
import PromiseKit

class BlueRayGridViewController: NSViewController {
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var scrollView: NSScrollView!
    var category: BlueRayTabViewController.TabItems = .film
    var pageIndex: Int = 1
    let pageSize: Int = 24
    var videos: [Video] = []
    var isLoading: Bool = false
    var isNoMoreData: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.backgroundColor.cgColor
        collectionView.backgroundColors = [.backgroundColor]
        registLoadMoreNotification()
        refresh()
    }


    func showPlayer(with result: VideoDetail) {
        guard let episodes = result.seasons?.first?.episodes, !episodes.isEmpty else {
            return
        }
        replacePlayerWindowIfNeeded(video: result, episodes: episodes)
    }

    func registLoadMoreNotification() {
        guard let clipView = collectionView.superview,
            let scrollView = clipView.superview as? NSScrollView else {
                return
        }
        scrollView.contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(collectionViewDidScroll),
                                               name: NSView.boundsDidChangeNotification,
                                               object: clipView)
    }
    
    @objc func collectionViewDidScroll() {
        
        guard !isNoMoreData, !isLoading else { return }
        guard let value = scrollView.verticalScroller?.floatValue,  value >= 0.9 else {
            return
        }
        
        loadMore()
    }
}

extension BlueRayGridViewController: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .videoCardView, for: indexPath) as! VideoCardView
        let video = videos[indexPath.item]
        item.data = video
        return item
    }

    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        let header = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: .gridSectionHeader, for: indexPath) as! GridSectionHeader
        header.backBtn.isHidden = false
        if let title = title {
            header.titleLabel.stringValue = title
        }
        return header
    }

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        collectionView.deselectItems(at: indexPaths)
        guard let indexPath = indexPaths.first else { return }
        let video = videos[indexPath.item]
        fetchVideo(id: video.id)
    }

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return VideoCardView.itemSize
    }
}


extension BlueRayGridViewController {

    func refresh() {
        pageIndex = 1
        isLoading = true
        showSpinning()
        attempt(maximumRetryCount: 3) {
            APIClient.fetchBlueRays(category: self.category, page: self.pageIndex)}
            .done { (videos) in
                self.videos = videos
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
                self.removeSpinning()
                self.isLoading = false
                self.pageIndex = 1
                self.collectionView.reloadData()
                self.collectionView.animator().scroll(.zero)
        }
    }

    func loadMore() {
        guard !isNoMoreData else {
            return
        }

        pageIndex += 1
        isLoading = true
        APIClient.fetchBlueRays(category: category, page: pageIndex).done { videos in
            if videos.isEmpty {
                self.isNoMoreData = true
            }
            self.videos.append(contentsOf: videos)
            }.catch{ (err) in
                self.isNoMoreData = true
                self.pageIndex = max(1, self.pageIndex-1)
                print(err)
            }.finally {
                self.isLoading = false
                self.collectionView.reloadData()
        }
    }

    func fetchVideo(id: String) {
        showSpinning()
        attempt(maximumRetryCount: 3) {
            APIClient.fetchBlueVideo(id: id)}
            .done { (detail) in
                self.showPlayer(with: detail)
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
                self.removeSpinning()
        }
    }
}

extension BlueRayGridViewController: Initializable {}
