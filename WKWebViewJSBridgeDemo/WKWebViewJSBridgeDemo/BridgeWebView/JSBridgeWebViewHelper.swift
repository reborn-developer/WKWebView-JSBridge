//
//  JSBridgeWebViewHelper.swift
//  WKWebViewJSBridgeDemo
//
//  Created by reborn on 2020/12/2.
//   处理H5与原生交互helper

import Foundation
import WKWebViewJavascriptBridge

class JSBridgeWebViewHelper {
    
    static let manager = JSBridgeWebViewHelper()

    private(set) weak var webView: JSWebView!
    
    var responseCallback: WKWebViewJavascriptBridgeBase.Callback?
    
    /// handle the h5 data and callback.
    /// - Parameters:
    ///   - webView: webView
    ///   - data: h5 data
    ///   - responseCallback: callback
    func webView(webView: JSWebView, handleH5Data data: Any, responseCallback: WKWebViewJavascriptBridgeBase.Callback? = nil) {
        self.responseCallback = responseCallback
        self.webView = webView
        
        print("H5唤起Swift了")
        
        let info = data as! NSDictionary
                
        print("H5传过来的参数")
        print(info)
        
        let callBack: [String : Any] = [
            "key" : "来自native的回调"
        ]
        
        responseCallback?(callBack)
    }
}
