//
//  HeaderView.swift
//  RXAgent
//
//  Created by RX Group on 06.07.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import UIKit

class HeaderView: UIView {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let gradient = CAGradientLayer()
    
            gradient.frame = self.bounds
            gradient.colors = [UIColorFromRGB(rgbValue: 0x32294C, alphaValue: 1).cgColor, UIColorFromRGB(rgbValue: 0x3B1D37, alphaValue: 1).cgColor]
    
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
    
            self.layer.insertSublayer(gradient, at: 0)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let gradient = CAGradientLayer()
    
            gradient.frame = self.bounds
            gradient.colors = [UIColorFromRGB(rgbValue: 0x32294C, alphaValue: 1).cgColor, UIColorFromRGB(rgbValue: 0x3B1D37, alphaValue: 1).cgColor]
    
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
    
            self.layer.insertSublayer(gradient, at: 0)
    }

}
