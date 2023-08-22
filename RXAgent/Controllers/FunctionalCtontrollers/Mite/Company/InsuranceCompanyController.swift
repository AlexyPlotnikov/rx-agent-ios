//
//  InsuranceCompanyController.swift
//  RXAgent
//
//  Created by RX Group on 25.03.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit

class InsuranceCompanyController: UIViewController {

    var dateFrom:String = ""
    var dateTo:String = ""
    var costClient:Int = 0
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        NotificationCenter.default.addObserver(self, selector: #selector(reloadProgram), name: NSNotification.Name(rawValue: "reloadProgram"), object: nil)

//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(reloadProgram),
//                                               name: NSNotification.Name( "reloadProgram"),
//                                               object: nil)
        
        
    }
    
    @objc func reloadProgram(){
        var count = 0
        if(MiteModel.sharedInstance().miteItem.items.count > 0){
            count = MiteModel.sharedInstance().miteItem.items.count
        }
        getRequest(URLString: domain + "v0/MitePolicies/calc?program=2&items=\(count)", completion: {
            result in
            DispatchQueue.main.async {
                if(result["result"] as? [String:Any]) != nil{
                    let dict = result["result"] as! [String:Any]
                    self.costClient = dict["costClient"] as! Int
                    self.dateFrom = dict["dateFrom"] as! String
                    self.dateTo = dict["dateTo"] as! String
                    self.table.reloadData()
                }
            }
        })
    }
    
}

extension InsuranceCompanyController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 88
        }else{
            return 342
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! InsCompanyCell
            cell.costLbl.text = "\(self.costClient) ₽"
            cell.kvLbl.text = String(format: "+ КВ %.0f", Double(self.costClient)/100*25) + " ₽"
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "insCell", for: indexPath) as! InsCompanyCell
            if(self.dateFrom != ""){
                cell.startPoliceField.text = dateFromJSON(self.dateFrom)
                cell.endPoliceField.text = dateFromJSON(self.dateTo)
            }
            return cell
        }
    }
    
    
}
