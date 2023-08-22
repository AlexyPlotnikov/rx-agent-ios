//
//  DetailCardCell.swift
//  RXAgent
//
//  Created by RX Group on 15.06.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit

class DetailCardCell: UITableViewCell {

    @IBOutlet weak var textField: YVTextField!
    @IBOutlet weak var eyeBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    @IBAction func secureChange(_ sender: Any) {
        self.textField.isSecureTextEntry = !self.textField.isSecureTextEntry
        self.eyeBtn.setImage(UIImage(named: self.textField.isSecureTextEntry ? "eyeClose":"eyeOpen"), for: .normal)
    }
    

}
