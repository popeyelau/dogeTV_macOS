//
//  RootViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/15.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
protocol Initializable where Self: NSViewController {}

class RootViewController: NSViewController {
    
    @IBOutlet weak var contentView: ContainerView!
    @IBOutlet weak var menuView: NSView!
    @IBOutlet weak var topView: NSView!
    @IBOutlet weak var btnStack: NSStackView!
    @IBOutlet weak var searchBarView: SearchBarView!
    @IBOutlet weak var latestBtn: PPButton!
    @IBOutlet weak var filmBtn: PPButton!
    @IBOutlet weak var dramaBtn: PPButton!
    @IBOutlet weak var varietyBtn: PPButton!
    @IBOutlet weak var cartoonBtn: PPButton!
    @IBOutlet weak var documentaryBtn: PPButton!
    @IBOutlet weak var liveBtn: PPButton!
    @IBOutlet weak var homeBtn: NSButton!
    @IBOutlet weak var versionBtn: NSButton!

    var mapping: [String: Initializable] = [:]
    var activiedController: NSViewController?
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.wantsLayer = true
        contentView.layer?.cornerRadius = 6
        contentView.layer?.masksToBounds = true
        //contentView.layer?.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        let target = makeContentView(type: LatestGridViewController.self, key: "latest")
        activiedController = target
        contentView.addSubview(target.view)
        latestBtn.isSelected = true

        NotificationCenter.default.addObserver(self, selector: #selector(handleMoreNotification(_:)), name: .init(rawValue: "com.dogetv.more"), object: nil)
        
        searchBarView.onTopRatedAction = { [weak self] in
            self?.showTopRated()
        }
        searchBarView.onSearchAction = { [weak self] keywords in
            self?.onSearch(keywords: keywords)
        }
        

        let trackingArea = NSTrackingArea(rect: homeBtn.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        homeBtn.addTrackingArea(trackingArea)
        homeBtn.focusRingType = .none
        view.window?.makeFirstResponder(nil)



        if let infoDictionary = Bundle.main.infoDictionary {
            if let version = infoDictionary["CFBundleShortVersionString"] as? String, let build = infoDictionary[String(kCFBundleVersionKey)] as? String {
                versionBtn.title = "Version: \(version)(\(build))"
            }
        }

    }
    
    @objc func handleMoreNotification(_ notify: Notification) {
        guard let title = notify.object as? String else { return }
        let index = VideoCategory.sections.firstIndex(of: title) ?? 0
        let category = Category(rawValue: index)!
        switch category {
        case .film: menuBtnClicked(filmBtn)
        case .drama: menuBtnClicked(dramaBtn)
        case .variety: menuBtnClicked(varietyBtn)
        case .cartoon: menuBtnClicked(cartoonBtn)
        case .documentary: menuBtnClicked(documentaryBtn)
        }
    }
    @IBAction func userAction(_ sender: NSButton) {
        resetButtons()
        let target = makeContentView(type: UserViewController.self, key: "history")
        makeTransition(to: target)
    }

    override func mouseEntered(with event: NSEvent) {
        homeBtn.rotate360Degrees()
    }

    func showTopRated() {
        resetButtons()
        let target = makeContentView(type: TopRatedViewController.self, key: "topRated")
        makeTransition(to: target)
    }
    
    @IBAction func homeAction(_ sender: NSButton) {
        menuBtnClicked(latestBtn)
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.isMovableByWindowBackground = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func menuBtnClicked(_ sender: PPButton) {
        view.window?.makeFirstResponder(nil)
        guard let identifier = sender.identifier?.rawValue, !identifier.isEmpty else { return }
        resetButtons()
        sender.isSelected = true
        switch identifier {
        case "latest":
            let target = makeContentView(type: LatestGridViewController.self, key: identifier)
            makeTransition(to: target)
        case Category.film.categoryKey, Category.drama.categoryKey, Category.variety.categoryKey, Category.cartoon.categoryKey, Category.documentary.categoryKey:
            let target = makeContentView(type: VideoGridViewController.self, key: identifier)
            target.category = .fromCategoryKey(identifier)
            makeTransition(to: target)
        case "live":
            let target = makeContentView(type: ChannelGridViewController.self, key: identifier)
            makeTransition(to: target)
        case "topic":
            let target = makeContentView(type: TopicsViewController.self, key: identifier)
            makeTransition(to: target)
        default: break
        }
    }
    
    
    func makeContentView<T>(type:T.Type, key: String) -> T where T: Initializable {
        if let target = mapping[key] as? T {
            return target
        }
        let target = type.init()
        mapping[key] = target
        addChild(target)
        return target
    }
    
    func resetButtons() {
        for view in btnStack.subviews {
            if let btn = view as? PPButton {
                btn.isSelected = false
            }
        }
    }

    func makeTransition(to: NSViewController) {
        guard let from = activiedController else { return }
        transition(from: from, to: to, options: .crossfade) {
            self.activiedController = to
        }
    }

    func onSearch(keywords: String) {
        if keywords.isEmpty { return }
        let target = makeContentView(type: SearchViewController.self, key: "search")
        target.keywords = keywords
        target.startSearch(keywords: keywords)
        makeTransition(to: target)
        resetButtons()
    }

    @IBAction func openURL(_ sender: NSButton) {
        openURL(with: sender)
    }

    @IBAction func checkUpdateAction(_ sender: NSButton) {
        //TODO:
    }
}


