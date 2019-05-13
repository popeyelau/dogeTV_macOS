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
    
    @IBOutlet weak var queryPanel: NSView!
    @IBOutlet weak var queryStack: NSStackView!
    
    var category: BlueRayTabViewController.TabItems = .film
    var pageIndex: Int = 1
    let pageSize: Int = 24
    var videos: [Video] = []
    var queryOptions: [OptionSet]?
    var isLoading: Bool = false
    var isNoMoreData: Bool = false
    
    lazy var queryOptionsView: QueryOptionsView = {
        let queryView = QueryOptionsView()
        queryView.onQueryChanged = { [weak self]  in
            self?.refresh()
        }
        return queryView
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.backgroundColor.cgColor
        collectionView.backgroundColors = [.backgroundColor]
        registLoadMoreNotification()
        refresh()
    }
    
    @IBAction func toggleSource(_ sender: NSButton) {
        pageIndex = 1
        refresh()
    }

    func refreshData(_ data: VideoCategory) {
        self.isNoMoreData = data.items.isEmpty

        if pageIndex == 1 {
            videos.removeAll()
        }
        
        videos.append(contentsOf: data.items)
        
        if let query = data.query, queryStack.arrangedSubviews.isEmpty {
            queryStack.addArrangedSubview(queryOptionsView)
            queryOptionsView.snp.remakeConstraints {
                $0.edges.equalToSuperview()
            }
            query.forEach { $0.options.first?.isSelected = true }
            queryOptions = query
            queryOptionsView.optionsSet = query
        }
    }
    
    @IBAction func toggleAction(_ sender: NSButton) {
        queryOptionsView.toggle()
    }

    func showPlayer(with result: VideoDetail) {
        guard let episodes = result.seasons?.first?.episodes, !episodes.isEmpty else {
            return
        }

        let video = VideoDetail(info: result.info, recommends: result.recommends, seasons: nil)
        replacePlayerWindowIfNeeded(video: video, episodes: episodes)
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
        if(queryOptionsView.isExpanded) {
            queryOptionsView.toggle()
        }
        guard !isNoMoreData, !isLoading else { return }
        guard let value = scrollView.verticalScroller?.floatValue,  value >= 0.9 else {
            return
        }
        loadMore()
    }
    
    var selectedQuery: String {
        guard let queryOptions = queryOptions else {
            return "/whole/\(category.key)_______0_hits__1.html"
        }
        let sort = queryOptions.first { $0.title == "排序" }?.options.first { $0.isSelected}?.key ?? "hits"
        let tag = queryOptions.first { $0.title == "类型" }?.options.first { $0.isSelected && $0.key != "全部" }?.key ?? ""
        let year = queryOptions.first { $0.title == "年份" }?.options.first { $0.isSelected && $0.key != "全部"}?.key ?? ""
        let area = queryOptions.first { $0.title == "地区" }?.options.first { $0.isSelected && $0.key != "全部"}?.key ?? ""
        let key = "/whole/\(category.key)_\(area)_\(tag)__\(year)___0_\(sort)_\(pageIndex).html"
        return key
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
            APIClient.fetchBlueRays(query: self.selectedQuery)}
            .done { (category) in
                self.refreshData(category)
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
        APIClient.fetchBlueRays(query: selectedQuery).done { category in
            self.refreshData(category)
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
