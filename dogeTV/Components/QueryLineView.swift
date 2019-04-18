//
//  QueryLineView.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import SnapKit


class QueryLineView: NSView {
    var onQueryChanged: (() -> Void)?
    var optionsSet: OptionSet? {
        didSet {
            if let data = optionsSet {
                let textParagraph:NSMutableParagraphStyle = NSMutableParagraphStyle()
                textParagraph.minimumLineHeight = 20
                let attribs = [NSAttributedString.Key.paragraphStyle:textParagraph]
                let attrString:NSAttributedString = NSAttributedString(string: "\(data.title):", attributes: attribs)
                titleLabel.attributedStringValue = attrString
                collectionView.reloadData()
            }
        }
    }
    
    lazy var scrollView: DisablableScrollView = {
        let scrollView = DisablableScrollView()
        scrollView.isEnabled = false
        scrollView.documentView = collectionView
        return scrollView
    }()
    
    lazy var collectionView: NSCollectionView = {
        let layout = NSCollectionViewFlowLayout()
        layout.itemSize = NSSize(width: 80, height: 24)
        layout.sectionInset = NSEdgeInsetsMake(0, 0, 8, 200)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        let collectionView = NSCollectionView()
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isSelectable = true
        collectionView.backgroundColors = [NSColor.clear]
        return collectionView
    }()
    
    lazy var titleLabel: NSTextField = {
        let label = NSTextField()
        label.isBordered = false
        label.textColor = .secondaryLabelColor
        label.alignment = .center
        label.isEditable = false
        label.backgroundColor = nil
        return label
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews()
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(titleLabel)
        addSubview(scrollView)
        titleLabel.snp.makeConstraints {
            $0.top.left.equalToSuperview().offset(8)
        }
    }
    
    override func layout() {
        super.layout()
        scrollView.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.left.equalTo(titleLabel.snp.right).offset(8)
            $0.height.equalTo(collectionView.collectionViewLayout!.collectionViewContentSize.height)
            $0.right.bottom.equalToSuperview()
        }
    }

}


extension QueryLineView: NSCollectionViewDelegate, NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let options = optionsSet?.options, !options.isEmpty else { return 0 }
        return min(options.count, 20)
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .init("QueryOptionView"), for: indexPath) as! QueryOptionView
        if let option = optionsSet?.options[indexPath.item] {
            item.isSelected = option.isSelected
            item.textField?.stringValue = option.text
        }
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        guard let option = optionsSet?.options[indexPath.item] else { return }

        if option.isSelected {
            optionsSet?.setSelected(item: option)
            return
        }
        collectionView.deselectItems(at: indexPaths)
        optionsSet?.setSelected(item: option)
        collectionView.reloadData()
        onQueryChanged?()
    }
}
