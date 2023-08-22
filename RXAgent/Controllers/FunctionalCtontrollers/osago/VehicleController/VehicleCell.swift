//
//  VehicleCell.swift
//  RXAgent
//
//  Created by RX Group on 12/08/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

class VehicleCell: UITableViewCell {

    @IBOutlet weak var titleChooseCell: UILabel!
    @IBOutlet weak var subtitleChooseCell: UILabel!
    
    @IBOutlet weak var titleSwitchCell: UILabel!
    @IBOutlet weak var switcherCell: UISwitch!
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var photoViewCell: UIView!
    @IBOutlet weak var imageViewCell: UIImageView!
    @IBOutlet weak var photoBtnCell: UIButton!
    @IBOutlet weak var titleCell: UILabel!
    @IBOutlet weak var subtitleCell: UILabel!
    @IBOutlet weak var editBtnCell: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if(photoViewCell != nil){
            photoViewCell.layer.cornerRadius = 11
            photoViewCell.layer.masksToBounds = true
            photoViewCell.backgroundColor = .clear
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
