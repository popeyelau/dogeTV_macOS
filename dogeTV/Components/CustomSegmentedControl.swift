//
//  CustomSegmentedControl.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/5/7.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa

class CustomSegmentedControl: NSControl {

    private var buttons: [NSButton] = []

    private lazy var stackView: NSStackView = {
        let stackView = NSStackView()
        stackView.orientation = .horizontal
        stackView.alignment = .centerY
//        stackView.distribution = .fill
        return stackView
    }()

    var titles: [String] = [] {
        didSet {
            positionButtons()
            updateSelection()
        }
    }

    var selectedIndex: Int? = nil {
        didSet {
            updateSelection()
        }
    }
    
    var selectedIdentifier: NSUserInterfaceItemIdentifier? {
        guard let index = selectedIndex else { return nil }
        return buttons[index].identifier
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        addSubview(stackView)
        wantsLayer = true
        layer?.backgroundColor = NSColor.activedBackgroundColor.withAlphaComponent(0.4).cgColor
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(3)
        }
        positionButtons()
    }
    
    override func layout() {
        super.layout()
        layer?.cornerRadius = frame.height * 0.5
    }

    private func updateSelection() {
        buttons.forEach {
            $0.state = .off
            $0.layer?.backgroundColor = NSColor.clear.cgColor
        }

        if let index = selectedIndex, let selectedBtn = buttons[safe: index] {
            selectedBtn.state = .on
            selectedBtn.layer?.backgroundColor = NSColor.activedBackgroundColor.cgColor
        }
    }

    func addSegment(withTitle title: String, at index: Int = -1) {
        if index == -1 {
            titles.append(title)
        } else {
            titles.insert(title, at: index)
        }

        positionButtons()
        updateSelection()
    }

    func setTitle(title: String, ofSegment segment: Int) {
        buttons[segment].title = title
    }
    
    func setIdentifier(_ identifier: NSUserInterfaceItemIdentifier, ofSegment segment: Int) {
        buttons[segment].identifier = identifier
    }

    private func positionButtons() {
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        
        titles.enumerated().forEach { (index, title) in
            let btn: NSButton = NSButton(title: title, target: self, action: #selector(CustomSegmentedControl.handleSegmentPress(_:)))
            btn.setButtonType(.toggle)
            btn.bezelStyle = .regularSquare
            btn.isBordered = false
            btn.wantsLayer = true
            btn.layer?.cornerRadius = 15
            btn.font = NSFont.systemFont(ofSize: 14)
            buttons.append(btn)
            stackView.addArrangedSubview(btn)
            btn.snp.makeConstraints {
                $0.width.greaterThanOrEqualTo(70)
                $0.height.equalTo(30)
            }
        }

        updateSelection()
    }

    func setEnabled(segment: Int, enabled: Bool) {
        buttons[segment].isEnabled = enabled
    }

    func isEnabled(segment: Int) -> Bool {
        return buttons[segment].isEnabled
    }

    @objc private func handleSegmentPress(_ sender: NSButton) {
        if let index: Int = buttons.firstIndex(of: sender) {
            selectedIndex = index
            sendAction(action, to: target)
        }
    }

    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
    }

}
