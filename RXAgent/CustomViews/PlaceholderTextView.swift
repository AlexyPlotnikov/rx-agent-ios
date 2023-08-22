//
//  PlaceholderTextView.swift
//  RXAgent
//
//  Created by RX Group on 11.08.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import UIKit

class PlaceholderTextView: UITextView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.text = "Комментарий"
        self.textColor = UIColor.lightGray
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.init(displayP3Red: 225/255, green: 225/255, blue: 225/255, alpha: 1).cgColor
    }
    
    
}
