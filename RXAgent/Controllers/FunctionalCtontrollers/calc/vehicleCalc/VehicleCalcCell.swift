//
//  VehicleCalcCell.swift
//  RXAgent
//
//  Created by RX Group on 06/09/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit
import AudioToolbox

class VehicleCalcCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var switcher: UISwitch!
    
    @IBOutlet weak var titleSegment: UILabel!
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameSubtitle: UILabel!
    @IBOutlet weak var buttonChoose: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func setTrailer(_ sender: Any) {
        trailerEmpty = (sender as! UISwitch).isOn
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    @IBAction func chooseTextField(_ sender: Any) {
        AudioServicesPlaySystemSound(1519)
        UIView.animate(withDuration: 0.5, animations: {
            self.buttonChoose.isHidden=true
            self.nameTextField.isHidden=false
            self.nameTextField.becomeFirstResponder()
            self.nameSubtitle.isHidden=false
        })
    }
}
