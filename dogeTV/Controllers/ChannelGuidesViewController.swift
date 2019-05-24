//
//  ChannelGuidesViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/5/24.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class ChannelGuidesViewController: NSViewController {
    let guides: [String]
    
    init(guides: [String]) {
        self.guides = guides
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        guides = []
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}

extension ChannelGuidesViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    enum Columns: String, CaseIterable {
        case time
        case name
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return guides.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let id = tableColumn?.identifier,
            let column = Columns(rawValue: id.rawValue),
            let cell = tableView.makeView(withIdentifier: .init(rawValue: "cell"), owner: nil) as? NSTableCellView else {
                return nil
        }
        
        let item = guides[row]
        var time: String?
        var program: String?
        
        if let whitespace = item.firstIndex(of: " ") {
            time = String(item[...whitespace])
            program = String(item[whitespace...])
        }
        
        switch column {
        case .time:
            cell.textField?.stringValue = time ?? item
        case .name:
            cell.textField?.stringValue = program ?? item
        }
        return cell
    }
}

