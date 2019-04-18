//
//  SearchViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import PromiseKit

class SearchViewController: NSViewController {
    var results: [Video] = [] {
        didSet {
            isNoMoreData = results.count < pageSize * pageIndex
        }
    }
    var keywords: String?
    var isCloudParse: Bool = false
    var pageIndex: Int = 1
    var isLoading: Bool = false
    let pageSize: Int = 10
    var isNoMoreData: Bool = false
    var parseResult: CloudParse?
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var incdicatorView: NSProgressIndicator!
    override func viewDidLoad() {
        super.viewDidLoad()
        startSearch(keywords: keywords!)
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
                self.incdicatorView.isHidden = true
                self.incdicatorView.stopAnimation(nil)
        }
    }

    func startSearch(keywords: String) {
        isNoMoreData = false
        pageIndex = 1
        self.keywords = keywords
        if !isViewLoaded { return }
        if let url = URL(string: keywords) {
            isCloudParse = true
            parse(url: url)
            return
        }
        search()
    }
    
}

extension SearchViewController: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return isCloudParse ? parseResult?.episodes.count ?? 0 :  results.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        if isCloudParse {
            let item = collectionView.makeItem(withIdentifier: .init("EpisodeItemView"), for: indexPath) as! EpisodeItemView
            let episode = parseResult!.episodes[indexPath.item]
            item.textField?.stringValue = episode.title
            return item
        }

        let item = collectionView.makeItem(withIdentifier: .init("VideoCardView"), for: indexPath) as! VideoCardView
        let video = results[indexPath.item]
        item.data = video
        return item


    }

    func collectionView(_ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
        if isCloudParse { return }
        if indexPath.item == results.count - 1 {
            loadMore()
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        collectionView.deselectItems(at: indexPaths)

        if isCloudParse {
            let window = AppWindowController(windowNibName: "AppWindowController")
            let content = PlayerViewController()
            content.episodes = parseResult?.episodes
            content.episodeIndex = indexPath.item
            content.titleText = parseResult?.title
            window.content = content
            window.show(from:self.view.window)
            return
        }

        let video = results[indexPaths.first!.item]
        showVideo(id: video.id)
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        let header = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: .init("GridSectionHeader"), for: indexPath) as! GridSectionHeader
        let title = isCloudParse ? parseResult?.title ?? "" : keywords ?? ""
        header.titleLabel.stringValue = "关键字:「\(title)」搜索结果"
        header.moreButton.isHidden = true
        return header
    }

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return isCloudParse ? NSSize(width: 90, height: 30) : NSSize(width: 150, height: 240)
    }
}

extension SearchViewController {
    func search() {
        guard let keywords = keywords, !keywords.isEmpty else { return }
        incdicatorView.isHidden = false
        incdicatorView.startAnimation(nil)
        _ = APIClient.search(keywords: keywords)
            .done { (items) in
                self.results = items
            }.catch({ (error) in
                print(error)
            }).finally {
                self.pageIndex = 1
                self.collectionView.reloadData()
                self.incdicatorView.isHidden = true
                self.incdicatorView.stopAnimation(nil)
                
        }
    }
    
    func loadMore() {
        guard let keywords = keywords, !keywords.isEmpty, !isNoMoreData else { return }
        pageIndex += 1
        isLoading = true
        _ = APIClient.search(keywords: keywords, page: pageIndex)
            .done { (items) in
                self.results.append(contentsOf: items)
            }.catch({ (error) in
                self.pageIndex = max(1, self.pageIndex-1)
                print(error)
            }).finally {
                self.collectionView.reloadData()
        }
    }

    func parse(url: URL) {
        incdicatorView.isHidden = false
        incdicatorView.startAnimation(nil)
        _ = APIClient.cloudParse(url: url.absoluteString)
            .done { (result) in
                self.parseResult = result
            }.catch({ (error) in
                print(error)
            }).finally {
                self.collectionView.reloadData()
                self.incdicatorView.isHidden = true
                self.incdicatorView.stopAnimation(nil)
        }
    }
}
