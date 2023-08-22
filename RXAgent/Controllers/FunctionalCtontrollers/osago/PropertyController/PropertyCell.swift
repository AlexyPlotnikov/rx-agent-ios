//
//  PropertyCell.swift
//  RXAgent
//
//  Created by RX Group on 19/08/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit
import AudioToolbox


class PropertyCell: UITableViewCell {

    @IBOutlet weak var commentView: UITextView!
    @IBOutlet weak var textField: YVTextField!
    @IBOutlet weak var arrowImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if(commentView != nil){
            commentView.layer.cornerRadius = 10
            commentView.layer.masksToBounds = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
 
    
}
