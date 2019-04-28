//
//  QueryOptionsView.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import SnapKit


class QueryOptionsView: NSView {
    var onQueryChanged: (() -> Void)?

    var isExpanded: Bool = false {
        didSet {
            collectionView.reloadData()
            needsLayout = true
        }
    }
    var optionsSet: [OptionSet] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    lazy var scrollView: DisablableScrollView = {
        let scrollView = DisablableScrollView()
        scrollView.isEnabled = false
        scrollView.verticalScroller = InvisibleScroller()
        scrollView.documentView = collectionView
        return scrollView
    }()
    
    lazy var collectionView: NSCollectionView = {
        let layout = QueryOptionsFlowLayout()
        let collectionView = NSCollectionView()
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isSelectable = true
        collectionView.backgroundColors = [NSColor.clear]
        return collectionView
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews()

    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func toggle() {
        isExpanded = !isExpanded
    }

    override func layout() {
        super.layout()
        scrollView.snp.remakeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(collectionView.collectionViewLayout!.collectionViewContentSize.height)
        }
    }

}


extension QueryOptionsView: NSCollectionViewDelegate, NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return isExpanded ? optionsSet.count : min(optionsSet.count, 1)
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = optionsSet[section]
        return min(section.options.count, 20)
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .init("QueryOptionView"), for: indexPath) as! QueryOptionView
        let section = optionsSet[indexPath.section]
        let option = section.options[indexPath.item]
        item.isSelected = option.isSelected
        item.textField?.stringValue = option.text
        return item
    }

    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        let header = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: .init("GridSectionHeader"), for: indexPath) as! GridSectionHeader
        header.layer?.backgroundColor =  NSColor.clear.cgColor
        let section = optionsSet[indexPath.section]
        header.titleLabel.stringValue = "\(section.title):"
        header.titleLabel.textColor = .secondaryLabelColor
        header.titleLabel.font = NSFont.systemFont(ofSize: 13)
        header.titleLabel.alignment = .left
        header.subTitleLabel.isHidden = true
        return header
    }

    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        let section = optionsSet[indexPath.section]
        guard let option = section.options[safe: indexPath.item] else { return }
        //collectionView.deselectItems(at: indexPaths)

        if option.isSelected {
            return
        }
        section.setSelected(item: option)
        collectionView.reloadData()
        onQueryChanged?()
    }
}
