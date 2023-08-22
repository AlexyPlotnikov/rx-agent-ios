//
//  optionCell.swift
//  RXAgent
//
//  Created by RX Group on 05/08/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

class optionCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var switchOption: UISwitch!
    
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var labelTop: UILabel!
    @IBOutlet weak var labelBottom: UILabel!
    @IBOutlet weak var addPhotoBtn: UIButton!
    @IBOutlet weak var photoBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if(photoView != nil){
            photoView.layer.cornerRadius = 11
            photoView.layer.masksToBounds = true
            photoView.backgroundColor = .clear
        }
    }
   
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
