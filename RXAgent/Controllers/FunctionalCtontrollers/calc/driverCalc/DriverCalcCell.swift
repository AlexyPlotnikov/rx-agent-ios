//
//  DriverCalcCell.swift
//  RXAgent
//
//  Created by RX Group on 10/09/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

class DriverCalcCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subtitlelbl: UILabel!
    
    @IBOutlet weak var switcher: UISwitch!
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    @IBOutlet weak var getKBMBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
    
}
