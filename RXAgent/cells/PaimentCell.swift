//
//  PaimentCell.swift
//  RXAgent
//
//  Created by RX Group on 16.07.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import UIKit

class PaimentCell: UITableViewCell {

    @IBOutlet weak var textFieldView: SignatureTextFieldView!
    
    @IBOutlet weak var mainPricelbl: UILabel!
    @IBOutlet weak var addPrice: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

  
}
