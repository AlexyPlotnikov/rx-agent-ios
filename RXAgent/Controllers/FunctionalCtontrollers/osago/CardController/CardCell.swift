//
//  CardCell.swift
//  RXAgent
//
//  Created by RX Group on 19/08/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

class CardCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subtitleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var titlePlaceholderLbl: UILabel!
    @IBOutlet weak var titleDays: UILabel!
    
    @IBOutlet weak var fromField: UITextField!
    @IBOutlet weak var toField: UITextField!
    @IBOutlet weak var switcher: UISwitch!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
