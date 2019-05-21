//
//  VideoGridViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/16.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import PromiseKit

class VideoGridViewController: NSViewController {
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var queryPanel: NSView!
    @IBOutlet weak var queryStack: NSStackView!
    @IBOutlet weak var scrollView: NSScrollView!
    
    private var scrollverObsrver: NSKeyValueObservation?
    
    var category: Category? = .film
    var isDouban: Bool = false
    var pageIndex: Int = 1
    var pageSize: Int {
        return isDouban ? 21 :  30
    }
    var videos: [Video] = []{
        didSet {
            isNoMoreData = videos.count < pageIndex * pageSize
        }
    }
    var isLoading: Bool = false
    var isNoMoreData: Bool = false
    var queryOptions: [OptionSet]?
    var queryString: String?

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
        isDouban = sender.state == .on
        queryOptions = nil
        refresh()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func toggleAction(_ sender: NSButton) {
        queryOptionsView.toggle()
    }
    
    var selectedQuery: String {
        if queryOptions == nil {
            return "-Shot"
        }
        
        var queryString = ""
        let tag = queryOptions?.first { $0.title == OptionSetType.tag.rawValue }?.options.first { $0.isSelected && !$0.key.isEmpty }?.key
        let keys = queryOptions?.filter { $0.title != OptionSetType.tag.rawValue }.flatMap { $0.options }.filter { $0.isSelected && !$0.key.isEmpty }.map { $0.key }.joined(separator: "-")
        
        if let tag = tag, !tag.isEmpty {
            queryString += "/\(tag)"
        }
        
        if let keys = keys, !keys.isEmpty {
            queryString += "-\(keys)"
        }
        return queryString
    }
}

extension VideoGridViewController: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
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

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        collectionView.deselectItems(at: indexPaths)
        guard let indexPath = indexPaths.first else { return }
        let video = videos[indexPath.item]
        showVideo(video: video)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return VideoCardView.itemSize
    }
}


extension VideoGridViewController {
    
    func refreshData(_ data: VideoCategory) {
        videos = data.items
        if let query = data.query, queryOptions == nil {
            queryStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            query.forEach {
                $0.options.first?.isSelected = true
            }
            queryOptions = query
            queryOptionsView.optionsSet = query
            queryStack.addArrangedSubview(queryOptionsView)
            queryOptionsView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
    
    func refresh() {
        guard let category = self.category else {
            return
        }
        pageIndex = 1
        isLoading = true
        let query = selectedQuery
        showSpinning()
        attempt(maximumRetryCount: 3) {
            APIClient.fetchCategoryList(category: category, isDouban: self.isDouban, query: query)}
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
                self.collectionView.scroll(.zero)
        }
    }
    
    func loadMore() {
        guard let category = self.category, !isLoading, !isNoMoreData else {
            return
        }
        
        let query = selectedQuery
        pageIndex += 1
        isLoading = true
        showSpinning()
        APIClient.fetchCategoryList(category: category, page: pageIndex, isDouban: isDouban, query: query).done { category in
            if category.items.isEmpty {
                return
            }
            self.videos.append(contentsOf: category.items)
            }.catch{ (err) in
                self.pageIndex = max(1, self.pageIndex-1)
                print(err)
            }.finally {
                self.isLoading = false
                self.removeSpinning()
                self.collectionView.reloadData()
        }
    }
}

extension VideoGridViewController: Refreshable {}
