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
    private var separators: [NSBox] = []

    private lazy var stackView: NSStackView = {
        let stackView = NSStackView()
        stackView.orientation = .horizontal
        stackView.alignment = .centerY
        stackView.distribution = NSStackView.Distribution.fillEqually
        stackView.spacing = 15
        return stackView
    }()

    private lazy var separator: NSBox = {
        let separator: NSBox = NSBox()
        separator.boxType = NSBox.BoxType.custom
        separator.borderColor = NSColor.primaryColor
        return separator
    }()

    var titles: [String] = []

    var selectedIndex: Int? = nil {
        didSet {
            updateSelection()
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        unifiedInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        unifiedInit()
    }

    func unifiedInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        addSubview(separator)

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        positionButtons()
    }

    private func updateSelection() {
        for button in buttons {
            button.state = .off
        }

        if buttons.count > 0 && selectedIndex != nil {
            let btn = buttons[selectedIndex!]
            btn.state = .on
            separator.snp.remakeConstraints {
                $0.top.equalTo(btn.snp.bottom).offset(5)
                $0.left.right.equalTo(btn)
                $0.height.equalTo(1)
            }
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

    private func positionButtons() {
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()

        separators.forEach { $0.removeFromSuperview() }
        separators.removeAll()

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for title in titles {
            let newButton: NSButton = NSButton(title: title, target: self, action: #selector(CustomSegmentedControl.handleSegmentPress(_:)))
            newButton.setButtonType(.toggle)
            newButton.bezelStyle = .regularSquare
            newButton.isBordered = false
            newButton.font = NSFont.systemFont(ofSize: 16)
            buttons.append(newButton)

            /*
            let newSeparator: NSBox = NSBox()
            newSeparator.boxType = NSBox.BoxType.separator
            separators.append(newSeparator)*/

            stackView.addArrangedSubview(newButton)
            //stackView.addArrangedSubview(newSeparator)
        }

        separators.last?.isHidden = true
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
        positionButtons()
    }

}
