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
    
    @IBOutlet weak var incdicatorView: NSProgressIndicator!
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        queryPanel.wantsLayer = true
        queryPanel.layer?.backgroundColor = NSColor(srgbRed:0.31, green:0.31, blue:0.33, alpha:1.00).cgColor

        if let clipView = collectionView.superview, let scrollView = clipView.superview as? NSScrollView{
            let contentView = scrollView.contentView
            contentView.postsBoundsChangedNotifications = true
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(collectionViewDidScroll),
                                                   name: NSView.boundsDidChangeNotification,
                                                   object: clipView)
        }
        
        refresh()
    }

    @IBAction func toggleSource(_ sender: NSButton) {
        pageIndex = 1
        isDouban = sender.state == .on
        queryOptions = nil
        refresh()
    }
    
    @objc func collectionViewDidScroll() {
        if(queryStack.arrangedSubviews.count <= 1) { return }
        NSAnimationContext.runAnimationGroup { context in
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            context.duration = 0.5
            for item in queryStack.arrangedSubviews[1...] {
                item.animator().isHidden = true
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func toggleAction(_ sender: NSButton) {
        sender.state = sender.state == .on ? .off : .on
        toggleQueryPanel()
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

extension VideoGridViewController: NSCollectionViewDelegate, NSCollectionViewDataSource {
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
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        collectionView.deselectItems(at: indexPaths)
        let video = videos[indexPath.item]
        showVideo(id: video.id)
    }
}


extension VideoGridViewController {
    
    func toggleQueryPanel() {
        NSAnimationContext.runAnimationGroup { context in
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            context.duration = 0.5
            let views = queryStack.arrangedSubviews.filter { $0.isHidden }
            if views.count > 0 {
                views.forEach { $0.animator().isHidden = false}
            } else {
                queryStack.arrangedSubviews[1...].forEach { $0.animator().isHidden = true}
            }
        }
    }
    
    func refreshData(_ data: VideoCategory) {
        videos = data.items
        
        if let query = data.query, queryOptions == nil {
            queryStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            query.forEach {
                $0.options.first?.isSelected = true
            }
            queryOptions = query
            query.forEach {
                let line = QueryLineView()
                line.optionsSet = $0
                line.onQueryChanged = { [weak self]  in
                    self?.refresh()
                }
                line.isHidden = $0.title != "排序"
                queryStack.addArrangedSubview(line)
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
        incdicatorView.isHidden = false
        incdicatorView.startAnimation(nil)
        attempt(maximumRetryCount: 3) {
            APIClient.fetchCategoryList(category: category, isDouban: self.isDouban, query: query)}
            .done { (category) in
                self.refreshData(category)
            }.catch({ (error) in
                print(error)
            }).finally {
                self.incdicatorView.isHidden = true
                self.incdicatorView.stopAnimation(nil)
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
                self.collectionView.reloadData()
        }
    }
}
