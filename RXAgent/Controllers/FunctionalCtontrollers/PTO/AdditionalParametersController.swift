//
//  AdditionalParametersController.swift
//  RXAgent
//
//  Created by RX Group on 03.08.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import UIKit

class AdditionalParametersController: UIViewController {
    
    struct Additional{
        let name:String
        let iconName:String
    }
    
    let additionals:[Additional] = [
        Additional(name: "Аварийный знак", iconName: "emergency sign"),
        Additional(name: "Огнетушитель", iconName: "fire ext"),
        Additional(name: "Аптечка", iconName: "health kit"),
        Additional(name: "Л1", iconName: "screen")]
    
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @objc func changeAdditionalSwitcher(switcher:UISwitch){
        switch switcher.tag {
        case 0:
            Address.sharedInstance().currentAddress.haveEmergencyStopSign = switcher.isOn
        case 1:
            Address.sharedInstance().currentAddress.haveFireExtinguisher = switcher.isOn
        case 2:
            Address.sharedInstance().currentAddress.haveFirstAidKit = switcher.isOn
        case 3:
            Address.sharedInstance().currentAddress.haveWindscreen = switcher.isOn
        default:
            print()
        }
        print(Address.sharedInstance().currentAddress)
    }

}


extension AdditionalParametersController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return additionals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AdditionalCell
        if(indexPath.row == 0){
            cell.switchAdditional.isEnabled = Address.sharedInstance().currentAddress.haveEmergencyStopSign!
            cell.nameAdditional.isEnabled = Address.sharedInstance().currentAddress.haveEmergencyStopSign!
            Address.sharedInstance().currentAddress.haveEmergencyStopSign = false
        }
        if(indexPath.row == 1){
            cell.switchAdditional.isEnabled = Address.sharedInstance().currentAddress.haveFireExtinguisher!
            cell.nameAdditional.isEnabled = Address.sharedInstance().currentAddress.haveFireExtinguisher!
            Address.sharedInstance().currentAddress.haveFireExtinguisher = false
        }
        if(indexPath.row == 2){
            cell.switchAdditional.isEnabled = Address.sharedInstance().currentAddress.haveFirstAidKit!
            cell.nameAdditional.isEnabled = Address.sharedInstance().currentAddress.haveFirstAidKit!
            Address.sharedInstance().currentAddress.haveFirstAidKit = false
        }
        if(indexPath.row == 3){
            cell.switchAdditional.isEnabled = Address.sharedInstance().currentAddress.haveWindscreen!
            cell.nameAdditional.isEnabled = Address.sharedInstance().currentAddress.haveWindscreen!
            Address.sharedInstance().currentAddress.haveWindscreen = false
        }
        cell.switchAdditional.tag = indexPath.row
        cell.switchAdditional.isOn = false
        cell.switchAdditional.addTarget(self, action: #selector(changeAdditionalSwitcher), for: .valueChanged)
        cell.icon.image = UIImage(named: additionals[indexPath.row].iconName)
        cell.nameAdditional.text = additionals[indexPath.row].name
        
        return cell
    }
    
    
}
