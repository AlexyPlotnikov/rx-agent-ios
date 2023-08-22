//
//  MainMiteCell.swift
//  RXAgent
//
//  Created by RX Group on 29.03.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit

class MainMiteCell: UITableViewCell {
    
    @IBOutlet weak var insuranceImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var costLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
