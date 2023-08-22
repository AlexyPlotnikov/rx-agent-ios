//
//  AdressController.swift
//  RXAgent
//
//  Created by RX Group on 13.07.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import UIKit

class AdressController: UIViewController {
    
    let profileID = String(format: "%04d", Profile.shared.profile?.contractor?.id ?? 0)
    let categoryID = Category.sharedInstance().currentCategoryID!
    let formatedDate = DatePTOModel.sharedInstance().choosenDateFormated
    let time = DatePTOModel.sharedInstance().choosenTime
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var loadLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configAddress()
        self.table.tableFooterView = UIView()
    }
    
    func configAddress(){
        Address.sharedInstance().loadAddress(profileID: profileID, categoryID: categoryID, formatedDate: formatedDate, time: time) { (loaded, addresses) in
            if(loaded){
                self.loadLbl.isHidden = (addresses ?? []).count > 0
                self.loadLbl.text = "Нет доступных адресов"
                self.table.reloadData()
            }
        }
    }

}


extension AdressController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ((Address.sharedInstance().arrayOfAddresses[indexPath.row].address?.height(withConstrainedWidth: tableView.bounds.size.width, font: UIFont.boldSystemFont(ofSize: 16))) ?? 20) + 52
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Address.sharedInstance().arrayOfAddresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AddressCell
        let currentAdress = Address.sharedInstance().arrayOfAddresses[indexPath.row]
        cell.addressLbl.text = currentAdress.address
        cell.organizationNameLbl.text = currentAdress.title ?? ""
        cell.phoneLbl.text = currentAdress.phones ?? ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Address.sharedInstance().currentAddress = Address.sharedInstance().arrayOfAddresses[indexPath.row]
        NotificationCenter.default.post(name: .nextStep, object: nil, userInfo: nil)
    }
    
    
}
