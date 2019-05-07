//
//  TopRatedViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/18.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import PromiseKit

class TopRatedViewController: NSViewController {
    
    @IBOutlet weak var segmentCtrl: CustomSegmentedControl!
    enum Columns: String, CaseIterable {
        case index
        case name
        case type
        case resource
        case update
        case hot
    }

    var list: [Ranking] = []
    var category: Category = .film
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var indicatorView: NSProgressIndicator!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleAction(_:))

        Category.allCases.enumerated().forEach { index, element in
            segmentCtrl.addSegment(withTitle: element.title)
        }
        segmentCtrl.selectedIndex = category.rawValue

        
        refresh()

        /*
        let segment = CustomSegmentedControl()
        segment.addSegment(withTitle: "我爱中国")
        segment.addSegment(withTitle: "我爱中国2")
        segment.addSegment(withTitle: "我爱中国3")
        segment.addSegment(withTitle: "我爱中国4")
        segment.addSegment(withTitle: "我爱中国5")
        segment.addSegment(withTitle: "我爱中国6")
        view.addSubview(segment)
        segment.snp.makeConstraints {
            $0.center.equalToSuperview()
        }*/
    }

    @objc func tableViewDoubleAction(_ sender: NSTableView) {
        guard tableView.clickedRow != -1 else { return }
        let selected = list[tableView.clickedRow]
        showVideo(id: selected.id, indicatorView: indicatorView)
    }
    @IBAction func segmentIndexChanged(_ sender: CustomSegmentedControl) {
        let index = sender.selectedIndex ?? 0
        category = Category(rawValue: index) ?? .film
        refresh()
    }


}

extension TopRatedViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let id = tableColumn?.identifier,
            let column = Columns(rawValue: id.rawValue),
            let cell = tableView.makeView(withIdentifier: .init(rawValue: "cell"), owner: nil) as? NSTableCellView else {
            return nil
        }

        var textColor: NSColor = .labelColor
        let item = list[row]
        var value = "-"
        switch column {
        case .index: value = item.index
        case .name: value = item.name
        case .type: value = item.score
        case .resource: value = item.episode
        case .update: value = item.updateAt
        case .hot:
            value = item.hot
            textColor = .systemRed
        }
        cell.textField?.stringValue = value
        cell.textField?.textColor = textColor
        return cell
    }
}

extension TopRatedViewController {
    func refresh() {
        indicatorView.show()
        attempt(maximumRetryCount: 3) {
            APIClient.fetchRankList(category: self.category)
            }.done { (list) in
                self.list = list
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
                self.tableView.reloadData()
                self.indicatorView.dismiss()
                self.tableView.scrollToVisible(.zero)
        }
    }
}

extension TopRatedViewController: Initializable {}
