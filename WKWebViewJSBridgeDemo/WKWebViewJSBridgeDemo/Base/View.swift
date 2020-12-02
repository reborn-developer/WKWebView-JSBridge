//
//  View.swift
//  WKWebViewJSBridgeDemo
//
//  Created by reborn on 2020/12/2.
//

import UIKit
import Driftwood

class View: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupStyle()
        self.setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupStyle()
        self.setupLayout()
    }
    
    func setupStyle() {}
    func setupLayout() {}
}
