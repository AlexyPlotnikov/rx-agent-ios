//
//  FullInfoCell.swift
//  RXAgent
//
//  Created by RX Group on 04/02/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

class FullInfoCell: UITableViewCell {
    
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var headerLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        infoLbl.font = UIFont(name: "Roboto-Medium", size: 18)
        headerLbl.font = UIFont(name: "Roboto-Regular", size: 14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
