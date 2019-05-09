//
//  ParseViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/28.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import WebKit

class ParseViewController: NSViewController {
    
    enum Site: Int, CaseIterable {
        case youku
        case iqiyi
        case mgtv
        case tencent
        case sohu
        case bilibili

        var title: String {
            switch self {
            case .youku: return "优酷"
            case .iqiyi: return "爱奇艺"
            case .mgtv: return "芒果TV"
            case .tencent: return "腾讯"
            case .sohu: return "搜狐"
            case .bilibili: return "BiliBili"
            }
        }
        
        var url: URL {
            switch self {
            case .youku: return URL(string: "https://home.vip.youku.com/")!
            case .iqiyi: return URL(string: "https://vip.iqiyi.com/")!
            case .mgtv: return URL(string: "https://www.mgtv.com/vip/")!
            case .tencent: return URL(string: "https://film.qq.com/")!
            case .sohu: return URL(string: "https://film.sohu.com/")!
            case .bilibili: return URL(string: "https://www.bilibili.com/movie/")!
            }
        }
        
        static let HandleURLs: [String] = ["https://v.youku.com/v_", "https://www.iqiyi.com/v_", "https://www.mgtv.com/b/", "https://v.qq.com/x/cover/", "https://film.sohu.com/album/", "https://tv.sohu.com/v/",  "https://www.bilibili.com/video/av", "https://www.bilibili.com/bangumi/play/"]
    }
    
    

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var segmentCtrl: CustomSegmentedControl!
    @IBOutlet weak var indicatorView: NSProgressIndicator!
    @IBOutlet weak var backBtn: NSButton!
    @IBOutlet weak var forwardBtn: NSButton!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    var selectedSite: Site = .youku
    private var webViewStateContext = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        Site.allCases.enumerated().forEach { index, element in
            segmentCtrl.addSegment(withTitle: element.title)
        }
        segmentCtrl.selectedIndex = selectedSite.rawValue
        sendRequest(url: selectedSite.url)

        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: &webViewStateContext)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: &webViewStateContext)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: &webViewStateContext)
    }
    
    @IBAction func segmentIndexChanged(_ sender: CustomSegmentedControl) {
        guard let index = sender.selectedIndex, let site = Site(rawValue: index) else { return }
        selectedSite = site
        sendRequest(url: site.url)
    }
    
    func sendRequest(url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    @IBAction func goBackAction(_ sender: NSButton) {
        webView.goBack()
        
    }

    @IBAction func goForwardAction(_ sender: NSButton) {
        webView.goForward()
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {

        guard context == &webViewStateContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }

        backBtn.isEnabled = webView.canGoBack
        forwardBtn.isEnabled = webView.canGoForward
        let progress =  webView.estimatedProgress
        progressBar.doubleValue = progress
        progressBar.isHidden = progress >= 1


    }

    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), context: &webViewStateContext)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), context: &webViewStateContext)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: &webViewStateContext)
    }
}


extension ParseViewController: Initializable {
    func refresh() {
        sendRequest(url: selectedSite.url)
    }
}

extension ParseViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url, url.absoluteString != "about:blank" else {
            decisionHandler(.cancel)
            return
        }
        
        if Site.HandleURLs.contains(where: { url.absoluteString.hasPrefix($0) }) {
            parse(url: url)
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
}

extension ParseViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.load(navigationAction.request)
        return nil
    }
}

extension ParseViewController {
    func parse(url: URL) {
        indicatorView.show()
        _ = APIClient.cloudParse(url: url.absoluteString)
            .done { (result) in
               self.showPlayer(with: result)
            }.catch({ (error) in
                print(error)
            }).finally {
                self.indicatorView.dismiss()
        }
    }
    
    func showPlayer(with result: CloudParse) {
        guard !result.episodes.isEmpty else {
           return
        }
        replacePlayerWindowIfNeeded(video: nil, episodes: result.episodes, title: result.title)
    }
}
