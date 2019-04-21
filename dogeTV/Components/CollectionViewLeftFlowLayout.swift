//
//  CollectionViewLeftFlowLayout.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/21.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
class CollectionViewLeftFlowLayout: NSCollectionViewFlowLayout {

    override init() {
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        minimumLineSpacing = 20
        minimumInteritemSpacing = 20
    }

    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        let attributes = super.layoutAttributesForElements(in: rect)

        if attributes.isEmpty { return attributes }

        guard let copied =  attributes.map( { $0.copy() }) as? [NSCollectionViewLayoutAttributes] else {
            return attributes
        }

        var leftMargin = sectionInset.left
        var lastYPosition = attributes[0].frame.maxY

        for itemAttributes in copied {
            if itemAttributes.representedElementKind == NSCollectionView.elementKindSectionHeader {
                continue
            }

            if itemAttributes.frame.origin.y > lastYPosition{
                leftMargin = sectionInset.left
            }
            itemAttributes.frame.origin.x = leftMargin
            leftMargin += itemAttributes.frame.width + minimumInteritemSpacing
            lastYPosition = itemAttributes.frame.maxY
        }
        return copied
    }
}



class QueryOptionsFlowLayout: NSCollectionViewFlowLayout {

    override init() {
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        minimumLineSpacing = 8
        minimumInteritemSpacing = 8
        sectionInset = NSEdgeInsets(top: 10, left: 60, bottom: 10, right: 100)
        headerReferenceSize = CGSize(width: 60, height: 0.01)
        itemSize = NSSize(width: 80, height: 24)
    }

    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        let attributes = super.layoutAttributesForElements(in: rect)
        if attributes.isEmpty { return attributes }

        guard let copied =  attributes.map( { $0.copy() }) as? [NSCollectionViewLayoutAttributes] else {
            return attributes
        }

        for itemAttributes in copied {
            if itemAttributes.representedElementKind == NSCollectionView.elementKindSectionHeader {
                let yPostion = itemAttributes.frame.origin.y  + sectionInset.top
                itemAttributes.frame = CGRect(origin: CGPoint(x: 0, y: yPostion), size: CGSize(width: headerReferenceSize.width, height: itemSize.height))
            }
        }
        return copied
    }
}
