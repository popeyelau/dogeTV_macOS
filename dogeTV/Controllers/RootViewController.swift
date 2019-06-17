//
//  RootViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/15.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

protocol Refreshable where Self: NSViewController {
    func refresh()
}

class RootViewController: NSViewController {
    
    @IBOutlet weak var contentView: GradientView!
    @IBOutlet weak var menuView: GradientView!
    @IBOutlet weak var topView: GradientView!
    @IBOutlet weak var btnStack: NSStackView!
    @IBOutlet weak var searchBarView: SearchBarView!
    @IBOutlet weak var iconImageView: AspectFitImageView!
    @IBOutlet weak var playingStatusBar: PlayStatusView!
    @IBOutlet weak var refreshBtn: NSButton!
    
    var mapping: [String: Refreshable] = [:]
    var activiedController: Refreshable?
    var fromController: Refreshable?
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(red:0.12, green:0.13, blue:0.14, alpha:1.00).cgColor
        menuView.colors = NSColor.menuBarGradientColors
        topView.colors = NSColor.titleBarGradientColors

        iconImageView.focusRingType = .none
        if FileManager.default.fileExists(atPath: ENV.iconPath) {
            iconImageView.image = NSImage(contentsOfFile: ENV.iconPath)
            iconImageView.layer?.cornerRadius = 45
            iconImageView.layer?.masksToBounds = true
            iconImageView.layer?.backgroundColor = NSColor.black.cgColor
        }
        
        setupLeftMenus()
        setupRootView()
        registerActions()
        registerNotification()
        
        let trackingArea = NSTrackingArea(rect: refreshBtn.bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect, .assumeInside], owner: self, userInfo: nil)
        refreshBtn.addTrackingArea(trackingArea)
        
        view.window?.makeFirstResponder(nil)
    }
    
    func setupRootView() {
        let isUnlocked = Preferences.shared.get(key: .unlocked, default: false)
        let target: Refreshable = isUnlocked ? makeContentView(type: PumpkinViewController.self, key: Menus.recommended.rawValue) : makeContentView(type: LatestGridViewController.self, key: Menus.latest.rawValue)
        activiedController = target
        contentView.addSubview(target.view)
    }

    override func mouseEntered(with event: NSEvent) {
        refreshBtn.rotate360Degrees()
    }

    func registerNotification()  {
        NotificationCenter.default.addObserver(forName: .playStatusChanged, object: nil, queue: .main) { [weak self] (notify) in
            guard let status = notify.object as? PlayStatus else {
                return
            }
            self?.playingStatusBar.status = status
        }
    }
    
    func registerActions() {
        searchBarView.onTopRatedAction = { [weak self] in
            self?.showTopRated()
        }
        searchBarView.onSearchAction = { [weak self] keywords in
            self?.onSearch(keywords: keywords)
        }
    }
    

    func setupLeftMenus() {
        Menus.allCases.forEach {
            let btn = PPButton()
            btn.title = $0.title
            btn.identifier = .init($0.rawValue)
            btnStack.addArrangedSubview(btn)
            btn.action = #selector(menuBtnClicked(_:))
            btn.snp.makeConstraints {
                $0.width.equalToSuperview()
                $0.height.equalTo(30)
            }
            if $0 == .blueray {
                btn.toolTip = "可能需要通过代理访问"
            }
        }
        
        if let selectedBtn = btnStack.arrangedSubviews.first as? PPButton {
            //CMD+1 to root view.
            selectedBtn.isSelected = true
            selectedBtn.keyEquivalent = "1"
            selectedBtn.keyEquivalentModifierMask = .command
        }
    }
    

    @IBAction func feedbackAction(_ sender: NSButton) {
        openURL(with: sender)
    }

    

     @objc func menuBtnClicked(_ sender: PPButton) {
        view.window?.makeFirstResponder(nil)
        guard let identifier = sender.identifier?.rawValue, let menu = Menus(rawValue: identifier) else { return }
        resetButtons()
        sender.isSelected = true

        switch menu {
        case .recommended:
            let target = makeContentView(type: PumpkinViewController.self, key: identifier)
            makeTransition(to: target)
        case .latest:
            let target = makeContentView(type: LatestGridViewController.self, key: identifier)
            makeTransition(to: target)
        case .film,.drama,.cartoon,.variety,.documentary:
            let target = makeContentView(type: VideoGridViewController.self, key: identifier)
            target.category = Category.fromCategoryKey(identifier)
            makeTransition(to: target)
        case .live:
            let target = makeContentView(type: ChannelGridViewController.self, key: identifier)
            makeTransition(to: target)
        case .topic:
            let target = makeContentView(type: TopicsViewController.self, key: identifier)
            makeTransition(to: target)
        case .parse:
            let target = makeContentView(type: ParseViewController.self, key: identifier)
            makeTransition(to: target)
        case .tag:
            let target = makeContentView(type: TagGridViewController.self, key: identifier)
            makeTransition(to: target)
        case .blueray:
            let target = makeContentView(type: BlueRayTabViewController.self, key: identifier)
            makeTransition(to: target)
        }
    }

    @IBAction func refreshAction(_ sender: NSButton) {
        activiedController?.refresh()
    }
    
    @IBAction func dogeAction(_ sender: NSImageView) {
        sender.image?.save(isLogo: true)
        sender.layer?.cornerRadius = 45
        sender.layer?.masksToBounds = true
        sender.layer?.backgroundColor = NSColor.black.cgColor
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension RootViewController {
    func onSearch(keywords: String) {
        if keywords.isEmpty { return }
        if keywords == "解锁" && !Preferences.shared.get(key: .unlocked, default: false) {
            NSApplication.shared.unlocked()
            dialogOKCancel(question: "解锁成功", text: "点击「确定」开启隐藏功能") { (ok) in
                if(ok){
                   NSApplication.shared.relaunch()
                }
            }
            return
        }

        let target = makeContentView(type: SearchViewController.self, key: "search")
        target.keywords = keywords
        target.isHD = searchBarView.isHD
        target.startSearch(keywords: keywords)
        makeTransition(to: target)
        resetButtons()
    }
    
    func showTopRated() {
        resetButtons()
        let target = makeContentView(type: TopRatedViewController.self, key: "topRated")
        makeTransition(to: target)
    }
    
    func showSeries(id: String, title: String? = nil) {
        let target = makeContentView(type: SerieGridViewController.self, key: "series")
        target.title = title
        target.id = id
        makeTransition(to: target)
    }
    
    func back() {
        guard let from = fromController else {
            return
        }
        makeTransition(to: from)
    }

    func resetButtons() {
        for view in btnStack.subviews {
            if let btn = view as? PPButton {
                btn.isSelected = false
            }
        }
    }
    
    func makeContentView<T>(type:T.Type, key: String) -> T where T: Refreshable {
        if let target = mapping[key] as? T {
            return target
        }
        let target = type.init()
        mapping[key] = target
        addChild(target)
        return target
    }
    
    func makeTransition(to: Refreshable, options: TransitionOptions = .crossfade) {
        guard let from = activiedController else { return }
        transition(from: from, to: to, options: options) {
            self.fromController = from
            self.activiedController = to
        }
    }
}



