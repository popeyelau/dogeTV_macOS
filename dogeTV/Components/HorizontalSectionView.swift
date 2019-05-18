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
                pageLabel.stringValue = "\(pageIndex + 1) / \(numberOfPage)"
            }
        }
    }
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var scrollView: DisablableScrollView!
    @IBOutlet weak var itemsCollectionView: NSCollectionView!
    @IBOutlet weak var pageLabel: NSTextField!

    var pageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        scrollView.isEnabled = false
        
    }
    
    
    
    @IBAction func prevAction(_ sender: NSButton) {
        pageIndex = max(pageIndex - 1, 0)
        let x = max(width * CGFloat(pageIndex), 0)
        scrollView.documentView?.scroll(NSPoint(x: x, y: 0))
        pageLabel.stringValue = "\(pageIndex + 1) / \(numberOfPage)"
        
    }
    @IBAction func nextAction(_ sender: NSButton) {
        pageIndex = min(pageIndex + 1, numberOfPage)
        let x = min(width * CGFloat(pageIndex), contentSize.width)
        if x >= contentSize.width {
            return
        }
        scrollView.documentView?.scroll(NSPoint(x: x, y: 0))
        pageLabel.stringValue = "\(pageIndex + 1) / \(numberOfPage)"
    }
    
    var numberOfPage: Int {
        let pages =  Int(ceil(contentSize.width / view.bounds.width))
        return pages
    }
    
    var width: CGFloat {
        return view.bounds.width - 40
    }
    
    var contentSize: CGSize {
        return itemsCollectionView.collectionViewLayout?.collectionViewContentSize ?? .zero
    }
    override func viewDidLayout() {
        super.viewDidLayout()
        pageLabel.stringValue = "\(pageIndex + 1) / \(numberOfPage)"
    }
}

extension HorizontalSectionView: NSCollectionViewDelegate,  NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return data?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let type = data.type ?? .normal
        switch type {
        case .normal:
            let item = collectionView.makeItem(withIdentifier: .videoCardView, for: indexPath) as! VideoCardView
            let video = data.items[indexPath.item]
            item.shadowView.isHidden = true
            item.data = video
            return item
        case .series, .topic:
            let item = collectionView.makeItem(withIdentifier: .topicCardView, for: indexPath) as! TopicCardView
            let video = data.items[indexPath.item]
            item.imageView?.setResourceImage(with: video.cover, placeholder: NSImage(named: "404_series"))
            return item
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        collectionView.deselectItems(at: indexPaths)
        guard let indexPath = indexPaths.first else { return }
        let type = data.type ?? .normal
        let video = data.items[indexPath.item]
        
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
