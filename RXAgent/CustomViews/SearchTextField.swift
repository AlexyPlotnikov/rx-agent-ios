//
//  SearchTextField.swift
//  RXAgent
//
//  Created by RX Group on 06.07.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import UIKit

class SearchTextField: UITextField {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.keyboardType = .numberPad
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColorFromRGB(rgbValue: 0x8E8E93, alphaValue: 1),
            NSAttributedString.Key.font : UIFont(name: "Roboto-Regular", size: 15)! // Note the !
        ]
        self.attributedPlaceholder = NSAttributedString(string: "Введите номер заявки", attributes:attributes)
        self.font = UIFont(name: "Roboto-Regular", size: 15)
        self.layer.cornerRadius=10
        self.layer.masksToBounds=true
        self.setLeftPaddingPoints(10)
    }

    
}
