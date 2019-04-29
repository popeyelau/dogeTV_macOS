//
//  RootViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/15.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

protocol Initializable where Self: NSViewController {
    func refresh()
}

class RootViewController: NSViewController {
    
    @IBOutlet weak var contentView: ContainerView!
    @IBOutlet weak var menuView: NSView!
    @IBOutlet weak var topView: NSView!
    @IBOutlet weak var btnStack: NSStackView!
    @IBOutlet weak var searchBarView: SearchBarView!
    @IBOutlet weak var iconImageView: AspectFitImageView!
    @IBOutlet weak var versionBtn: NSButton!

    var mapping: [String: Initializable] = [:]
    var activiedController: Initializable?
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.wantsLayer = true
        contentView.layer?.cornerRadius = 6
        contentView.layer?.masksToBounds = true

        iconImageView.focusRingType = .none
        if FileManager.default.fileExists(atPath: ENV.iconPath) {
            iconImageView.image = NSImage(contentsOfFile: ENV.iconPath)
            iconImageView.layer?.cornerRadius = 45
            iconImageView.layer?.masksToBounds = true
            iconImageView.layer?.backgroundColor = NSColor.black.cgColor
        }
        
        setupLeftMenus()
        
        let target = makeContentView(type: LatestGridViewController.self, key: "latest")
        activiedController = target
        contentView.addSubview(target.view)
        
        searchBarView.onTopRatedAction = { [weak self] in
            self?.showTopRated()
        }
        searchBarView.onSearchAction = { [weak self] keywords in
            self?.onSearch(keywords: keywords)
        }
        
        view.window?.makeFirstResponder(nil)

        if let infoDictionary = Bundle.main.infoDictionary {
            if let version = infoDictionary["CFBundleShortVersionString"] as? String, let build = infoDictionary[String(kCFBundleVersionKey)] as? String {
                versionBtn.title = "Version: \(version)(\(build))"
            }
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
        }
        
        if let selectedBtn = btnStack.arrangedSubviews.first as? PPButton {
            selectedBtn.isSelected = true
        }
    }
    

    @IBAction func userAction(_ sender: NSButton) {
        resetButtons()
        let target = makeContentView(type: UserViewController.self, key: "history")
        makeTransition(to: target)
    }

    

     @objc func menuBtnClicked(_ sender: PPButton) {
        view.window?.makeFirstResponder(nil)
        guard let identifier = sender.identifier?.rawValue, let menu = Menus(rawValue: identifier) else { return }
        resetButtons()
        sender.isSelected = true

        switch menu {
        case .latest:
            let target = makeContentView(type: LatestGridViewController.self, key: identifier)
            makeTransition(to: target)
        case .film, .drama, .variety, .cartoon, .documentary:
            let target = makeContentView(type: VideoGridViewController.self, key: identifier)
            target.category = .fromCategoryKey(identifier)
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
        }
    }
    
    @IBAction func openURL(_ sender: NSButton) {
        openURL(with: sender)
    }

    @IBAction func checkUpdateAction(_ sender: Any) {
        NSApplication.shared.checkForUpdates(background: true)
    }
    
    @IBAction func refreshAction(_ sender: NSButton) {
        activiedController?.refresh()
    }
    
    @IBAction func dogeAction(_ sender: NSImageView) {
        sender.image?.saveAsLogo()
        sender.layer?.cornerRadius = 45
        sender.layer?.masksToBounds = true
        sender.layer?.backgroundColor = NSColor.black.cgColor
    }
}


extension RootViewController {
    func onSearch(keywords: String) {
        if keywords.isEmpty { return }
        let target = makeContentView(type: SearchViewController.self, key: "search")
        target.keywords = keywords
        target.startSearch(keywords: keywords)
        makeTransition(to: target)
        resetButtons()
    }
    
    func showTopRated() {
        resetButtons()
        let target = makeContentView(type: TopRatedViewController.self, key: "topRated")
        makeTransition(to: target)
    }
    
    func resetButtons() {
        for view in btnStack.subviews {
            if let btn = view as? PPButton {
                btn.isSelected = false
            }
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
    
    func makeTransition(to: Initializable) {
        guard let from = activiedController else { return }
        transition(from: from, to: to, options: .crossfade) {
            self.activiedController = to
        }
    }
}


