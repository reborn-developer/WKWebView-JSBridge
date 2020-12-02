//
//  ViewController.swift
//  WKWebViewJSBridgeDemo
//
//  Created by reborn on 2020/12/2.
//

import UIKit
import Driftwood

class ViewController: UIViewController {
    // MARK: - Public
    
    // MARK: Property
    
    /// safeArea
    var availableSafeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    /// 使用navView
    var useNavView: Bool = true

    /// navView样式
    var navViewType: NavigationView.Options = [.title, .back]

    /// navView可能为nil
    var navView: NavigationView?
    
    // MARK: Func
    
    /// 在init时被调用，用于配置样式（如：导航条的样式），需要配置时请override
    func config() {}
    
    /// override，在这里添加控件
    func setupStyle() {}

    /// override， 在这里添加约束
    func setupLayout() {}
    
    // MARK: - Action
    
    /// 当点击navigationView的返回按钮时调用，需要配置时请override
    @objc func onBack(sender: UIButton) {
        if let _ = self.navigationController {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
        
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self._preConfig()
        self.config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self._preConfig()
        self.config()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self._preSetupStyle()
        self.setupStyle()
        self._deferSetupStyle()
        
        self._preSetupLayout()
        self.setupLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Private
    
    private func _preConfig() {
        
        // 配置navBar/tabbar
        self.edgesForExtendedLayout = []
        self.automaticallyAdjustsScrollViewInsets = false
        self.hidesBottomBarWhenPushed = false
    }
    
    private func _preSetupStyle() {
        if self.useNavView {
            self.navView = NavigationView(opts: self.navViewType)
            self.navView?.translatesAutoresizingMaskIntoConstraints = false
            self.navView?.btnBack?.addTarget(self, action: #selector(self.onBack(sender:)), for: .touchUpInside)
            self.view.addSubview(self.navView!)
        }
    }
    
    private func _deferSetupStyle() {
        if let navView = self.navView {
            self.view.bringSubviewToFront(navView)
        }
    }
    
    private func _preSetupLayout() {
        self.navView?.dw.make().left(0).top(0).right(0).height(NavigationBar.kNavigationBarHeight + self.availableSafeAreaInsets.top)
    }
}
