//
//  LibraryViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/5/17.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class LibraryViewController: NSViewController {
    @IBOutlet weak var segmentCtrl: CustomSegmentedControl!
    @IBOutlet weak var tabView: NSTabView!
    var selectedCategory: Category = .film
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.backgroundColor.cgColor
        
        tabView.tabPosition = .none
        tabView.tabViewBorderType = .none
        
        
        
        tabView.tabViewItems = Category.allCases.map { category in
            let controller = VideoGridViewController()
            controller.category = category
            let item = NSTabViewItem(viewController: controller)
            item.label = category.title
            return item
        }
        
        segmentCtrl.titles = Category.allCases.map { $0.title }
        segmentCtrl.selectedIndex = selectedCategory.rawValue
    }
    
    @IBAction func segmentIndexChanged(_ sender: CustomSegmentedControl) {
        guard let index = sender.selectedIndex else { return }
        selectedCategory = Category(rawValue: index) ?? .film
        tabView.selectTabViewItem(at: index)
    }
}


extension LibraryViewController: Refreshable {
    func refresh() {
        guard let index = segmentCtrl.selectedIndex else { return }
        guard let controller = tabView.tabViewItems[safe: index]?.viewController as? Refreshable else { return }
        controller.refresh()
    }
}
