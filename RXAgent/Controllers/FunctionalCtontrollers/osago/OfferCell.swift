//
//  OfferCell.swift
//  RXAgent
//
//  Created by RX Group on 28.04.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit

class OfferCell: UICollectionViewCell {
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var costLbl: UILabel!
    @IBOutlet weak var tariffName: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var getOfferBtn: UIButton!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    
    @IBOutlet weak var desc1: UILabel!
    @IBOutlet weak var desc2: UILabel!
    @IBOutlet weak var desc3: UILabel!
    
    @IBOutlet weak var tariffTitle: UILabel!
    
    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var newCostLbl: UILabel!
    
    @IBOutlet weak var discountLbl: UILabel!
    
    private var shadowLayer: CAShapeLayer!
    
    
   
        override func layoutSubviews() {
            super.layoutSubviews()
            
            self.shadowView.layer.cornerRadius = 16
             
            self.shadowView.layer.masksToBounds = false
            self.shadowView.layer.shadowColor = UIColor.init(displayP3Red: 154/255, green: 154/255, blue: 154/255, alpha: 0.15).cgColor
            self.shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
            self.shadowView.layer.shadowRadius = 6
            self.shadowView.layer.shadowOpacity = 1
            
        }
    
    func setupCost(oldCost:Int, color:UIColor, newCost:Int?, discountPercent:Int?){
        
        if(newCost == 0 || newCost == nil){
            costLbl.attributedText = nil
            costLbl.text = "\(oldCost.formattedWithSeparator) ₽"
            costLbl.textColor = color
            
            newCostLbl.isHidden = true
            discountLbl.isHidden = true
        }else{
            let attributedText = NSAttributedString(
                string: "\(oldCost.formattedWithSeparator) ₽",
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            costLbl.attributedText = attributedText
            costLbl.textColor = UIColor.init(displayP3Red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
            newCostLbl.isHidden = false
            newCostLbl.text = "\(newCost!.formattedWithSeparator) ₽"
            newCostLbl.textColor = color
            discountLbl.isHidden = false
            discountLbl.text = "Скидка \(discountPercent!)%"
        }
    }

   
    
}

