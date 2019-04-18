//
//  PlayerViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/16.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import AVKit

class PlayerViewController: NSViewController {
    
    enum Section {
        case episodes([Episode])
        case source([Int])
        case video(Video)

        var title: String {
            switch self {
            case .episodes:
                return "分集"
            case .source:
                return "线路"
            case .video:
                return "简介"
            }
        }
    }

    var videDetail: VideoDetail?
    var episodes: [Episode]?
    var episodeIndex: Int = 0
    var sourceIndex: Int = 0
    var dataSource: [Section] = []
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var episodePanel: NSScrollView!
    @IBOutlet weak var episodePanelWidth: NSLayoutConstraint!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var avPlayer: AVPlayerView!
    @IBOutlet weak var toggleBtn: NSButton!
    @IBOutlet weak var incdicatorView: NSProgressIndicator!
    var titleText: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        episodePanel.wantsLayer = true
        episodePanel.backgroundColor = NSColor(srgbRed:0.12, green:0.12, blue:0.13, alpha:1.00)
        titleLabel.stringValue = titleText ?? ""
        updateDataSource()
        if let playing = episodes?[safe: episodeIndex] {
            play(episode: playing)
        }

        let trackingArea = NSTrackingArea(rect: view.bounds, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea)
    }

    override func mouseEntered(with event: NSEvent) {
        toggleBtn.isHidden = false
    }

    override func mouseExited(with event: NSEvent) {
        toggleBtn.isHidden = true
    }

    @IBAction func toggleEpisodePanel(_ sender: NSButton) {
        if episodePanelWidth.constant == 0 {
            episodePanelWidth.constant = 400
            toggleBtn.image = NSImage(named: "toggle_off")
        } else {
            episodePanelWidth.constant = 0
            toggleBtn.image = NSImage(named: "toggle_on")
        }
    }
    
    func play(episode: Episode) {
        if videDetail == nil {
            titleLabel.stringValue = "\(titleText ?? "") - \(episode.title)"
        } else {
            titleLabel.stringValue = "\(videDetail?.info.name ?? "") - \(episode.title)"
        }
        if episode.canPlay {
            avPlayer.player = AVPlayer(url: URL(string: episode.url)!)
            avPlayer.player?.play()
            return
        }
        
        
        incdicatorView.isHidden = false
        incdicatorView.startAnimation(nil)
        _ = APIClient.resolveUrl(url: episode.url)
            .done { (url) in
                self.avPlayer.player = AVPlayer(url: URL(string: url)!)
                self.avPlayer.player?.play()
            }.catch({ (error) in
                print(error)
            }).finally {
                self.incdicatorView.stopAnimation(nil)
                self.incdicatorView.isHidden = true
        }
        
    }
    
    func updateSource(index: Int) {
        guard let id = videDetail?.info.id else { return }
        incdicatorView.isHidden = false
        incdicatorView.startAnimation(nil)
        _ = APIClient.fetchEpisodes(id: id, source: index).done { (episodes) in
            self.episodes = episodes
            }.catch({ (error) in
                print(error)
            }).finally {
                self.updateDataSource()
                self.incdicatorView.stopAnimation(nil)
                self.incdicatorView.isHidden = true
        }
    }
    
    func updateDataSource() {
        dataSource.removeAll()
        if let eipsodes = episodes {
            dataSource.append(.episodes(eipsodes))
        }
        if let video = videDetail?.info {
            dataSource.insert(.source(Array((0..<min(video.source,5)))), at: 0)
            dataSource.insert(.video(video), at: 0)
        }
        collectionView.reloadData()
    }
}


extension PlayerViewController: NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = dataSource[section]
        switch section {
        case .episodes(let episodes):
            return episodes.count
        case .source(let source):
            return source.count
        case .video:
            return 1
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let section = dataSource[indexPath.section]
        switch section {
        case .episodes(let episodes):
            let item = collectionView.makeItem(withIdentifier: .init("EpisodeItemView"), for: indexPath) as! EpisodeItemView
            let episode = episodes[indexPath.item]
            item.textField?.stringValue = episode.title
            item.textField?.alignment = .center
            item.isSelected = episodeIndex == indexPath.item
            return item
        case .source(let sources):
            let item = collectionView.makeItem(withIdentifier: .init("EpisodeItemView"), for: indexPath) as! EpisodeItemView
            let source = sources[indexPath.item]
            item.textField?.stringValue = source == 0 ? "默认线路" : "线路\(source)"
            item.textField?.alignment = .center
            item.isSelected = sourceIndex == indexPath.item
            return item
        case .video(let video):
            let item = collectionView.makeItem(withIdentifier: .init("VideoIntroView"), for: indexPath) as! VideoIntroView
            item.textField?.stringValue =  "导演: \(video.director)\n主演: \(video.actor))\n国家/地区: \(video.area)\n上映: \(video.year )\n类型: \(video.tag)\n\(video.state)"
            item.imageView?.setResourceImage(with: video.cover)
            return item
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        let header = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: .init("GridSectionHeader"), for: indexPath) as! GridSectionHeader
        let section = dataSource[indexPath.section]
        header.titleLabel.stringValue = section.title
        header.titleLabel.font = NSFont.systemFont(ofSize: 14)
        header.moreButton.isHidden = true
        return header
    }
    
    
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        collectionView.deselectItems(at: indexPaths)
        let section = dataSource[indexPath.section]
        switch section {
        case .episodes(let episodes):
            let episode = episodes[indexPath.item]
            episodeIndex = indexPath.item
            collectionView.reloadSections([indexPath.section])
            avPlayer.player?.pause()
            play(episode: episode)
            return
        case .source(let sources):
            let source = sources[indexPath.item]
            sourceIndex = indexPath.item
            collectionView.reloadSections([indexPath.section])
            updateSource(index: source)
        case .video:
            break
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
          let section = dataSource[indexPath.section]
        switch section {
        case .source:
            return NSSize(width: 90, height: 30)
        case .episodes(let episodes):
            let title = episodes[indexPath.item].title
            let width = title.widthOfString(usingFont: .systemFont(ofSize: 14)) + 20
            return NSSize(width: width, height: 30)
        case .video:
            return NSSize(width: collectionView.bounds.width - 32, height: 200)
        }
    }
    
}

