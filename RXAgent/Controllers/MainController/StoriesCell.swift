//
//  StoriesCell.swift
//  RXAgent
//
//  Created by RX Group on 05.03.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit

class StoriesCell: UICollectionViewCell {
    
    
    @IBOutlet weak var storiesLine: UIView!
    @IBOutlet weak var storieImage: UIImageView!
    @IBOutlet weak var storiesTitle: UILabel!
    
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.gradientStories()
//    }
    
    func gradientStories(){
        storiesLine.layer.cornerRadius = 10
        storiesLine.backgroundColor = .clear
        storiesLine.layer.borderWidth = 2
        storiesLine.layer.borderColor = UIColor.init(displayP3Red: 186/255, green: 53/255, blue: 141/255, alpha: 1).cgColor
     
//        let gradient = CAGradientLayer()
//            gradient.frame =  CGRect(origin: CGPoint.zero, size: self.storiesLine.bounds.size)
//            gradient.colors = [UIColor.init(displayP3Red: 186/255, green: 53/255, blue: 141/255, alpha: 1).cgColor, UIColor.init(displayP3Red: 250/255, green: 240/255, blue: 38/255, alpha: 0.76).cgColor]
//
//            let shape = CAShapeLayer()
//            shape.lineWidth = 2
//            shape.path = UIBezierPath(roundedRect: storiesLine.bounds, cornerRadius: 8).cgPath
//            shape.strokeColor = UIColor.black.cgColor
//            shape.fillColor = UIColor.clear.cgColor
//            gradient.mask = shape
//
//            self.storiesLine.layer.addSublayer(gradient)
    }
    
    func viewedStories(){
        storiesLine.layer.cornerRadius = 10
        storiesLine.backgroundColor = .clear
        storiesLine.layer.borderWidth = 2
        storiesLine.layer.borderColor = UIColor.init(displayP3Red: 78/255, green: 63/255, blue: 96/255, alpha: 1).cgColor
    }
   
    
}


