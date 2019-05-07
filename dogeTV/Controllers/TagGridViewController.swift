//
//  TagGridViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/5/7.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

enum TabItems: CaseIterable {
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

}

class TagGridViewController: NSViewController {

    @IBOutlet weak var segmentCtrl: NSSegmentedControl!
    @IBOutlet weak var tabView: NSTabView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tabView.tabPosition = .none
        tabView.tabViewBorderType = .none
        
        
        tabView.tabViewItems = TabItems.allCases.map { tag in
            let item = NSTabViewItem(viewController: HomeViewController())
            item.label = tag.title
            return item
            
        }
        segmentCtrl.segmentCount = TabItems.allCases.count
        TabItems.allCases.enumerated().forEach { index, element in
            segmentCtrl.setWidth(60, forSegment: index)
            segmentCtrl.setLabel(element.title, forSegment: index)
        }
    }
    
    @IBAction func segmentIndexChanged(_ sender: NSSegmentedControl) {
        tabView.selectTabViewItem(at: sender.selectedSegment)
    }
}


extension TagGridViewController: Initializable {
    func refresh() {
        
    }
}
