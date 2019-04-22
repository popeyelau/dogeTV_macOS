//
//  PlayerViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/16.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import AVKit
import PromiseKit

class PlayerViewController: NSViewController {
    
    enum Section {
        case episodes([Episode])
        case source([Int])
        case video(Video)
        case recommends([Video])

        var title: String {
            switch self {
            case .episodes:
                return "分集"
            case .source:
                return "线路"
            case .video:
                return "简介"
            case .recommends:
                return "猜你喜欢"
            }
        }
    }

    var videDetail: VideoDetail?
    var episodes: [Episode]?

    var history: History? {
        didSet {
            if let history = history {
                episodeIndex = history.episode
                sourceIndex = history.source
                duration = history.currentTime
            }
        }
    }

    var episodeIndex: Int = 0
    var sourceIndex: Int = 0
    var duration: Double = 0
    var dataSource: [Section] = []

    private var playerItemContext = 0

    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var episodePanel: NSScrollView!
    @IBOutlet weak var episodePanelWidth: NSLayoutConstraint!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var avPlayer: AVPlayerView!
    @IBOutlet weak var toggleBtn: NSButton!
    @IBOutlet weak var indicatorView: NSProgressIndicator!
    var titleText: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        episodePanel.wantsLayer = true
        episodePanel.backgroundColor = NSColor(red:0.12, green:0.12, blue:0.13, alpha:1.00)
        
        titleLabel.stringValue = titleText ?? ""
        updateDataSource()
        playing()
        let trackingArea = NSTrackingArea(rect: view.bounds, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea)
    }
    
    func playing() {
        if let playing = episodes?[safe: episodeIndex] {
            play(episode: playing)
        }
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
            self.prepareToPlay(url: episode.url)
            return
        }

        indicatorView.show()
        _ = APIClient.resolveUrl(url: episode.url)
            .done { (url) in
                self.prepareToPlay(url: url)
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
                self.indicatorView.dismiss()
        }
    }

    func prepareToPlay(url: String) {
        avPlayer.player = AVPlayer(url: URL(string: url)!)
        avPlayer.player?.addObserver(self,
                                     forKeyPath: #keyPath(AVPlayer.status),
                                     options: [.old, .new],
                                     context: &playerItemContext)


        self.avPlayer.player?.play()
    }
    
    func updateSource(index: Int) {
        guard let id = videDetail?.info.id else { return }
        indicatorView.show()
        _ = APIClient.fetchEpisodes(id: id, source: index).done { (episodes) in
            self.episodes = episodes
            }.catch({ (error) in
                print(error)
                self.showError(error)
            }).finally {
                self.updateDataSource()
                self.indicatorView.dismiss()
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
        if let recommends = videDetail?.recommends {
            dataSource.append(.recommends(recommends))
        }
        collectionView.reloadData()
        collectionView.scrollToVisible(.zero)
    }
    
    func replace(id: String) {
        history = nil
        indicatorView?.isHidden = false
        indicatorView?.startAnimation(nil)
        attempt(maximumRetryCount: 3) {
            when(fulfilled: APIClient.fetchVideo(id: id),
                 APIClient.fetchEpisodes(id: id))
            }.done { detail, episodes in
                self.videDetail = detail
                self.episodes = episodes
            }.catch{ error in
                print(error)
                self.showError(error)
            }.finally {
                self.sourceIndex = 0
                self.episodeIndex = 0
                self.indicatorView?.stopAnimation(nil)
                self.indicatorView?.isHidden = true
                self.updateDataSource()
                self.playing()
        }
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {

        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }

        //播放历史 && 时长 > 0 监听播放器状态，当成功加载时，跳转到历史播放时间点
        guard let history = history, history.currentTime > 0, episodeIndex == history.episode else {
            return
        }
        if keyPath == #keyPath(AVPlayer.status){
            let status: AVPlayer.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayer.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }

            switch status {
            case .readyToPlay:
                //开始播放
                let seekTo = CMTimeMakeWithSeconds(history.currentTime, preferredTimescale: 1000000)
                avPlayer.player?.seek(to: seekTo)
            default:
                break
            }
        }
    }

    func addRecord() {
        guard let video = videDetail?.info, let episode = episodes?[safe: episodeIndex] else { return }

        let history = History()
        history.primaryKey = video.id
        history.videoId = video.id
        history.name = video.name
        history.episode = episodeIndex
        history.episodeName = episode.title
        history.source = sourceIndex
        history.currentTime = avPlayer.player?.currentItem?.currentTime().seconds ?? 0
        history.duration = 0
        if let duration = avPlayer.player?.currentItem?.asset.duration {
            history.duration = CMTimeGetSeconds(duration)
        }
        history.cover = video.cover
        Repository.insertOrReplace(table: history)
        NotificationCenter.default.post(name: .init(rawValue: "com.dogetv.history"), object: nil)
    }

    deinit {
        guard avPlayer.player?.status == AVPlayer.Status.readyToPlay else { return }
        addRecord()
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
        case .recommends(let videos):
            return videos.count
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
        case .recommends(let videos):
            let item = collectionView.makeItem(withIdentifier: .init("VideoCardView"), for: indexPath) as! VideoCardView
            let video = videos[indexPath.item]
            item.data = video
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
        case .recommends(let videos):
            let video = videos[indexPath.item]
            avPlayer.player?.pause()
            replace(id: video.id)
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
            return NSSize(width: collectionView.bounds.width - 40, height: 200)
        case .recommends:
            return VideoCardView.smallSize
        }
    }
    
}

