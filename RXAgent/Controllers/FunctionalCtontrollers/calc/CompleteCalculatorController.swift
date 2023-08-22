//
//  CompleteCalculatorController.swift
//  RXAgent
//
//  Created by RX Group on 01.06.2020.
//  Copyright © 2020 RX Group. All rights reserved.
//

import UIKit

class CompleteCalculatorController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate {
    
    var dict:[String:Any]!
    
    var namesINS = //["rgs",
    ["vsk","ingos","alphaSuper","vskSuper","zettaSuper","soglasieSuper","resoSuper","renessansSuper"]
    var imagesINS = //["ins-rgs",
    ["ins-vsk","ins-ingos","ins-alpha","ins-vsk","ins-zetta","ins-soglas","ins-reso","ins-renesans"]
    @IBOutlet weak var table: UITableView!
   
    @IBOutlet weak var summFROMLbl: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.tableFooterView = UIView()
    
        let calcDict = dict["eosagoCalculator"] as! [String:Any]
       // summTOLbl.text = String(format: "%.1f ₽",(calcDict["sumFrom"] as! NSNumber).doubleValue)
        summFROMLbl.text = String(format: "%.2f ₽", calcDict["sumTo"] as? Double ?? 0.0)
        for i in 0..<namesINS.count{
            let ins = calcDict[(namesINS[i] )] as! [String:Any]
            let summ = (ins["cost"] as? NSNumber)?.doubleValue ?? 0
            let price = (ins["prise"] as? NSNumber)?.doubleValue ?? 0
            let comment = ins["comment"] as? String ?? ""
            insuranceArray.add(Insurance(img: UIImage(named: imagesINS[i] ), summ: summ, bonus: (summ/100)*price, comment: comment,insuranceID: 0))
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (navigationController?.viewControllers.count ?? 0) > 1
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 2
        }else{
            return 6
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section==0){
            let cellReuseIdentifier = "cell"
            let cell:CompleteCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! CompleteCell
            let currentIns = (insuranceArray[indexPath.row] as! Insurance)
            if(!currentIns.comment.isEmpty){
                cell.comment.isHidden=false
                cell.comment.text = currentIns.comment
            }else{
                cell.comment.isHidden = true
                
                cell.bonus.text = String(format: "%.0f ₽",currentIns.bonus!)
                cell.summ.text = String(format: "%.0f ₽",currentIns.summ!)
            }
            cell.imageINS.image = currentIns.img
            return cell
        }else{
            let cellReuseIdentifier = "cell"
            let cell:CompleteCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! CompleteCell
            let currentIns = (insuranceArray[indexPath.row+2] as! Insurance)
            if(!currentIns.comment.isEmpty){
                cell.comment.isHidden=false
                cell.comment.text = currentIns.comment
            }else{
                cell.comment.isHidden = true
                cell.bonus.text = String(format: "%.0f ₽",currentIns.bonus!)
                cell.summ.text = String(format: "%.0f ₽",currentIns.summ!)
            }
            cell.imageINS.image = currentIns.img
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.table.frame.size.width, height: 32))
        view.backgroundColor = UIColorFromRGB(rgbValue: 0xF6F6F6, alphaValue: 1)
        
        let titleLbl = UILabel(frame:CGRect(x: 14, y:8, width: 176 , height: 16))
        if(section==0){
            titleLbl.text = "БЫСТРО И УДОБНО"
        }else{
            titleLbl.text = "ПОВЫШЕННАЯ КОМИССИЯ"
        }
        titleLbl.textColor = UIColorFromRGB(rgbValue: 0x6E6E6E, alphaValue:0.8)
        titleLbl.font = UIFont(name: "Roboto-Medium", size: 13)
        titleLbl.textAlignment = .left
        titleLbl.numberOfLines = 1
        view.addSubview(titleLbl)
        
        let timeChar:String!
        if(section==0){
            timeChar = "3 мин."
        }else{
            timeChar = "10-15 мин."
        }
        let titleBonus = UILabel(frame:CGRect(x: view.bounds.size.width-(timeChar.widthSize+5)-14, y:8, width: 75 , height: 16))
        titleBonus.text = timeChar
        titleBonus.textColor = UIColorFromRGB(rgbValue: 0x6E6E6E, alphaValue: 0.8)
        titleBonus.font = UIFont(name: "Roboto-Medium", size: 13)
        titleBonus.textAlignment = .left
        view.addSubview(titleBonus)
        
        let imageView=UIImageView(frame: CGRect(x: titleBonus.frame.origin.x-21, y: 8, width: 16, height: 16))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "clock")
        view.addSubview(imageView)
        
        return view
    }
    
    @IBAction func goOSAGO(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        let storyboard = UIStoryboard(name: "OSAGO", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "osagoVC") as! MainOsagoController
        self.navigationController?.pushViewController(viewController, animated: true)
            isEdit = false
                  
    }
    
    @IBAction func close(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
