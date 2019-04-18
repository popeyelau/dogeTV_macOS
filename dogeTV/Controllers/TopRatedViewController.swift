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
    @IBOutlet weak var incdicatorView: NSProgressIndicator!
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleAction(_:))
        segmentCtrl.selectedSegment = category.rawValue
        segmentCtrl.segmentCount = Category.allCases.count
        Category.allCases.enumerated().forEach { index, element in
            segmentCtrl.setWidth(100, forSegment: index)
            segmentCtrl.setLabel(element.title, forSegment: index)
        }
    }
    
    @objc func tableViewDoubleAction(_ sender: NSTableView) {
        guard tableView.clickedRow != -1 else { return }
        let selected = list[tableView.clickedRow]
        showVideo(id: selected.id)
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

    func showVideo(id: String) {
        incdicatorView.isHidden = false
        incdicatorView.startAnimation(nil)
        attempt(maximumRetryCount: 3) {
            when(fulfilled: APIClient.fetchVideo(id: id),
                 APIClient.fetchEpisodes(id: id))
            }.done { detail, episodes in
                let window = AppWindowController(windowNibName: "AppWindowController")
                let content = PlayerViewController()
                content.videDetail = detail
                content.episodes = episodes
                window.content = content
                window.show(from:self.view.window)
            }.catch{ error in
                print(error)
            }.finally {
                self.incdicatorView.stopAnimation(nil)
                self.incdicatorView.isHidden = true
        }
    }
}

extension TopRatedViewController {
    func refresh() {
        incdicatorView.isHidden = false
        incdicatorView.startAnimation(nil)
        attempt(maximumRetryCount: 3) {
            APIClient.fetchRankList(category: self.category)
            }.done { (list) in
                self.list = list
            }.catch({ (error) in
                print(error)
            }).finally {
                self.tableView.reloadData()
                self.incdicatorView.stopAnimation(nil)
                self.incdicatorView.isHidden = true
                self.tableView.scrollToVisible(.zero)
        }
    }
}

extension TopRatedViewController: Initializable {}
