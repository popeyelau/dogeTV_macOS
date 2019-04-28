//
//  UserViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/20.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class UserViewController: NSViewController {

    var histories: [History] = [] {
        didSet {
            emptyView.isHidden = !histories.isEmpty
        }
    }
    @IBOutlet weak var historyCollectionView: NSCollectionView!
    @IBOutlet weak var emptyView: EmptyView!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(historyUpdatedHandler), name: .init(rawValue: "com.dogetv.history"), object: nil)
    }

    func reload() {
        histories = Repository.getObjects(table: History.self, orderBy: [History.Properties.createDate.asOrder(by: .descending)]) ?? []
        historyCollectionView.reloadData()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        reload()
    }

    @objc func historyUpdatedHandler() {
        reload()
    }

    @IBAction func emptyTrashAction(_ sender: NSButton) {
        guard !histories.isEmpty else { return }
        if dialogOKCancel(question: "确定要清空全部历史记录吗？", text: "") {
            Repository.truncate(table: History.self)
            reload()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension UserViewController: NSCollectionViewDelegate, NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return histories.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .init("HistoryCardView"), for: indexPath) as! HistoryCardView
        let history = histories[indexPath.item]
        item.data = history
        return item
    }

    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        let header = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: .init("GridSectionHeader"), for: indexPath) as! GridSectionHeader
        header.titleLabel.stringValue = "历史观看"
        header.subTitleLabel.isHidden = true
        return header
    }

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        collectionView.deselectItems(at: indexPaths)
        guard let history = histories[safe: indexPath.item] else {
            return
        }
        showVideo(id: history.videoId, history: history)
    }
}
extension UserViewController: Initializable {
    func refresh() {
        reload()
    }
}


