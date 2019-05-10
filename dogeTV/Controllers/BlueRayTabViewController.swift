//
//  BlueRayTabViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/5/8.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class BlueRayTabViewController: NSViewController {
    @IBOutlet weak var segmentCtrl: CustomSegmentedControl!
    @IBOutlet weak var tabView: NSTabView!
    var selectedCategory: TabItems = .film

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.backgroundColor.cgColor
        
        tabView.tabPosition = .none
        tabView.tabViewBorderType = .none

        tabView.tabViewItems = TabItems.allCases.map { category in
            let controller = BlueRayGridViewController()
            controller.category = category
            let item = NSTabViewItem(viewController: controller)
            item.label = category.title
            return item
        }

        TabItems.allCases.enumerated().forEach { index, element in
            segmentCtrl.addSegment(withTitle: element.title)
        }
        segmentCtrl.selectedIndex = selectedCategory.rawValue
    }

    @IBAction func segmentIndexChanged(_ sender: CustomSegmentedControl) {
        guard let index = sender.selectedIndex else { return }
        selectedCategory = TabItems(rawValue: index) ?? .film
        tabView.selectTabViewItem(at: index)
    }
}


extension BlueRayTabViewController: Initializable {
    func refresh() {
        guard let index = segmentCtrl.selectedIndex else { return }
        guard let controller = tabView.tabViewItems[safe: index]?.viewController as? Initializable else { return }
        controller.refresh()
    }

    enum TabItems: Int, CaseIterable {
        case film
        case drama
        case cartoon
        case variety

        var key: String {
            switch self {
            case .film: return "1"
            case .drama: return "2"
            case .cartoon: return "3"
            case .variety: return "4"
            }
        }

        var title: String {
            switch self {
            case .film: return "电影"
            case .drama: return "电视剧"
            case .cartoon: return "动漫"
            case .variety: return "综艺"
            }
        }
    }
}
