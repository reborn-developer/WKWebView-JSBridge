//
//  AppDelegate.swift
//  WKWebViewJSBridgeDemo
//
//  Created by reborn on 2020/12/2.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // window
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        self.window?.rootViewController = JSBridgeWebViewController()

        self.window?.makeKeyAndVisible()
        
        return true
    }


}

