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

        var leftMargin = sectionInset.left
        var lastYPosition = attributes[0].frame.maxY

        for itemAttributes in attributes {
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
        return attributes
    }
}
