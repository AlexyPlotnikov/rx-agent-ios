//
//  DetailStateCell.swift
//  RXAgent
//
//  Created by RX Group on 29.06.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit

class DetailStateCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var costLbl: UILabel!
    @IBOutlet weak var descriptionCost: UILabel!
    @IBOutlet weak var calculateLbl: UILabel!
    @IBOutlet weak var insuranceImage: UIImageView!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
