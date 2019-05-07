//
//  SerieGridViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/5/7.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import PromiseKit

class SerieGridViewController: NSViewController {
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var indicatorView: NSProgressIndicator!
    var id: String?
    var pageIndex: Int = 0
    let pageSize: Int = 21
    var videos: [Video] = []{
        didSet {
            isNoMoreData = videos.count < max(pageIndex, 1) * pageSize
        }
    }
    var isLoading: Bool = false
    var isNoMoreData: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColors = [.clear]
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        refresh()
    }
}

extension SerieGridViewController: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .init("VideoCardView"), for: indexPath) as! VideoCardView
        let video = videos[indexPath.item]
        item.data = video
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
        if indexPath.item == videos.count - 1 {
            loadMore()
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        let header = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: .init("GridSectionHeader"), for: indexPath) as! GridSectionHeader
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
        showVideo(id: video.id, source: .pumpkin, indicatorView: indicatorView)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return VideoCardView.itemSize
    }
}


extension SerieGridViewController {
    
    func refresh() {
        guard let id = id else {
            return
        }
        pageIndex = 0
        isLoading = true
        indicatorView.show()
        attempt(maximumRetryCount: 3) {
            APIClient.fetchPumpkinserieVideos(id: id, page: self.pageIndex)}
            .done { (videos) in
                self.videos = videos
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
                self.indicatorView.dismiss()
                self.isLoading = false
                self.pageIndex = 0
                self.collectionView.reloadData()
                self.collectionView.animator().scroll(.zero)
        }
    }
    
    func loadMore() {
        guard let id = id, !isNoMoreData else {
            return
        }
        
        pageIndex += 1
        isLoading = true
        APIClient.fetchPumpkinserieVideos(id: id, page: pageIndex).done { videos in
            if videos.isEmpty {
                self.isNoMoreData = true
            }
            self.videos.append(contentsOf: videos)
            }.catch{ (err) in
                self.isNoMoreData = true
                self.pageIndex = max(0, self.pageIndex-1)
                print(err)
            }.finally {
                self.isLoading = false
                self.collectionView.reloadData()
        }
    }
}

extension SerieGridViewController: Initializable {}
