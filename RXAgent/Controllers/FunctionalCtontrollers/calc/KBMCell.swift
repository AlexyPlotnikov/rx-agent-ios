//
//  KBMCell.swift
//  RXAgent
//
//  Created by RX Group on 29.05.2020.
//  Copyright © 2020 RX Group. All rights reserved.
//

import UIKit

class KBMCell: UITableViewCell {

    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subtitleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
