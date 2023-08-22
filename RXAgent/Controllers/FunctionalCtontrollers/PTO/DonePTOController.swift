//
//  DonePTOController.swift
//  RXAgent
//
//  Created by RX Group on 19.07.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import UIKit

class DonePTOController: UIViewController {
    

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    var maintence:Maintence!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.table.tableFooterView = UIView()
        self.setUPLabels()
    }
    
    fileprivate func setUPLabels(){
        let fullNameArr = maintence.dateTime.components(separatedBy: "T")
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        
        let dateformatter2 = DateFormatter()
        dateformatter2.dateFormat = "dd.MM"
        
        dateLbl.text = dateformatter2.string(from: dateformatter.date(from: fullNameArr[0])!)
        timeLbl.text = fullNameArr[1]
    }
    
    @IBAction func doneAction(_ sender: Any) {
            
            self.dismiss(animated: true, completion: nil)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateTO"), object: nil, userInfo: nil)
    }
    

}


extension DonePTOController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return (Address.sharedInstance().currentAddress.address?.height(withConstrainedWidth: self.table.frame.size.width - 32, font: UIFont.systemFont(ofSize: 18)))! + 32
        }else{
            return 60
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6 + (Address.sharedInstance().needAdditionalParam ? 1:0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row <= 5){
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DonePTOCell
            if(indexPath.row == 0){
                cell.titleLbl.text = Address.sharedInstance().currentAddress.address
                cell.titleLbl.numberOfLines = 0
                cell.subtitleLbl.text = "Пункт ТО"
            } else if(indexPath.row == 1){
                cell.titleLbl.text = maintence.clientName
                cell.subtitleLbl.text = "Имя клиента"
            } else if(indexPath.row == 2){
                cell.titleLbl.text = maintence.clientPhone
                cell.subtitleLbl.text = "Телефон клиента"
            } else if(indexPath.row == 3){
                cell.titleLbl.text = maintence.vehicleMarkModel
                cell.subtitleLbl.text = "Марка и подель машины"
            }else if(indexPath.row == 4){
                cell.titleLbl.text = maintence.vehicleGosnumber
                cell.subtitleLbl.text = "Госномер"
            }else if(indexPath.row == 5){
                cell.titleLbl.text = maintence.comment != "" ? maintence.comment:"-"
                cell.subtitleLbl.text = "Комментарий"
            }
            
            
            return cell
        }else{
            let cellReuseIdentifier = "Cell"
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellReuseIdentifier)
            var imagesArray:[UIImage]=[]
            if(Address.sharedInstance().currentAddress.haveEmergencyStopSign!){
                imagesArray.append(UIImage(named: "miniIconAdditional1")!)
            }
            if(Address.sharedInstance().currentAddress.haveFireExtinguisher!){
                imagesArray.append(UIImage(named: "miniIconAdditional2")!)
            }
            if(Address.sharedInstance().currentAddress.haveFirstAidKit!){
                imagesArray.append(UIImage(named: "miniIconAdditional3")!)
            }
            if(Address.sharedInstance().currentAddress.haveWindscreen!){
                imagesArray.append(UIImage(named: "miniIconAdditional4")!)
            }
            
            for i in 0..<imagesArray.count{
                let imageView = UIImageView(frame: CGRect(x: 16 + i * (41 + 8), y: 4, width: 41, height: 30))
                imageView.image = imagesArray[i]
                cell.addSubview(imageView)
            }
            
            
            return cell
        }
    }
    
    
}
