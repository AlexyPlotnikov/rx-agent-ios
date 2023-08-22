//
//  ShildStatus.swift
//  RXAgent
//
//  Created by Алексей on 06.07.2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

class ShildStatus: UIView {
    var status:UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
       
        status = UILabel(frame: CGRect(x: 16, y: self.frame.size.height/2-14, width: self.frame.size.width-16, height: 28))
        status.textAlignment = .left
        status.font = UIFont(name: "Roboto-Bold", size: 12)
        self.addSubview(status)
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.roundCorners(corners: [.bottomRight,.topRight], radius: 10)
    }
    
    func updateUI(colorText: UIColor,colorBackground:UIColor, text:String){
        self.backgroundColor=colorBackground
        status.textColor=colorText
        setNeedsDisplay()
        status.text=text
    }
   
}
extension String {
    var widthSize:CGFloat{
        let constraintRect = CGSize(width: UIScreen.main.bounds.width, height: .greatestFiniteMagnitude)
        let boundingBox = self.trimmingCharacters(in: .whitespacesAndNewlines).boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], context: nil)
        return ceil(boundingBox.width)
    }
}
