//
//  CompleteCell.swift
//  RXAgent
//
//  Created by RX Group on 01.06.2020.
//  Copyright © 2020 RX Group. All rights reserved.
//

import UIKit

class CompleteCell: UITableViewCell {

    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var summ: UILabel!
    @IBOutlet weak var bonus: UILabel!
    @IBOutlet weak var imageINS: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
