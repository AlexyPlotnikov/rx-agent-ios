//
//  InsuranceCell.swift
//  RXAgent
//
//  Created by Алексей on 30/04/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

class InsuranceCell: UITableViewCell {

    @IBOutlet weak var insuranceImage: UIImageView!
    @IBOutlet weak var summ: UILabel!
    @IBOutlet weak var KVlbl: UILabel!
    @IBOutlet weak var bonusLbl: UILabel!
    @IBOutlet weak var summLbl: UILabel!
    @IBOutlet weak var summView: UIView!
    @IBOutlet weak var kvView: UIView!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var circle1: UIImageView!
    @IBOutlet weak var circle2: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if(actionBtn != nil){
            actionBtn.layer.cornerRadius = 8
        }
        if(circle1 != nil){
            let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotation.toValue = NSNumber(value: Double.pi * 2)
            rotation.duration = 1
            rotation.isCumulative = true
            rotation.repeatCount = Float.greatestFiniteMagnitude
            self.circle1.layer.add(rotation, forKey: "rotationAnimation")
            
            let rotation1 : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotation1.toValue = NSNumber(value: Double.pi * 2)
            rotation1.duration = 1.5
            rotation1.isCumulative = false
            rotation1.repeatCount = Float.greatestFiniteMagnitude
            self.circle2.layer.add(rotation1, forKey: "rotationAnimation")
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
