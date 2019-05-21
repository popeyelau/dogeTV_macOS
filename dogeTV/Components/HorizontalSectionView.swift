//
//  HorizontalSectionView.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/5/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class HorizontalSectionView: NSCollectionViewItem {
    var data: Hot! {
        didSet {
            if let data = data {
                titleLabel.stringValue = data.title
                itemsCollectionView.reloadData()
                numberOfPage = (data.items.count / data.numberOfColumn) + ((data.items.count % data.numberOfColumn) > 0 ? 1 : 0)
                pageIndex = 1
                updatePageLabel()
            }
        }
    }
    @IBOutlet weak var prevBtn: NSButton!
    @IBOutlet weak var nextBtn: NSButton!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var scrollView: DisablableScrollView!
    @IBOutlet weak var itemsCollectionView: NSCollectionView!
    @IBOutlet weak var pageLabel: NSTextField!

    var pageIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.isEnabled = false
        itemsCollectionView.backgroundColors = [.backgroundColor]
    }

    @IBAction func prevAction(_ sender: NSButton) {
        pageIndex = pageIndex - 1 <= 0 ? numberOfPage : pageIndex - 1
        updatePageLabel()
        itemsCollectionView.reloadData()
        
    }
    @IBAction func nextAction(_ sender: NSButton) {
        pageIndex = pageIndex + 1 > numberOfPage ? 1 : pageIndex + 1
        updatePageLabel()
        itemsCollectionView.reloadData()
    }

    func updatePageLabel() {
        pageLabel.stringValue = "\(pageIndex) / \(numberOfPage)"
    }
    
    var numberOfPage: Int = 1
    
    var width: CGFloat {
        return view.bounds.width - 40
    }
    
    var contentSize: CGSize {
        return itemsCollectionView.collectionViewLayout?.collectionViewContentSize ?? .zero
    }
    override func viewDidLayout() {
        super.viewDidLayout()

    }
}

extension HorizontalSectionView: NSCollectionViewDelegate,  NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(data.items[data.numberOfColumn * (pageIndex - 1)..<data.items.count].count, data.numberOfColumn)
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let type = data.type ?? .normal
        switch type {
        case .normal:
            let item = collectionView.makeItem(withIdentifier: .videoCardView, for: indexPath) as! VideoCardView
            let video = data.items[data.numberOfColumn * (pageIndex - 1) + indexPath.item]
            item.shadowView.isHidden = true
            item.data = video
            return item
        case .series, .topic:
            let item = collectionView.makeItem(withIdentifier: .topicCardView, for: indexPath) as! TopicCardView
            let video = data.items[data.numberOfColumn * (pageIndex - 1) + indexPath.item]
            item.imageView?.setResourceImage(with: video.cover, placeholder: NSImage(named: "404_series"))
            return item
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        collectionView.deselectItems(at: indexPaths)
        guard let indexPath = indexPaths.first else { return }
        let type = data.type ?? .normal
        let video = data.items[data.numberOfColumn * (pageIndex - 1) + indexPath.item]
        
        if type == .normal {
            showVideo(video: video)
            return
        }
        NSApplication.shared.rootViewController?.showSeries(id: video.id, title: video.name)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let type = data.type ?? .normal
        return type.itemSize
    }
    
}
