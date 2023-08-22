//
//  OwnerCalcController.swift
//  RXAgent
//
//  Created by RX Group on 03/09/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

class OwnerCalcController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.tableFooterView = UIView()
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        table.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row==1 && !needCity){
            return 0
        }else{
            return 65
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
            let cellReuseIdentifier = "cell"
            let cell:OwnerCalcCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! OwnerCalcCell
            cell.accessoryType = .disclosureIndicator
            if(indexPath.row==0){
                cell.titleOwner.text = regionCalc
                cell.subtitleOwner.text = "Укажите регион"
            }else{
                cell.titleOwner.text = cityCalc
                cell.subtitleOwner.text = "Укажите населенный пункт"
            }
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row==0){
            isRegion = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "detailVC") as! DetailController
            self.navigationController?.pushViewController(viewController, animated: true)
            
        }
        if(indexPath.row==1){
            isRegion = false
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "detailVC") as! DetailController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
}
