//
//  NavigationView.swift
//  WKWebViewJSBridgeDemo
//
//  Created by reborn on 2020/12/2.
//

import UIKit

extension NavigationView {
    
    struct Options: OptionSet {
        let rawValue: Int
        static let title = Options(rawValue: 1 << 0)
        static let back = Options(rawValue: 1 << 1)
    }
    
    var lbTitle: UILabel? {
        return self.navigationBar.centerView as? UILabel
    }
    
    var btnBack: UIButton? {
        return self.navigationBar.leftViews.first as? UIButton
    }
    
    var centerView: UIView? {
        get {
            return self.navigationBar.centerView
        }
        set {
            self.navigationBar.centerView = newValue
        }
    }
    
    var leftView: UIView? {
        get {
            return self.navigationBar.leftViews.first
        }
        
        set {
            self.navigationBar.leftViews = newValue == nil ? [] : [newValue!]
        }
    }
    
    var rightView: UIView? {
        get {
            return self.navigationBar.rightViews.first
        }
        set {
            self.navigationBar.rightViews = newValue == nil ? [] : [newValue!]
        }
    }
    
    convenience init(opts: Options) {
        self.init()
        self.backgroundColor = UIColor.white

        if opts.contains(.title) {
            let lb = UILabel()
            lb.textColor = .black
            lb.textAlignment = .center
            self.navigationBar.centerView = lb
        }
        
        if opts.contains(.back) {
            let btn = UIButton()
            btn.setImage(UIImage(named: "btn_nav_back_black"), for: .normal)
            btn.dw.make().width(44).height(44)
            self.navigationBar.leftViews = [btn]
        }
    }
}

class NavigationView: UIView {

    // MARK: - Public
    /// 状态栏
    private(set) var statusBar: StatusBar!
    
    /// 导航栏
    private(set) var navigationBar: NavigationBar!
    
    /// 底部线
    private(set) var bottomLine: UIView!
    
    /// init
    convenience init() {
        self.init(frame: CGRect.zero)
        
        //
        self.bottomLine = self.createSubView()
        self.bottomLine.backgroundColor = .gray

        self.bottomLine.isHidden = true
        self.bottomLine.dw.make().left(0).bottom(0).right(0).height(0.5)
        
        //
        self.navigationBar = self.createSubView()
        self.navigationBar.dw.make().left(0).bottom(0).right(0).height(NavigationBar.kNavigationBarHeight)
        
        //
        self.statusBar = self.createSubView()
        self.statusBar.dw.make().left(0).top(0).right(0).bottom(0, to: self.navigationBar.dw.top)
    }

}

/// StatusBar
class StatusBar: UIView { }

/// NavigationBar
class NavigationBar: UIView {
    // MARK: - Public
    /// 导航栏高度 44pt
    static let kNavigationBarHeight: CGFloat = 44
    
    /// 控件边距
    private static let kNavigationItemMargin: CGFloat = 10
    
    /// 中间控件
    var centerView: UIView? {
        didSet {
            oldValue?.dw.remove().centerX().centerY()
            oldValue?.removeFromSuperview()
            
            if let newValue = self.centerView {
                newValue.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(newValue)
                newValue.dw.make().centerX(0).centerY(0)
            }
            self.setNeedsUpdateConstraints()
        }
    }
    
    /// 左边控件（从左至右排列）
    var leftViews: [UIView] = [] {
        didSet {
            self._stkLeftViews?.dw.remove().left().top().bottom().width()
            self._stkLeftViews?.removeFromSuperview()
            
            if self.leftViews.count > 0 {
                let stk = self._genStackView()
                self.leftViews.forEach({
                    $0.translatesAutoresizingMaskIntoConstraints = false
                    stk.addArrangedSubview($0)
                })
                self.addSubview(stk)
                stk.translatesAutoresizingMaskIntoConstraints = false
                stk.dw.make().left(NavigationBar.kNavigationItemMargin).top(0).bottom(0).width(44, by: .greaterThanOrEqual)
                self._stkLeftViews = stk
            }
            self.setNeedsUpdateConstraints()
        }
    }
    
    /// 右边控件（从左至右排列）
    var rightViews: [UIView] = [] {
        didSet {
            self._stkRightViews?.dw.remove().left().top().bottom().width()
            self._stkRightViews?.removeFromSuperview()
            
            if self.rightViews.count > 0 {
                let stk = self._genStackView()
                self.rightViews.forEach({
                    $0.translatesAutoresizingMaskIntoConstraints = false
                    stk.addArrangedSubview($0)
                })
                self.addSubview(stk)
                stk.translatesAutoresizingMaskIntoConstraints = false
                stk.dw.make().right(-NavigationBar.kNavigationItemMargin).top(0).bottom(0).width(44, by: .greaterThanOrEqual)
                self._stkRightViews = stk
            }
            self.setNeedsUpdateConstraints()
        }
    }
    
    // MARK: - Private
    private weak var _stkLeftViews: UIStackView?
    private weak var _stkRightViews: UIStackView?
    
    private func _genStackView() -> UIStackView {
        let stk = UIStackView()
        stk.alignment = UIStackView.Alignment.center
        stk.spacing = NavigationBar.kNavigationItemMargin
        stk.axis = .horizontal
        stk.distribution = .equalSpacing
        return stk
    }
}
