//
//  DriverCell.swift
//  RXAgent
//
//  Created by RX Group on 15/08/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

class DriverCell: UITableViewCell {

    @IBOutlet weak var titleDriverLbl: UILabel!
    @IBOutlet weak var subtitleDriverLbl: UILabel!
    @IBOutlet weak var addBtnDriver: UIButton!
    @IBOutlet weak var photoViewDriver: UIView!
    @IBOutlet weak var photoImageDriver: UIImageView!
    @IBOutlet weak var photoButtonDriver: UIButton!
    
    @IBOutlet weak var switchMultidrive: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if(photoViewDriver != nil){
            photoViewDriver.layer.cornerRadius = 11
            photoViewDriver.layer.masksToBounds = true
            photoViewDriver.backgroundColor = .clear
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
