//
//  InsurerCell.swift
//  RXAgent
//
//  Created by RX Group on 23.03.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit

class InsurerCell: UITableViewCell {

    @IBOutlet weak var infoBackView: UIView!
    
    @IBOutlet weak var fioField: YVTextField!
    @IBOutlet weak var phoneNumberField: YVTextField!
    @IBOutlet weak var dobField: YVTextField!
    
    @IBOutlet weak var seriesPassField: YVTextField!
    @IBOutlet weak var registratorField: YVTextField!
    @IBOutlet weak var regDateField: YVTextField!
    
    
    @IBOutlet weak var regionField: YVTextField!
    @IBOutlet weak var cityField: YVTextField!
    @IBOutlet weak var streetField: YVTextField!
    @IBOutlet weak var numberHouseField: YVTextField!
    @IBOutlet weak var housingField: YVTextField!
    @IBOutlet weak var flatField: YVTextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
            infoBackView.layer.cornerRadius = 12
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
