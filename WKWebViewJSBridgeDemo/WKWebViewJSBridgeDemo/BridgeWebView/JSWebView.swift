//
//  JSWebView.swift
//  WKWebViewJSBridgeDemo
//
//  Created by reborn on 2020/12/2.
//  通用webView封装

import UIKit
import WebKit
import PKHUD
import WKWebViewJavascriptBridge

private let _estimatedProgressKey = "estimatedProgress"
private let _webViewTitle = "title"

protocol JSWebViewDelegate: class {
    func webViewWillGoBack(webView: JSWebView)
    
    func webViewWillGoForward(webView: JSWebView)
     
    func webViewWillReload(webView: JSWebView)
    
    func webViewWillStop(webView: JSWebView)
    
    func webView(webView: JSWebView, shouldStartLoad request: URLRequest)
    
    func webViewDidStartLoad(webView: JSWebView)
    
    func webViewDidFinishLoad(webView: JSWebView)
    
    func webView(webView: JSWebView, didFailLoad error: Error)

    func webView(webView: JSWebView, registerHandlerData data: Any, responseCallback: Any)
    
    func webView(webView: JSWebView, h5TitleDidChange title: String)
}

class JSWebView: View {
    
    private(set) weak var progress: UIProgressView!
    
    weak var webView: WKWebView!
    
    weak var delegate: JSWebViewDelegate?
    
    var  bridge: WKWebViewJavascriptBridge?

    var navigation: WKNavigation?
    
    private weak var callH5Btn: UIButton!  //测试用的可以删除
    
    private lazy var webConfiguration: WKWebViewConfiguration = {
          let configuration = WKWebViewConfiguration.init()
          let preferences = WKPreferences.init()
          preferences.javaScriptCanOpenWindowsAutomatically = true
          configuration.preferences = preferences

          let userContentController = WKUserContentController()

         let cookie = "document.cookie = 'fromapp=ios';"
         let cookieScript = WKUserScript(source: cookie, injectionTime: .atDocumentStart, forMainFrameOnly: false)
         userContentController.addUserScript(cookieScript)

         configuration.userContentController = userContentController

        return configuration
      }()

    deinit {
        self.webView.removeObserver(self, forKeyPath: _estimatedProgressKey)
        self.webView.removeObserver(self, forKeyPath: _webViewTitle)
    }
    
    override func setupStyle() {
        
        self.webView = self.createSubView()
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        self.webView.allowsBackForwardNavigationGestures = true
        self.webView.backgroundColor = UIColor.clear
        self.webView.isMultipleTouchEnabled = false
        self.webView.scrollView.backgroundColor = UIColor.clear
        self.webView.scrollView.bounces = false
                
        if #available(iOS 11.0, *) {
            self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        }

        self.progress = self.createSubView()
        self.progress.progressViewStyle = .bar
        self.progress.progressTintColor = .blue
        self.progress.trackTintColor = UIColor.clear
        
        self.bringSubviewToFront(self.progress)
        
        
        self.callH5Btn = self.createSubView()
        self.callH5Btn.backgroundColor = .red
        self.callH5Btn.setTitle("原生调用H5", for: .normal)
        self.callH5Btn.setTitleColor(.black, for: .normal)
        self.callH5Btn.addTarget(self, action: #selector(call(sender:)), for: .touchUpInside)
        
        self.setupWebViewJavascriptBridge()
        self.setupObservers()
    }

    override func setupLayout() {
        self.webView.dw.make().left(0).top(0).right(0).bottom(0)
        self.progress.dw.make().left(0).top(0).right(0).height(2.0)
        
        self.callH5Btn.dw.make().centerX(0).centerY(0)
    }
}

extension JSWebView {
    
    /// load the request
    /// - Parameters:
    ///   - urlString: the url string
    ///   - timeoutInterval: timeout interval
    func loadRequestWithUrl(urlString: String?, timeoutInterval: TimeInterval) {
        
        guard let urlStr = urlString else { return }
        guard let url = URL(string: urlStr) else { return }
        let req = URLRequest(url: url, timeoutInterval: timeoutInterval)
        self.webView.load(req)
    }
    
    /// Call js bridge handler
    /// - Parameters:
    ///   - data: the data native assess H5
    ///   - responseCallback: callback
     func callJSBridgeHandlerWithData(data: Any?, responseCallback: WKWebViewJavascriptBridgeBase.Callback? = nil) {
        self.bridge?.call(handlerName: "H5_REGISTER", data: data) { (response) in
            responseCallback?(response)
        }
    }
    
    /// Navigation action
    func goBack() {
        self.willGoBack()
        if webView.canGoBack {
            self.navigation = webView?.goBack() as! WKNavigation
        }
    }
    
    func goForward() {
        self.willGoForward()
        if webView.canGoForward {
            self.navigation = webView?.goForward() as! WKNavigation
        }
    }
    
    func reload() {
        self.willReload()
        self.navigation = webView?.reload() as! WKNavigation
    }

    func stop() {
        self.willStop()
        webView?.stopLoading()
    }
}

extension JSWebView {
       /// setup webview js bridge.
       func setupWebViewJavascriptBridge() {
        self.bridge = WKWebViewJavascriptBridge(webView: self.webView)
           self.bridge?.isLogEnable = true
           self.registerWebViewJavascriptBridgeHandler()
       }
    
       ///  regist a listener handler for H5 access native
       func registerWebViewJavascriptBridgeHandler() {
        self.bridge?.register(handlerName: "NATIVE_REGISTER") { (paramters, callback) in
            self.delegate?.webView(webView: self, registerHandlerData: paramters, responseCallback: callback)
         }
       }
    
    /// add Observer
    func setupObservers() {
        self.webView.addObserver(self, forKeyPath: _estimatedProgressKey, options: .new, context: nil)
        self.webView.addObserver(self, forKeyPath: _webViewTitle, options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let kp = keyPath else { return }
        if kp == _estimatedProgressKey {
            self.progress.isHidden = false
            self.progress.setProgress(Float(self.webView.estimatedProgress), animated: true)
            
            if(self.webView.estimatedProgress >= 1.0) {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut, animations: {
                    self.progress.isHidden = true
                }) { (finished:Bool) in
                    self.progress.progress = 0
                }
             }
        } else if kp == _webViewTitle {
            self.delegate?.webView(webView: self, h5TitleDidChange: self.webView?.title ?? "")
        }
    }
    
       private func willGoBack() {
        self.delegate?.webViewWillGoBack(webView: self)
       }
       
       private func willGoForward() {
        self.delegate?.webViewWillGoForward(webView: self)
       }
       
       private func willReload() {
        self.delegate?.webViewWillReload(webView: self)
       }
       
       private func willStop() {
        self.delegate?.webViewWillStop(webView: self)
    }
}

extension JSWebView: WKNavigationDelegate {
    
    /// 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.delegate?.webViewDidStartLoad(webView: self)
    }
    
    /// 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.delegate?.webViewDidFinishLoad(webView: self)
    }
    
    /// 当内容开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {}
    
    /// 页面加载失败时调用
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.progress.setProgress(0.0, animated: false)
        self.delegate?.webView(webView: self, didFailLoad: error)
    }
    
    /// 提交发生错误时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.progress.setProgress(0.0, animated: false)
    }
    
    /// 接收到服务器跳转请求即服务重定向时之后调用
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    ///  在发送请求之前，决定是否跳转
    /// - Parameters:
    ///   - webView: 实现该代理的webview
    ///   - navigationAction: 当前navigation
    ///   - decisionHandler: 是否调转block
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let url = navigationAction.request.url
        let url_scheme = url?.scheme
        
        if url_scheme == "tel" {
            if let url = url, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
        }
        
        if let url = url, url.absoluteString.contains("itunes.apple.com") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }

        if ((self.delegate?.webView(webView: self, shouldStartLoad: navigationAction.request) ?? nil) != nil) {
            decisionHandler(.allow)
            return
        } else {
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    /// 根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        //允许跳转
        decisionHandler(.allow)
    }
    
    /// 进程被终止时调用
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {}
}

extension JSWebView: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let frameInfo = navigationAction.targetFrame

        if frameInfo?.isMainFrame != nil {
            webView.load(navigationAction.request)
        }
        return nil
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("确定",  comment: ""), style: .default, handler: { (action) in
            completionHandler()
        }))
        VCManager.manager.getTopVC()?.present(alert, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alert = UIAlertController(title: nil, message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = defaultText
        }

         alert.addAction(UIAlertAction(title: NSLocalizedString("确定",  comment: ""), style: .default, handler: { (action) in
            completionHandler(alert.textFields?[0].text ?? "")
         }))
        VCManager.manager.getTopVC()?.present(alert, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("确定",  comment: ""), style: .default, handler: { (action) in
            completionHandler(true)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("取消",  comment: ""), style: .default, handler: { (action) in
            completionHandler(false)
        }))
        VCManager.manager.getTopVC()?.present(alert, animated: true, completion: nil)
    }
}

//// 测试用
extension JSWebView {
    ////test之后删除
    @objc func call(sender: UIButton) {
            let data = ["greetingFromiOS": "Hi there, I am Swift!"]
            self.callJSBridgeHandlerWithData(data: data, responseCallback: nil)
        }
    /// test之后删除
    func loadDemoPage() {
        enum LoadDemoPageError: Error {
            case nilPath
        }
        
        do {
            guard let pagePath = Bundle.main.path(forResource: "Demo", ofType: "html") else {
                throw LoadDemoPageError.nilPath
            }
            let testUrl = URL.init(fileURLWithPath: pagePath)
            let request = URLRequest(url: testUrl)
            self.webView.load(request)

        } catch LoadDemoPageError.nilPath {
            print(print("webView loadDemoPage error: pagePath is nil"))
        } catch let error {
            print("webView loadDemoPage error: \(error)")
        }
    }
}
