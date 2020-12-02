//
//  JSBridgeWebViewController.swift
//  WKWebViewJSBridgeDemo
//
//  Created by reborn on 2020/12/2.
//  带交互的h5页面

import UIKit
import WKWebViewJavascriptBridge

class JSBridgeWebViewController: ViewController {
    
    // MARK: - Public
    private(set) var url: String?
    private(set) weak var webView: JSWebView!
    
    var titleName: String?

    override func config() {
        self.hidesBottomBarWhenPushed = true
        
        self.useNavView = true
        self.navViewType = [.title, .back]
    }
    
    override func setupStyle() {
        self.navView?.bottomLine.isHidden = false
        self.navView?.lbTitle?.text = titleName
                       
        self.webView = self.view.createSubView()
        self.webView.delegate = self
    }
    
    override func setupLayout() {
        self.webView.dw.make().left(0).top(0, to: (self.navView?.dw.bottom)!).right(0).bottom(0)
    }
}

extension JSBridgeWebViewController {
    // MARK: Func
    func loadUrl(url: String) {
        self.url = url
    }
    
    func loadRelativeUrl(url: String) {
        self.url = "" + url
    }
    
    private func _loadUrl() {
//        self.webView.loadRequestWithUrl(urlString: self.url, timeoutInterval: 60.0)
        
        //// 测试用，测试通过直接换成上面的
        self.webView.loadDemoPage()
    }
}

extension JSBridgeWebViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self._loadUrl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

extension JSBridgeWebViewController: JSWebViewDelegate {
    
    func webViewWillGoBack(webView: JSWebView) {
        
    }
      
    func webViewWillGoForward(webView: JSWebView) {
        
    }
       
    func webViewWillReload(webView: JSWebView) {
        
    }
      
    func webViewWillStop(webView: JSWebView) {
        
    }
      
    func webView(webView: JSWebView, shouldStartLoad request: URLRequest) {
        
    }
      
    func webViewDidStartLoad(webView: JSWebView) {
        
    }
      
    func webViewDidFinishLoad(webView: JSWebView) {
    }
      
    func webView(webView: JSWebView, didFailLoad error: Error) {
        
    }

    func webView(webView: JSWebView, registerHandlerData data: Any, responseCallback: Any) {
        JSBridgeWebViewHelper.manager.webView(webView: webView, handleH5Data: data, responseCallback: responseCallback as! WKWebViewJavascriptBridgeBase.Callback)
    }
      
    func webView(webView: JSWebView, h5TitleDidChange title: String) {
        self.navView?.lbTitle?.text = title
    }
}
