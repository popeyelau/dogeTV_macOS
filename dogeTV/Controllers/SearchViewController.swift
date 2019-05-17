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
        }
    }
    var keywords: String?
    var isCloudParse: Bool = false
    var parseResult: CloudParse?
    var isHD: Bool = false
    
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var emptyView: EmptyView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.backgroundColor.cgColor
        collectionView.backgroundColors = [.backgroundColor]
        startSearch(keywords: keywords!)
    }

    func startSearch(keywords: String) {
        self.keywords = keywords
        if !isViewLoaded { return }
        if keywords.hasPrefix("http"), let url = URL(string: keywords) {
            parse(url: url)
            return
        }
        search()
    }
    
    func showParsePlayer(at indexPath: IndexPath) {
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
            let item = collectionView.makeItem(withIdentifier: .episodeItemView, for: indexPath) as! EpisodeItemView
            let episode = parseResult!.episodes[indexPath.item]
            item.textField?.stringValue = episode.title
            return item
        }

        let item = collectionView.makeItem(withIdentifier: .videoCardView, for: indexPath) as! VideoCardView
        let video = results[indexPath.item]
        item.data = video
        return item


    }

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        collectionView.deselectItems(at: indexPaths)
        if isCloudParse {
            guard let episodes = parseResult?.episodes else { return }
            replacePlayerWindowIfNeeded(video: nil, episodes: episodes, episodeIndex: indexPath.item, title: parseResult?.title)
            return
        }
        
        let video = results[indexPath.item]
        showVideo(video: video)
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        let header = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: .gridSectionHeader, for: indexPath) as! GridSectionHeader
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
        if !isHD {
            searchAll(keywords: keywords)
            return
        }
        searchHQ(keywords: keywords)
    }

    func searchAll(keywords: String) {
        showSpinning()
        _ = APIClient.search(keywords: keywords)
            .done { (items) in
                self.results = items
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
                self.isCloudParse = false
                self.collectionView.reloadData()
                self.removeSpinning()
        }
    }
    
    func searchHQ(keywords: String) {
        showSpinning()
        _ = APIClient.fetchPumpkinSearchResults(keywords: keywords)
            .done { (items) in
                self.results = items.uniqueElements
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
                self.isCloudParse = false
                self.collectionView.reloadData()
                self.removeSpinning()
        }
    }

    func parse(url: URL) {
        showSpinning()
        _ = APIClient.cloudParse(url: url.absoluteString)
            .done { (result) in
                self.parseResult = result
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
                self.isCloudParse = true
                self.collectionView.reloadData()
                self.removeSpinning()
        }
    }
}

extension SearchViewController: Initializable {
    func refresh() {
        guard let keywords = keywords, !keywords.isEmpty else { return }
        startSearch(keywords: keywords)
    }
}
