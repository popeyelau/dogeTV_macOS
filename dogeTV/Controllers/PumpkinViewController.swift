//
//  PumpkinViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/5/6.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import PromiseKit


class PumpkinViewController: NSViewController {

    enum SourceType {
        case home
        case category(category: String)
    }

    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var scrollView: NSScrollView!
    var hots: [Hot] = []
    var sourceType: SourceType = .home
    var pageIndex: Int = 0
    let pageSize: Int = 20
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
        switch sourceType {
        case .home:
            loadMoreHome()
        case .category:
            loadMoreCategory()
        }
    }
}

extension PumpkinViewController: NSCollectionViewDelegate,  NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return hots.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .horizontalSectionView, for: indexPath) as! HorizontalSectionView
        let data = hots[indexPath.section]
        item.data = data
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        let header = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: .gridSectionHeader, for: indexPath) as! GridSectionHeader
        let section = hots[indexPath.section]
        header.titleLabel.stringValue = section.title
        return header
    }

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let type = hots[indexPath.section].type ?? .normal
        let width = collectionView.bounds.width - 40
        let height = type.itemSize.height
        return NSSize(width: width, height: height + 44)
    }
}

extension PumpkinViewController {
    func refresh() {
        pageIndex = 0
        switch sourceType {
        case .home:
            refreshHome()
        case .category(let category):
            refreshCategory(category: category)
        }
    }

    func refreshHome() {
        showSpinning()
        attempt(maximumRetryCount: 3) {
            APIClient.fetchHome()
            }.done { hots in
                self.hots = hots
            }.catch{ error in
                print(error)
                self.showError(error)
            }.finally {
                self.collectionView.reloadData()
                self.collectionView.scroll(.zero)
                self.removeSpinning()
        }
    }
    
    func loadMoreHome() {
        guard !isNoMoreData else {
            return
        }
        pageIndex += 1
        isLoading = true
         APIClient.fetchHome(page: pageIndex).done { hots in
            if hots.isEmpty {
                self.isNoMoreData = true
            }
            self.hots.append(contentsOf: hots)
            }.catch{ (err) in
                self.isNoMoreData = true
                self.pageIndex = max(0, self.pageIndex-1)
                print(err)
            }.finally {
                self.isLoading = false
                self.collectionView.reloadData()
        }
    }

    func refreshCategory(category: String) {
        showSpinning()
        attempt(maximumRetryCount: 3) {
            APIClient.fetchPumpkinCategoryVideo(category: category)
            }.done { hots in
                self.hots = hots
            }.catch{ error in
                print(error)
                self.showError(error)
            }.finally {
                self.collectionView.reloadData()
                self.collectionView.scroll(.zero)
                self.removeSpinning()
        }
    }
    
    func loadMoreCategory() {
        guard !isNoMoreData, case let SourceType.category(category) = sourceType else {
            return
        }
       
        pageIndex += 1
        isLoading = true
        APIClient.fetchPumpkinCategoryVideo(category: category, page: pageIndex).done { hots in
            if hots.isEmpty {
                self.isNoMoreData = true
            }
            self.hots.append(contentsOf: hots)
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


extension PumpkinViewController: Initializable {}



