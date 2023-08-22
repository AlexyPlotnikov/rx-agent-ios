//
//  MiteDetailCell.swift
//  RXAgent
//
//  Created by RX Group on 30.03.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit

class MiteDetailCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var costLbl: UILabel!
    @IBOutlet weak var bonusLbl: UILabel!
    
    @IBOutlet weak var statusField: YVTextField!
    @IBOutlet weak var insCompanyField: YVTextField!
    @IBOutlet weak var insProgrammField: YVTextField!
    @IBOutlet weak var dateInsField: YVTextField!
    
    @IBOutlet weak var insuranceField: YVTextField!
    
    @IBOutlet weak var insPeopleField: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.cornerRadius = 12
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
