//
//  TagGridViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/5/7.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class TagGridViewController: NSViewController {
    @IBOutlet weak var segmentCtrl: CustomSegmentedControl!
    @IBOutlet weak var tabView: NSTabView!
    var selectedCategory: TabItems = .action
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.backgroundColor.cgColor
        
        tabView.tabPosition = .none
        tabView.tabViewBorderType = .none
        
        tabView.tabViewItems = TabItems.allCases.map { tag in
            let controller = PumpkinViewController()
            controller.sourceType = .category(category: tag.key)
            let item = NSTabViewItem(viewController: controller)
            item.label = tag.title
            return item
        }
        
        TabItems.allCases.enumerated().forEach { index, element in
            segmentCtrl.addSegment(withTitle: element.title)
        }
        segmentCtrl.selectedIndex = selectedCategory.rawValue
    }
    
    @IBAction func segmentIndexChanged(_ sender: CustomSegmentedControl) {
        guard let index = sender.selectedIndex else { return }
        selectedCategory = TabItems(rawValue: index) ?? .action
        tabView.selectTabViewItem(at: index)
    }
}


extension TagGridViewController: Initializable {
    func refresh() {
        guard let index = segmentCtrl.selectedIndex else { return }
        guard let controller = tabView.tabViewItems[safe: index]?.viewController as? Initializable else { return }
        controller.refresh()
    }


    enum TabItems: Int, CaseIterable {
        case action //动作
        case war //战争
        case sf //科幻
        case risk //冒险
        case serial //电视剧
        case crime //犯罪
        case disaster //灾难
        case magic //魔幻
        case suspense //悬疑
        case feature //剧情
        case terror //恐怖
        case west //西部

        var title: String {
            switch self {
            case .action: return "动作"
            case .war: return "战争"
            case .sf: return "科幻"
            case .risk: return "冒险"
            case .serial: return "电视剧"
            case .crime: return "犯罪"
            case .disaster: return "灾难"
            case .magic: return "魔幻"
            case .suspense: return "悬疑"
            case .feature: return "剧情"
            case .terror: return "恐怖"
            case .west: return "西部"
            }
        }

        var key: String {
            switch self {
            case .action: return "CATG_ACTION"
            case .war: return "CATG_WAR"
            case .sf: return "CATG_SF"
            case .risk: return "CATG_RISK"
            case .serial: return "CATG_SERIAL"
            case .crime: return "CATG_CRIME"
            case .disaster: return "CATG_DISASTER"
            case .magic: return "CATG_MAGIC"
            case .suspense: return "CATG_SUSPENSE"
            case .feature: return "CATG_FEATURE"
            case .terror: return "CATG_TERROR"
            case .west: return "CATG_WEST"
            }
        }

    }
}
