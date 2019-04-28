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
    
    @IBOutlet weak var segmentCtrl: NSSegmentedControl!
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
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(red:0.12, green:0.13, blue:0.13, alpha:1.00).cgColor
        
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleAction(_:))
        segmentCtrl.selectedSegment = category.rawValue
        segmentCtrl.segmentCount = Category.allCases.count
        Category.allCases.enumerated().forEach { index, element in
            segmentCtrl.setWidth(100, forSegment: index)
            segmentCtrl.setLabel(element.title, forSegment: index)
        }
        segmentCtrl.selectedSegmentBezelColor = .primaryColor
        
        refresh()
    }
    
    @objc func tableViewDoubleAction(_ sender: NSTableView) {
        guard tableView.clickedRow != -1 else { return }
        let selected = list[tableView.clickedRow]
        showVideo(id: selected.id, indicatorView: indicatorView)
    }
    @IBAction func segmentIndexChanged(_ sender: NSSegmentedControl) {
        category = Category(rawValue: sender.selectedSegment) ?? .film
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
