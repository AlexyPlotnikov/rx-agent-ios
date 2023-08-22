//
//  InsuranceControllerViewController.swift
//  RXAgent
//
//  Created by Алексей on 23/04/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit
import AudioToolbox

class InsuranceViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,CustomAlertDelegate  {
    
    var needCard:Bool = false
    var needCreator:Bool = false
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!
  
    var curIndex = 0
    var APIIndex = 0
    var segmentIndex = 0
    var myarr = [Insurance]()
    var APIarr = [Insurance]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       print(needCard, needCreator)
     
            segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        if #available(iOS 13.0, *) {
            segment.selectedSegmentTintColor = UIColorFromRGB(rgbValue: 0x34323B, alphaValue: 1)
        } else {
            segment.tintColor = UIColorFromRGB(rgbValue: 0x34323B, alphaValue: 1)
        }
          
        
        self.table.tableFooterView = UIView()
        
        for i in 0..<insuranceArray.count{
            let newIns = insuranceArray[i] as! Insurance
            if(newIns.isAPI){
                APIarr.append(newIns)
            }else{
                myarr.append(newIns)
            }
        }
        
        
        var tempArrayAPI = APIarr
         let maxApi = tempArrayAPI.filter { $0.bonus != 0 }.max(by: {$0.summ < $1.summ})?.summ
             tempArrayAPI = tempArrayAPI.filter { $0.bonus != 0 }.sorted(by: {$0 .summ < $1.summ})
        APIIndex = tempArrayAPI.filter { $0.bonus != 0 }.firstIndex(where: {$0.summ == maxApi}) ?? 0
                     
        var tempArrayInsurance = myarr
         let maxSumm = tempArrayInsurance.filter { $0.bonus != 0 }.max(by: {$0.summ < $1.summ})?.summ
             tempArrayInsurance = tempArrayInsurance.filter { $0.bonus != 0 }.sorted(by: {$0 .summ < $1.summ})
        curIndex = tempArrayInsurance.filter { $0.bonus != 0 }.firstIndex(where: {$0.summ == maxSumm}) ?? 0
        
        for i in 0..<tempArrayAPI.count{
            if let index = APIarr.firstIndex(where:{$0.name == tempArrayAPI[i].name}) {
                APIarr.remove(at: index)
            }
        }
        
        for i in 0..<tempArrayInsurance.count{
            if let index = myarr.firstIndex(where:{$0.name == tempArrayInsurance[i].name}) {
                myarr.remove(at: index)
            }
        }
        
        tempArrayAPI.append(contentsOf: APIarr)
        tempArrayInsurance.append(contentsOf: myarr)
        APIarr = tempArrayAPI
        myarr = tempArrayInsurance
        table.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeController), name: NSNotification.Name(rawValue: "close"), object: nil)
    }
    
    @objc func closeController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        AudioServicesPlaySystemSound(1519)
        segmentIndex = sender.selectedSegmentIndex
        if(sender.selectedSegmentIndex == 0){
           var tempArrayAPI = APIarr
            let maxApi = tempArrayAPI.filter { $0.bonus != 0 }.max(by: {$0.summ < $1.summ})?.summ
                tempArrayAPI = tempArrayAPI.filter { $0.bonus != 0 }.sorted(by: {$0 .summ < $1.summ})
                APIIndex = tempArrayAPI.filter { $0.bonus != 0 }.firstIndex(where: {$0.summ == maxApi}) ?? 0
                        
           var tempArrayInsurance = myarr
            let maxSumm = tempArrayInsurance.filter { $0.bonus != 0 }.max(by: {$0.summ < $1.summ})?.summ
                tempArrayInsurance = tempArrayInsurance.filter { $0.bonus != 0 }.sorted(by: {$0 .summ < $1.summ})
                curIndex = tempArrayInsurance.filter { $0.bonus != 0 }.firstIndex(where: {$0.summ == maxSumm}) ?? 0
           
           for i in 0..<tempArrayAPI.count{
               if let index = APIarr.firstIndex(where:{$0.name == tempArrayAPI[i].name}) {
                   APIarr.remove(at: index)
               }
           }
           
           for i in 0..<tempArrayInsurance.count{
               if let index = myarr.firstIndex(where:{$0.name == tempArrayInsurance[i].name}) {
                   myarr.remove(at: index)
               }
           }
           
           tempArrayAPI.append(contentsOf: APIarr)
           tempArrayInsurance.append(contentsOf: myarr)
           APIarr = tempArrayAPI
           myarr = tempArrayInsurance
        }else{
           var tempArrayAPI = APIarr
            let maxApi = tempArrayAPI.filter { $0.bonus != 0 }.max(by: {$0.bonus < $1.bonus})?.bonus
                tempArrayAPI = tempArrayAPI.filter { $0.bonus != 0 }.sorted(by: {$0 .bonus < $1.bonus})
                APIIndex = tempArrayAPI.filter { $0.bonus != 0 }.firstIndex(where: {$0.bonus == maxApi}) ?? 0
                        
           var tempArrayInsurance = myarr
            let maxSumm = tempArrayInsurance.filter { $0.bonus != 0 }.max(by: {$0.bonus < $1.bonus})?.bonus
                tempArrayInsurance = tempArrayInsurance.filter { $0.bonus != 0 }.sorted(by: {$0 .bonus < $1.bonus})
                curIndex = tempArrayInsurance.filter { $0.bonus != 0 }.firstIndex(where: {$0.bonus == maxSumm}) ?? 0
           
           for i in 0..<tempArrayAPI.count{
               if let index = APIarr.firstIndex(where:{$0.name == tempArrayAPI[i].name}) {
                   APIarr.remove(at: index)
               }
           }
           
           for i in 0..<tempArrayInsurance.count{
               if let index = myarr.firstIndex(where:{$0.name == tempArrayInsurance[i].name}) {
                   myarr.remove(at: index)
               }
           }
           
           tempArrayAPI.append(contentsOf: APIarr)
           tempArrayInsurance.append(contentsOf: myarr)
           APIarr = tempArrayAPI
           myarr = tempArrayInsurance
        }
        table.reloadData()
    }
    
    func equalDict(lhs: [String: AnyObject], rhs: [String: AnyObject] ) -> Bool {
        return NSDictionary(dictionary: lhs).isEqual(to: rhs)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section==0){
            return APIarr.count
        }else{
            return myarr.count + 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 
            
           let cellReuseIdentifier = "cell"
           let cell:InsuranceCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! InsuranceCell
           
           if(indexPath.section == 0 || (indexPath.section == 1 && indexPath.row != self.myarr.count)){
                DispatchQueue.main.async {
                    cell.summView.isHidden=false
                    cell.kvView.isHidden=false
                        let currentIns = indexPath.section == 0 ? self.APIarr[indexPath.row] : self.myarr[indexPath.row]
                        if(!currentIns.comment.isEmpty){
                            cell.comment.isHidden=false
                       
                            cell.comment.text = currentIns.comment
                        
                        }else{
                            cell.comment.isHidden = true
                            cell.KVlbl.text = String(format: "%.0f ₽",currentIns.bonus!)
                            cell.summ.text = String(format: "%.0f ₽",currentIns.summ!)
                        }
                        let newIndex = indexPath.section == 0 ? self.APIIndex:self.curIndex
                        if(self.segmentIndex==1){
                            if(newIndex==indexPath.row){
                                cell.summView.backgroundColor = UIColorFromRGB(rgbValue: 0xA3CD3A, alphaValue: 0.3)
                                cell.summ.textColor = UIColorFromRGB(rgbValue: 0x8EB725, alphaValue: 1)
                                cell.bonusLbl.textColor = UIColorFromRGB(rgbValue: 0x8EB725, alphaValue: 1)
                            }else{
                                cell.summView.backgroundColor = .clear
                                cell.summ.textColor = .black
                                cell.bonusLbl.textColor = UIColorFromRGB(rgbValue: 0x959595, alphaValue: 1)
                            }
                            if(indexPath.row == 0){
                                cell.kvView.backgroundColor = UIColorFromRGB(rgbValue: 0xFFCA33, alphaValue: 0.3)
                                cell.KVlbl.textColor = UIColorFromRGB(rgbValue: 0xE19012, alphaValue: 1)
                                cell.summLbl.textColor = UIColorFromRGB(rgbValue: 0xE19012, alphaValue: 1)
                            }else{
                                cell.kvView.backgroundColor = .clear
                                cell.KVlbl.textColor = .black
                                cell.summLbl.textColor = UIColorFromRGB(rgbValue: 0x959595, alphaValue: 1)
                            }
                        }else{
                            if(newIndex==indexPath.row){
                                cell.kvView.backgroundColor = UIColorFromRGB(rgbValue: 0xFFCA33, alphaValue: 0.3)
                                cell.KVlbl.textColor = UIColorFromRGB(rgbValue: 0xE19012, alphaValue: 1)
                                cell.summLbl.textColor = UIColorFromRGB(rgbValue: 0xE19012, alphaValue: 1)
                            }else{
                                cell.kvView.backgroundColor = .clear
                                cell.KVlbl.textColor = .black
                                cell.summLbl.textColor = UIColorFromRGB(rgbValue: 0x959595, alphaValue: 1)
                            }
                            if(indexPath.row == 0){
                                cell.summView.backgroundColor = UIColorFromRGB(rgbValue: 0xA3CD3A, alphaValue: 0.3)
                                cell.summ.textColor = UIColorFromRGB(rgbValue: 0x8EB725, alphaValue: 1)
                                cell.bonusLbl.textColor = UIColorFromRGB(rgbValue: 0x8EB725, alphaValue: 1)
                            }else{
                                cell.summView.backgroundColor = .clear
                                cell.summ.textColor = .black
                                cell.bonusLbl.textColor = UIColorFromRGB(rgbValue: 0x959595, alphaValue: 1)
                            }
                        }
                        cell.insuranceImage.image = currentIns.img
                    }
                    return cell
                }else{
               let cellReuseIdentifier = "cell"
               let cell:InsuranceCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! InsuranceCell
               cell.insuranceImage.image = UIImage(named: "ins-rx")
               cell.comment.isHidden = true
               cell.summView.isHidden=true
               cell.kvView.isHidden=true
               return cell
            }
        
    }
       
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            self.request(indexPath: indexPath)
        }else if (indexPath.section == 1){
            var readyToSend = false
            needPTS = (currentFullPolice["vehicleDocID"] as! Int) == 1
            if(needPTS){
                if(!(currentFullPolice["vehiclePassportPageFirstID"] is NSNull) && !(currentFullPolice["vehiclePassportPageSecondID"] is NSNull) && !(currentFullPolice["cardPageFirstID"] is NSNull) && !(currentFullPolice["insurantDocumentPageFirstID"] is NSNull) && !(currentFullPolice["insurantDocumentPageSecondID"] is NSNull)){
                    readyToSend = true
                }
            }else{
                if(!(currentFullPolice["vehicleCertificatePageFirstID"] is NSNull) && !(currentFullPolice["vehicleCertificatePageSecondID"] is NSNull) && !(currentFullPolice["cardPageFirstID"] is NSNull) && !(currentFullPolice["insurantDocumentPageFirstID"] is NSNull) && !(currentFullPolice["insurantDocumentPageSecondID"] is NSNull)){
                    readyToSend = true
                }
            }
            
            
            if(!readyToSend){
                setMessage("Пожалуйста, приложите документы")
            }else{
                self.request(indexPath: indexPath)
            }
        }

    }
    func request(indexPath: IndexPath){
        table.isUserInteractionEnabled = false
        getRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)", completion: {
            result in
                DispatchQueue.main.async{
                      self.table.isUserInteractionEnabled = true
                      let newPolice = result["eosagoPolicy"] as! [String : Any]
                      state = newPolice["state"] as! Int
                      if(state==0){
                        let tempArray = indexPath.section == 0 ? self.APIarr:self.myarr
                          if(indexPath.row != tempArray.count){
                              let newID = tempArray[indexPath.row]
                            if(newID.comment.isEmpty){
                                  //отправка КВ
                                 let customAllert = CustomAlertInsurance(frame: UIScreen.main.bounds)
                                     customAllert.setValuesAlert(insurance: newID.name, bonus: String(format: "%.0f ₽",newID.bonus!), cost: String(format: "%.0f ₽",newID.summ!))
                                  customAllert.delegate=self
                                 let win:UIWindow = UIApplication.shared.delegate!.window!!
                                 win.addSubview(customAllert)

                              }
                          }else{
                            let customAllert = CustomAlertInsurance(frame: UIScreen.main.bounds)
                                customAllert.setValuesAlert(insurance: "rx", bonus: "0", cost:"0" )
                             customAllert.delegate=self
                            let win:UIWindow = UIApplication.shared.delegate!.window!!
                            win.addSubview(customAllert)
                        }
                    }

                }})
    }
    func alertDidClicked(insurance: String) {
        if(insurance == "rx"){
            if(!needCreator && !needCard){
               getPatchRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)/dispatch", completion: {
                 result in
                 DispatchQueue.main.async{
                    print(result)
                    if(result["errors"] == nil){
                     isEdit=false
                     activeItem=1
                     clearAgregator()
                    DispatchQueue.main.async{
                         NotificationCenter.default.post(name: Notification.Name("close"), object: nil)
                         self.dismiss(animated: true, completion: nil)
                     }
                    }else{
                        let errors = (result["errors"] as? NSArray)?[0] as? String ?? result["error"] as! String
                        
                        self.setMessage(errors)
                    }
                 }
             })
            }else{
                let storyboard = UIStoryboard(name: "OSAGO", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "needInfoVC") as! NeedInfoController
                    viewController.needCard = self.needCard
                    viewController.needCreator = self.needCreator
                    self.present(viewController, animated: true, completion: nil)
                creatorPhone = ""
                commentAgent = ""
                creatorInsurance = ""
            }
        }else{
            var IDIns:Insurance!
            if APIarr.contains(where: {$0.name == insurance}) {
              if let foo = APIarr.first(where: {$0.name == insurance}) {
                IDIns = foo
              }
            } else {
               if let foo = myarr.first(where: {$0.name == insurance}) {
                 IDIns = foo
               }
            }
            if(!needCreator){
                getPatchRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)/superDispatch?company=\(IDIns.insuranceID!)", completion: {
                   result in
                   DispatchQueue.main.async{
                       NotificationCenter.default.post(name: Notification.Name("close"), object: nil)
                       self.dismiss(animated: true, completion: nil)
                   }
                })
            }else{
                let storyboard = UIStoryboard(name: "OSAGO", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "needInfoVC") as! NeedInfoController
                    viewController.needCard = false
                    viewController.needCreator = true
                    viewController.insurance = IDIns
                    self.present(viewController, animated: true, completion: nil)
            }
        }
       }
    
    func setNewMessage(_ text:String) {
        let alertController = UIAlertController(title: "Внимание!", message: text, preferredStyle: .alert)
        let alertAction = UIAlertAction( title : "OK" ,
                                         style : .default) { action in
                                            NotificationCenter.default.post(name: Notification.Name("close"), object: nil)
                                            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: false, completion: nil)
        
    }
    
    
    func setMessage(_ text:String) {
        let alertController = UIAlertController(title: "Внимание!", message: text, preferredStyle: .alert)
        let alertAction = UIAlertAction( title : "OK" ,
                                         style : .default) { action in
                                            
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: false, completion: nil)
        
    }
    @IBAction func close(_ sender: Any) {
        self.closeController()
    }
    
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension BinaryInteger {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}
