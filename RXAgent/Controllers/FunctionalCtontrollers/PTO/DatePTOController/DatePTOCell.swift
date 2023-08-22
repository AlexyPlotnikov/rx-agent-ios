//
//  DatePTOCell.swift
//  RXAgent
//
//  Created by RX Group on 08.07.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import UIKit

class DatePTOCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.contentView.layer.cornerRadius = 10
        self.contentView.backgroundColor = UIColor.init(displayP3Red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
    }
    
    func checkState(){
        if(reuseIdentifier == "timeCell"){
            if(isSelected){
                self.contentView.backgroundColor = UIColor.init(displayP3Red: 163/255, green: 205/255, blue: 58/255, alpha: 1)
                timeLbl.textColor = .white
            }else{
                self.contentView.backgroundColor = UIColor.init(displayP3Red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
                timeLbl.textColor = .black
            }
        }
    }
}
