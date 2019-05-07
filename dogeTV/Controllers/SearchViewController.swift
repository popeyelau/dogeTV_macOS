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
            emptyView.isHidden = !results.isEmpty
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
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var indicatorView: NSProgressIndicator!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColors = [.backgroundColor]
        startSearch(keywords: keywords!)
    }

    func startSearch(keywords: String) {
        isNoMoreData = false
        pageIndex = 1
        self.keywords = keywords
        if !isViewLoaded { return }
        if keywords.hasPrefix("http"), let url = URL(string: keywords) {
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
        showVideo(id: video.id, indicatorView: indicatorView)
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        let header = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: .init("GridSectionHeader"), for: indexPath) as! GridSectionHeader
        let title = isCloudParse ? parseResult?.title ?? "" : keywords ?? ""
        header.titleLabel.stringValue = "关键字:「\(title)」搜索结果"
        header.subTitleLabel.isHidden = true
        return header
    }

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        if isCloudParse {
            return NSSize(width: 150, height: 30)
        }
        return VideoCardView.itemSize
    }
}

extension SearchViewController {
    func search() {
        guard let keywords = keywords, !keywords.isEmpty else { return }
        indicatorView.show()
        _ = APIClient.search(keywords: keywords)
            .done { (items) in
                self.results = items
            }.catch({ (error) in
                print(error)
                self.showError(error)
                if self.pageIndex == 1 {
                    self.results = []
                }
            }).finally {
                self.isCloudParse = false
                self.pageIndex = 1
                self.collectionView.reloadData()
                self.indicatorView.dismiss()
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
                self.isNoMoreData = true
                print(error)
                self.showError(error)
            }).finally {
                self.collectionView.reloadData()
        }
    }

    func parse(url: URL) {
        indicatorView.show()
        _ = APIClient.cloudParse(url: url.absoluteString)
            .done { (result) in
                self.parseResult = result
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
                self.isCloudParse = true
                self.collectionView.reloadData()
                self.indicatorView.dismiss()
        }
    }
}

extension SearchViewController: Initializable {
    func refresh() {
        guard let keywords = keywords, !keywords.isEmpty else { return }
        startSearch(keywords: keywords)
    }
}
