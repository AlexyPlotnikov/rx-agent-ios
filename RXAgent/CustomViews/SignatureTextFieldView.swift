//
//  SignatureTextFieldView.swift
//  RXAgent
//
//  Created by RX Group on 14.07.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import UIKit

class SignatureTextFieldView: UIView {
    var textField:UITextField!
    var moneyImage:UIImageView!
    var needImage:Bool!{
        didSet{
            moneyImage.isHidden = !needImage
        }
    }
    private var subtextLabel:UILabel!
    var placeholder:String!{
        didSet{
            textField.placeholder = placeholder
        }
    }
    var subtitleText:String!{
        didSet{
            subtextLabel.text = subtitleText
        }
    }
    
   
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let line = UIBezierPath()
        line.move(to:CGPoint(x: 0, y: 35))
        line.addLine(to: CGPoint(x: self.frame.size.width, y: 35))
        line.lineWidth = 0.5
        UIColor.init(displayP3Red: 164/255, green: 164/255, blue: 164/255, alpha: 1).setStroke()
        line.stroke()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.backgroundColor = .clear
        
        let dot = UILabel(frame: CGRect(x: self.bounds.size.width - 50, y: 4, width: 30, height: 30))
        dot.textColor = .red
        dot.text = "*"
        dot.font = UIFont.boldSystemFont(ofSize: 16)
        self.addSubview(dot)
        
        moneyImage = UIImageView(frame: CGRect(x: self.bounds.size.width - 70, y: 8, width: 40, height: 17))
        moneyImage.contentMode = .scaleAspectFit
        moneyImage.image = UIImage(named: "moneyIcon")
        moneyImage.isHidden = true
        self.addSubview(moneyImage)
        
        textField = UITextField(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width - 58, height: 35))
        textField.font = UIFont.boldSystemFont(ofSize: 16)
        self.addSubview(textField)
        
        subtextLabel = UILabel(frame: CGRect(x: 0, y: 38, width: self.bounds.size.width, height: 22))
        subtextLabel.textColor = UIColor.init(displayP3Red: 173/255, green: 173/255, blue: 173/255, alpha: 1)
        subtextLabel.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(subtextLabel)
        
        self.setNeedsDisplay()
    }
}
