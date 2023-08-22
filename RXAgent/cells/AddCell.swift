//
//  AddCell.swift
//  RXAgent
//
//  Created by RX Group on 28/01/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

class AddCell: UITableViewCell {
    
    @IBOutlet weak var iconAdd: UIImageView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var descriptionlbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.shadowView.layer.cornerRadius = 14
         
        self.shadowView.layer.masksToBounds = false
        self.shadowView.layer.shadowColor = UIColor.init(displayP3Red: 154/255, green: 154/255, blue: 154/255, alpha: 0.15).cgColor
        self.shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.shadowView.layer.shadowRadius = 6
        self.shadowView.layer.shadowOpacity = 1
    }
    
    
    
}
