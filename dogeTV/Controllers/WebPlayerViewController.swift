//
//  WebPlayerViewController.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/5/11.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Cocoa
import WebKit
import AVKit

extension NSView {
    var allSubViews : [NSView] {

        var array = [self.subviews].flatMap {$0}

        array.forEach { array.append(contentsOf: $0.allSubViews) }

        return array
    }

}

class WebPlayerViewController: NSViewController {

    @IBOutlet weak var titleView: NSView!

    @IBOutlet weak var titleLabel: NSTextField!
    lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsAirPlayForMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.isHidden = true
        return webView
    }()

    var url: URL?
    var site: ParseViewController.Site?
    var isPlaying = false
    
    var isParsed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.75).cgColor

        titleView.wantsLayer = true
        titleView.layer?.backgroundColor = NSColor(red:0.05, green:0.05, blue:0.05, alpha:1.00).cgColor
        guard let url = url else {
            return
        }
        view.addSubview(webView)
        webView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        showSpinning(message: "解析中, 请耐心等候...")
        sendRequest(url: url)
        //NotificationCenter.default.addObserver(self, selector: #selector(startPlay(_:)), name: .webPlayerStartPlay, object: nil)
    }

    @IBAction func openMainWindow(_ sender: Any) {
        NSApplication.shared.openMainWindow()
    }

    func sendRequest(url: URL, customAgent: Bool = false) {
        print(url.absoluteString)
        let request = URLRequest(url: url)
        webView.customUserAgent = customAgent ? "Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Mobile/15E148 Safari/604.1" : nil
        webView.load(request)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension WebPlayerViewController: WKNavigationDelegate {

    func removeElement() {
        guard let elementId = site?.elementId else { return }
        let removeElementIdScript = """
        var element = document.getElementById('\(elementId)');
        element.parentElement.removeChild(element);

        var vidoes = document.getElementsByTagName('video');
        while (vidoes[0]) {
        videos[0].muted = 'muted';
        videos[0].poster = '';
        vidoes[0].parentNode.removeChild(vidoes[0]);
        }
        """
        webView.evaluateJavaScript(removeElementIdScript) { (response, error) in
            debugPrint("Am here")
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url, url.absoluteString != "about:blank" else {
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.isHidden = false
        removeSpinning()
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard let url = webView.url, url.absoluteString != "about:blank" else {
            return
        }

        guard ParseViewController.Site.HandleURLs.contains(where: { url.absoluteString.hasPrefix($0) }) else {
            return
        }

        if let title = webView.title {
            titleLabel.stringValue = title
        }

        if !isParsed {
            sendRequest(url:URL(string: "https://www.loveyinzi.cc/qipacao/index.php?url=\(url.absoluteString)")!, customAgent: true)
            isParsed = true
            return
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
        

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        if isParsed { return }
        guard let url = webView.url, url.absoluteString != "about:blank" else {
            return
        }
        guard ParseViewController.Site.HandleURLs.contains(where: { url.absoluteString.hasPrefix($0) }) else {
            return
        }

        isParsed = true
        sendRequest(url:URL(string: "https://www.loveyinzi.cc/qipacao/index.php?url=\(url.absoluteString)")!, customAgent: true)
    }
}

extension WebPlayerViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.load(navigationAction.request)
        return nil
    }
}
