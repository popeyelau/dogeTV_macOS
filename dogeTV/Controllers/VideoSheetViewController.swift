//
//  VideoSheetViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/5/14.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import AVKit
import PromiseKit

class VideoSheetViewController: NSViewController {
    
    enum Section {
        case episodes([Episode])
        case source([Int])
        case video(Video)
        case recommends([Video])
        case seasons([Seasons])
        
        var title: String {
            switch self {
            case .episodes:
                return "选集"
            case .source:
                return "线路"
            case .video:
                return "简介"
            case .recommends:
                return "猜你喜欢"
            case .seasons:
                return "分季"
            }
        }
    }
    
    var videDetail: VideoDetail?
    var episodes: [Episode]?
    
    var episodeIndex: Int = 0
    var playingEpisode: Episode?
    var sourceIndex: Int = 0
    var seasonIndex: Int = 0
    var dataSource: [Section] = []
    
    @IBOutlet weak var bottomView: NSView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var downloadBtn: NSButton!
    @IBOutlet weak var actionStackView: NSStackView!
    var hideToggleBtn = true
    var titleText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.activedBackgroundColor.cgColor
        collectionView.backgroundColors = [.backgroundColor]
        updateDataSource()
        downloadBtn.isHidden = !NSApplication.shared.isDownieInstalled
        titleLabel.stringValue = titleText ?? (videDetail?.info.name ?? "")
        
        if episodes?.count == 1 {
           playing()
        }
    }
    
    @IBAction func dismissBtn(_ sender: NSButton) {
        dismiss(sender)
    }
    
    func playing() {
        if let playing = episodes?[safe: episodeIndex] {
            play(episode: playing)
        }
    }
    


    @IBAction func openMainWindowAction(_ sender: NSButton) {
        NSApplication.shared.appDelegate?.mainWindowController?.window?.makeKeyAndOrderFront(nil)
    }
    
    @IBAction func shareAction(_ sender: NSButton) {
        guard let playing = playingEpisode, playing.canPlay else {
            return
        }
        guard let image = QRCode.createQRImage(message: playing.url),let saved = image.save() else {
            return
        }
        NSWorkspace.shared.open(saved)
    }
    
    @IBAction func downloadAction(_ sender: NSButton) {
        guard NSApplication.shared.isDownieInstalled else { return }
        guard let playing = playingEpisode, playing.canPlay else { return }
        
        let url = URL(string: "downie://XUOpenLink?url=\(playing.url)")!
        NSWorkspace.shared.open(url)
    }
    
    func play(episode: Episode) {
        playingEpisode = episode
        if episode.canPlay {
            self.prepareToPlay(url: episode.url)
            return
        }
        
        getStreamURL(episode: episode)
    }
    
    func getStreamURL(episode: Episode) {
        if let id = episode.id,  episode.url.isEmpty {
            APIClient.fetchPumpkinEpisodes(id: id)
                .done { episodes in
                    if let url = episodes.last?.url {
                        self.prepareToPlay(url: url)
                    }
                }.catch{ error in
                    print(error)
                    self.showError(error)
                }.finally {
            }
            return
        }
        
        APIClient.resolveUrl(url: episode.url)
            .done { (url) in
                self.prepareToPlay(url: url)
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
        }
    }
    
    func prepareToPlay(url: String) {
        if Preferences.shared.usingIINA {
            NSApplication.shared.launchIINA(withURL: url)
            return
        }
    }
    
    func updateSource(index: Int) {
        guard let id = videDetail?.info.id else { return }
        _ = APIClient.fetchEpisodes(id: id, source: index).done { (episodes) in
            self.episodes = episodes
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
                self.updateDataSource()
                self.updatePlayingEpisodeIfNeeded()
        }
    }
    
    func updateSeason(index: Int, sid: String) {
        guard let id = videDetail?.info.id else { return }
        _ = APIClient.fetchPumpkinSeason(id: id, sid: sid).done { (detail) in
            guard let seasons = detail.seasons, let episodes = seasons[safe: index]?.episodes else {
                return
            }
            self.episodeIndex = 0
            self.seasonIndex = index
            self.videDetail = detail
            self.episodes = episodes
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
                self.updateDataSource()
                self.updatePlayingEpisodeIfNeeded()
        }
    }
    
    func updatePlayingEpisodeIfNeeded() {
        guard let playing = playingEpisode,
            let updated = episodes?[safe: episodeIndex] else {
                return
        }
        if playing != updated{
            play(episode: updated)
        }
    }
    
    func updateDataSource() {
        dataSource.removeAll()
        if let video = videDetail?.info {
            dataSource.insert(.video(video), at: 0)
            if video.source > 0 {
                dataSource.append(.source(Array((0..<min(video.source,5)))))
            }
        }
        
        if let seasons = videDetail?.seasons, !seasons.isEmpty {
            dataSource.append(.seasons(seasons))
        }
        
        if let eipsodes = episodes, !eipsodes.isEmpty {
            dataSource.append(.episodes(eipsodes))
        }
        
        if let recommends = videDetail?.recommends, !recommends.isEmpty {
            dataSource.append(.recommends(recommends))
        }
        
        collectionView.reloadData()
        collectionView.scrollToVisible(.zero)
    }
    
    func replace(video: Video) {
        showVideo(video: video)
    }
    
    deinit {
        print("deinit")
    }
}


extension VideoSheetViewController: NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {
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
        case .recommends(let videos):
            return videos.count
        case .seasons(let seasons):
            return seasons.count
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let section = dataSource[indexPath.section]
        switch section {
        case .episodes(let episodes):
            let item = collectionView.makeItem(withIdentifier: .episodeItemView, for: indexPath) as! EpisodeItemView
            let episode = episodes[indexPath.item]
            item.textField?.stringValue = episode.title
            item.textField?.alignment = .center
            item.isSelected = episodeIndex == indexPath.item
            return item
        case .source(let sources):
            let item = collectionView.makeItem(withIdentifier: .episodeItemView, for: indexPath) as! EpisodeItemView
            let source = sources[indexPath.item]
            item.textField?.stringValue = source == 0 ? "默认线路" : "线路\(source)"
            item.textField?.alignment = .center
            item.isSelected = sourceIndex == indexPath.item
            return item
        case .video(let video):
            let item = collectionView.makeItem(withIdentifier: .videoIntroView, for: indexPath) as! VideoIntroView
            item.textField?.stringValue =  "导演: \(video.director)\n主演: \(video.actor))\n国家/地区: \(video.area)\n上映: \(video.year )\n类型: \(video.tag)\n\(video.state)"
            item.imageView?.setResourceImage(with: video.cover)
            return item
        case .recommends(let videos):
            let item = collectionView.makeItem(withIdentifier: .videoCardView, for: indexPath) as! VideoCardView
            let video = videos[indexPath.item]
            item.data = video
            return item
        case .seasons(let seasons):
            let item = collectionView.makeItem(withIdentifier: .episodeItemView, for: indexPath) as! EpisodeItemView
            let season = seasons[indexPath.item]
            item.textField?.stringValue = season.name
            item.textField?.alignment = .center
            item.isSelected = seasonIndex == indexPath.item
            return item
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        let header = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: .gridSectionHeader, for: indexPath) as! GridSectionHeader
        let section = dataSource[indexPath.section]
        header.titleLabel.stringValue = section.title
        header.subTitleLabel.isHidden = true
        if case Section.episodes(_) = section {
            header.subTitleLabel.isHidden = false
            header.subTitleLabel.stringValue = "无法播放? 尝试切换路线"
        }
        header.titleLabel.font = NSFont.systemFont(ofSize: 14)
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
            play(episode: episode)
            return
        case .source(let sources):
            if sourceIndex == indexPath.item { return }
            let source = sources[indexPath.item]
            sourceIndex = indexPath.item
            collectionView.reloadSections([indexPath.section])
            updateSource(index: source)
        case .video:
            break
        case .recommends(let videos):
            let video = videos[indexPath.item]
            replace(video: video)
        case .seasons(let seasons):
            let index = indexPath.item
            let sid = seasons[index].id
            updateSeason(index: index, sid: sid)
            break
        }
        
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let section = dataSource[indexPath.section]
        switch section {
        case .source:
            return NSSize(width: 70, height: 30)
        case .episodes(let episodes):
            let title = episodes[indexPath.item].title
            let width = title.widthOfString(usingFont: .systemFont(ofSize: 14)) + 20
            return NSSize(width: width, height: 30)
        case .video:
            return NSSize(width: collectionView.bounds.width - 40, height: 200)
        case .recommends:
            return VideoCardView.smallSize
        case .seasons:
            return NSSize(width: 70, height: 30)
        }
    }
    
}
