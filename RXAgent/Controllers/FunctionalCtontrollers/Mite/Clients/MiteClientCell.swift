//
//  MiteClientCell.swift
//  RXAgent
//
//  Created by RX Group on 18.03.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit

class MiteClientCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var readyBackView: UIView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var fullNameField: YVTextField!
    @IBOutlet weak var dobField: YVTextField!
    @IBOutlet weak var addNewClient: UIButton!
    @IBOutlet weak var removeBtnReady: UIButton!
    @IBOutlet weak var removeBtnCreate: UIButton!
    
    
    @IBOutlet weak var clientNameLbl: UILabel!
    @IBOutlet weak var clientDobLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if(self.reuseIdentifier == "cellAdd"){
            backView.layer.cornerRadius = 12
        }
        if(self.reuseIdentifier == "cellReady"){
            readyBackView.layer.cornerRadius = 12
        }
        if(self.reuseIdentifier == "cellAddBtn"){
            addNewClient.backgroundColor = .white
            addNewClient.layer.cornerRadius = 12
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
