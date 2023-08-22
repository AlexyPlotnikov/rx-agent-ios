//
//  InsCompanyCell.swift
//  RXAgent
//
//  Created by RX Group on 25.03.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit

class InsCompanyCell: UITableViewCell {

    @IBOutlet weak var resultBackView: UIView!
    @IBOutlet weak var costLbl: UILabel!
    @IBOutlet weak var kvLbl: UILabel!
    
    @IBOutlet weak var startPoliceField: YVTextField!
    @IBOutlet weak var endPoliceField: YVTextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
            resultBackView.layer.cornerRadius = 12
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    //a0019
    //Rx1003
}
