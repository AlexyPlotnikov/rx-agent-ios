//
//  FullStateController.swift
//  RXAgent
//
//  Created by RX Group on 30/01/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit
import SafariServices

var state:Int = 0
var isPaid:Bool = false
var isIns:Bool = false
var cost:Int = 0
var currentFullPolice = [String:Any]()

struct Insurance{
      var img:UIImage!
      var summ:Double!
      var bonus:Double!
      var comment:String = ""
      var insuranceID:Int!
      var isAPI:Bool!
      var name:String = ""
  }

var insuranceArray:NSMutableArray = []

class FullStateController: UIViewController, UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var statusView: ShildStatus!
    
  
    var namesINS = //["rgs",
    ["vsk","ingos","alphaSuper","vskSuper","zettaSuper","soglasieSuper","resoSuper","renessansSuper"]
    var imagesINS = //["ins-rgs",
    ["ins-vsk","ins-ingos","ins-alpha","ins-vsk","ins-zetta","ins-soglas","ins-reso","ins-renesans"]
    
    
    @IBOutlet weak var widthStatus: NSLayoutConstraint!
    @IBOutlet weak var numberLbl: UILabel!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var chooseBtn: UIButton!
    @IBOutlet weak var circle1: UIImageView!
    @IBOutlet weak var circle2: UIImageView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var refreshShare: UIButton!
    @IBOutlet weak var insViewConst: NSLayoutConstraint!
    @IBOutlet weak var imageIns: UIImageView!
    @IBOutlet weak var bonusIns: UILabel!
    @IBOutlet weak var summIns: UILabel!
    @IBOutlet weak var insView: UIView!
    
    var paidURL:URL!

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.refresh()
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: NSNotification.Name(rawValue: "close"), object: nil)
        
        numberLbl.text = "№\(mainID)"
        numberLbl.font = UIFont(name: "Roboto-Bold", size: 15)
        if(!(currentFullPolice["cost"] is NSNull) && !(currentFullPolice["finalBonus"] is NSNull) && !(currentFullPolice["super"] is NSNull) && state != 4){
             insViewConst.constant = 86

            if(currentFullPolice["super"] as! String)=="VSK"{
                imageIns.image = UIImage(named: "ins-vsk")
            }
            if(currentFullPolice["super"] as! String)=="RESO"{
                imageIns.image = UIImage(named: "ins-reso")
            }
            if(currentFullPolice["super"] as! String)=="Renessans"{
                imageIns.image = UIImage(named: "ins-renesans")
            }
            if(currentFullPolice["super"] as! String)=="Alpha"{
                imageIns.image = UIImage(named: "ins-alpha")
            }
            if(currentFullPolice["super"] as! String)=="Ingos"{
                imageIns.image = UIImage(named: "ins-ingos")
            }
            bonusIns.text = String("\((currentFullPolice["finalBonus"] as! NSNumber).intValue.formattedWithSeparator) ₽")
            summIns.text = String("\((currentFullPolice["cost"] as! NSNumber).intValue.formattedWithSeparator) ₽")
        }else{
            insViewConst.constant = 0
            insView.isHidden=true
        }
        //cost цена
        //finalBonus бонус
        //super страховая
        fullNameInsurance = check(itemNamed: "insurantFullName")
        if(!check(itemNamed: "insurantPhone").hasPrefix("7")){
            phoneInsurance = "7"+check(itemNamed: "insurantPhone")
        }else{
            phoneInsurance = check(itemNamed: "insurantPhone")
        }
        commentInsurance = check(itemNamed: "agentComment")
        if(!check(itemNamed: "creatorPhone").hasPrefix("7")){
            creatorPhone = "7"+check(itemNamed: "creatorPhone")
        }else{
            creatorPhone = check(itemNamed: "creatorPhone")
        }
        creatorInsurance = check(itemNamed: "creatorFullName")
        periodID = Int(check(itemNamed: "insurancePeriod"))!
        
        getDataMethod(key: "InsurancePeriods",getKey: "insurancePeriods", completion:{
            result in
            periodArray = result
            
            if let period = periodArray.first(where: {($0 as! [String:Any])["id"] as? Int == periodID}) as? [String:Any]{
                periodTitle = period["title"] as! String
            }
        })
        
        dateStartForTable = check(itemNamed: "startDate")
        dateStartForTable = dateStartForTable.components(separatedBy: "T")[0]
       
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "YYYY-MM-dd"
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.init(localeIdentifier: "ru") as Locale
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        print(dateStartForTable, Calendar.current.date(byAdding: .day, value: 4, to: Date())!)
        
        if(dateFormatter2.date(from: dateStartForTable)!<=(Calendar.current.date(byAdding: .day, value: 4, to: Date())!)){
            propertyDateStart = dateFormatter.string(from: self.calculateNewDate())
            dateStartForTable = dateFormatter2.string(from: self.calculateNewDate())
        }else{
            propertyDateStart = dateFormatter.string(from: dateFormatter2.date(from: dateStartForTable)!)
        }
    }
    
    func calculateNewDate() -> Date {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 4, to: today)
        return tomorrow!
    }
    
    func getDataMethod(key: String, getKey : String, completion:@escaping (NSMutableArray)->Void){
        if((UserDefaults.standard.array(forKey: key)) != nil){
            let array = UserDefaults.standard.value(forKey: key) as! NSArray
            completion(array.mutableCopy() as! NSMutableArray)
        }else{
            getRequest(URLString: "\(domain)v0/\(key)", completion:{ result in
                DispatchQueue.main.async{
                    let array = result[getKey] as! NSArray
                    let defaults = UserDefaults.standard
                    defaults.set(array, forKey: key)
                    completion(array.mutableCopy() as! NSMutableArray)
                }
            })
            
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
       
        return (navigationController?.viewControllers.count ?? 0) > 1
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(!isEdit){
            self.dismiss(animated: false, completion: nil)
        }
        
    }
//    self.tabBarController?.tabBar.isHidden = false
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.viewDidDisappear(animated)
     //   self.tabBarController?.tabBar.isHidden = false
    }
    
   
    
    func reloadState(){
        self.configView(state: state, isPaid: isPaid, isInsurance: isIns)
        self.loadingView.isHidden = true
        chooseBtn.isHidden = true
        if(state==254){
            if(isPaid){
                self.buttonNext.isHidden = false
                self.buttonNext.setImage(UIImage(named: "downloadBtn"), for: .normal)
                refreshShare.isHidden=false
                self.refreshShare.setImage(UIImage(named: "share"), for: .normal)
            }else{
                buttonNext.isHidden = false
                buttonNext.setImage(UIImage(named: "payBtn"), for: .normal)
            }
        }
        
        if(state==7){
            self.loadingView.isHidden = true
            self.chooseBtn.isHidden = true
            self.buttonNext.isHidden = false
            self.buttonNext.setImage(UIImage(named: "sendMessage"), for: .normal)
        }
        
        if(state==6){
           
            if(!(currentFullPolice["super"] is NSNull)){
            
            
            getRequest(URLString: "\(domain)v0/InsurantCompanyItems/\(mainID)/superItem", completion:{
                result in
                 DispatchQueue.main.async {
                    if(!(result["item"] is NSNull)){
                        let item = result["item"] as! [String:Any]
                         self.loadingView.isHidden = true
                        if((item["companyState"] as! Int)==3){
                            self.chooseBtn.isHidden = false
                            self.chooseBtn.setImage(UIImage(named: "getPolice"), for: .normal)
                            self.buttonNext.isHidden = false
                            self.buttonNext.setImage(UIImage(named: "payBlack"), for: .normal)
                        }else{
                            self.chooseBtn.isHidden = true
                        }
                        if((item["companyState"] as! Int)==1){
                            
                            self.buttonNext.isHidden = false
                            self.buttonNext.setImage(UIImage(named: "payBlack"), for: .normal)
                            self.chooseBtn.isHidden = false
                            self.chooseBtn.setImage(UIImage(named: "getPolice"), for: .normal)
                        }
                        if((item["companyState"] as! Int)==2){
                            self.buttonNext.isHidden = false
                            self.buttonNext.setImage(UIImage(named: "payBlack"), for: .normal)
                        }
                        if((item["companyState"] as! Int)==4){
                            self.chooseBtn.isHidden = true
                            self.loadingView.isHidden = false
                            let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
                            rotation.toValue = NSNumber(value: Double.pi * 2)
                            rotation.duration = 1
                            rotation.isCumulative = true
                            rotation.repeatCount = Float.greatestFiniteMagnitude
                            self.circle1.layer.add(rotation, forKey: "rotationAnimation")
                            
                            let rotation1 : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
                            rotation1.toValue = NSNumber(value: Double.pi * 2)
                            rotation1.duration = 1.5
                            rotation1.isCumulative = false
                            rotation1.repeatCount = Float.greatestFiniteMagnitude
                            self.circle2.layer.add(rotation1, forKey: "rotationAnimation")
                        }
                    }
                }
            })
            }else{
                self.buttonNext.isHidden = true
            }
        }
        
        if(state==3){
            chooseBtn.isHidden = false
            if(!(currentFullPolice["super"] is NSNull)){
                chooseBtn.setImage(UIImage(named: "payBtn"), for: .normal)
            }else{
                chooseBtn.setImage(UIImage(named: "acceptBtn"), for: .normal)
            }
            
            buttonNext.isHidden = false
            buttonNext.setImage(UIImage(named: "deaccepBtn"), for: .normal)
        }
        
        if(state==0){
            insuranceArray = []
            postReq(URLString: "\(domain)v0/EOSAGOPolicies/calculator/\(mainID)", completion: {
                result in
                if(result["error"] == nil && result["errors"] == nil){
                    let calc = result["eosagoCalculator"] as! [String: Any]
                    for i in 0..<self.namesINS.count{
                        let name = self.namesINS[i]
                        let ins = calc[(self.namesINS[i] )] as! [String:Any]
                        let summ = (ins["cost"] as? NSNumber)?.doubleValue ?? 0
                        let price = (ins["prise"] as? NSNumber)?.doubleValue ?? 0
                        let comment = ins["comment"] as? String ?? ""
                        let insID = (ins["insuranceCompanyID"] as? NSNumber)?.intValue ?? 0
                        let isAPI = i < 3 ? true:false
                      
                        insuranceArray.add(Insurance(img: UIImage(named: self.imagesINS[i] ), summ: comment.isEmpty ? summ:100000, bonus: comment.isEmpty ? (summ/100)*price:0 , comment: comment, insuranceID: insID, isAPI: isAPI,name:name))
                    }
                    DispatchQueue.main.async {
                    
                        self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
                    }
                    }else{
//                        DispatchQueue.main.async {
//                            let errors = (result["errors"] as? NSArray)?[0] as? String ?? result["error"] as! String
//
//                            self.setMessage(errors)
//                        }
                    }
                    
                
            })
        }
    }
    
    @objc func onDidReceiveData(_ notification:Notification) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func close(_ sender: Any) {
       self.navigationController?.popViewController(animated: true)
    }
    
  
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
   
   
    
    func loadPhotos(){
        isOwner = currentFullPolice["insurantIsOwner"] as! Bool
        if(isOwner){
            countOptions=2
        }else{
            countOptions=0
        }
        countRowVehicle = 3
        hasDKPInsurance = currentFullPolice["hasSaleContract"] as! Bool
        hasRegInsurance = currentFullPolice["ownerHasTemporaryRegistration"] as! Bool
        needPTS = (currentFullPolice["vehicleDocID"] as! Int) == 1
       
        passport1Ins = check(itemNamed: "insurantDocumentPageFirstID")
        if(!check(itemNamed: "insurantDocumentPageFirstID").isEmpty){
            
                DispatchQueue.main.async {
                    imagesInsurance.replaceObject(at: 0, with: self.load(url: "\(domain)v0/Attachments/data/\(self.check(itemNamed: "insurantDocumentPageFirstID"))/min") ?? "")
                }
            
        }
        passport2Ins = check(itemNamed: "insurantDocumentPageSecondID")
        if(!check(itemNamed: "insurantDocumentPageSecondID").isEmpty){
          
                DispatchQueue.main.async {
                imagesInsurance.replaceObject(at: 1, with: self.load(url: "\(domain)v0/Attachments/data/\(self.check(itemNamed: "insurantDocumentPageSecondID"))/min") ?? "")
                }
            
        }
        DKPIns = check(itemNamed: "saleContractPageID")
        if(!check(itemNamed: "saleContractPageID").isEmpty){
           
                DispatchQueue.main.async {
                    imagesInsurance.replaceObject(at: 2, with: self.load(url: "\(domain)v0/Attachments/data/\(self.check(itemNamed: "saleContractPageID"))/min") ?? "")
                    imagesOwner.replaceObject(at: 2, with: self.load(url: "\(domain)v0/Attachments/data/\(self.check(itemNamed: "saleContractPageID"))/min") ?? "")
                    }
           
        }
        regIns = check(itemNamed: "ownerTemporaryRegistrationPageID")
        if(!check(itemNamed: "ownerTemporaryRegistrationPageID").isEmpty){
           
                DispatchQueue.main.async {
                    imagesInsurance.replaceObject(at: 3, with: self.load(url: "\(domain)v0/Attachments/data/\(self.check(itemNamed: "ownerTemporaryRegistrationPageID"))/min") ?? "")
                    imagesOwner.replaceObject(at: 3, with: self.load(url: "\(domain)v0/Attachments/data/\(self.check(itemNamed: "ownerTemporaryRegistrationPageID"))/min") ?? "")
                    }
                
        }

        passport1Owner = check(itemNamed: "ownerDocumentPageFirstID")
        if(!check(itemNamed: "ownerDocumentPageFirstID").isEmpty){
           
                DispatchQueue.main.async {
                imagesOwner.replaceObject(at: 0, with: self.load(url: "\(domain)v0/Attachments/data/\(self.check(itemNamed: "ownerDocumentPageFirstID"))/min") ?? "")
                }
            
        }
        passport2Owner = check(itemNamed: "ownerDocumentPageSecondID")
        if(!check(itemNamed: "ownerDocumentPageSecondID").isEmpty){
           
                  DispatchQueue.main.async {
                imagesOwner.replaceObject(at: 1, with: self.load(url: "\(domain)v0/Attachments/data/\(self.check(itemNamed: "ownerDocumentPageSecondID"))/min") ?? "")
                }
               }
        PTSidFront = check(itemNamed: "vehiclePassportPageFirstID")
        if(!check(itemNamed: "vehiclePassportPageFirstID").isEmpty){
            
                DispatchQueue.main.async {
                imagesPTS.replaceObject(at: 0, with: self.load(url: "\(domain)v0/Attachments/data/\(self.check(itemNamed: "vehiclePassportPageFirstID"))/min") ?? "")
                }
           
            
        }
        PTSidBack = check(itemNamed: "vehiclePassportPageSecondID")
        if(!check(itemNamed: "vehiclePassportPageSecondID").isEmpty){
            
                DispatchQueue.main.async {
                imagesPTS.replaceObject(at: 1, with: self.load(url: "\(domain)v0/Attachments/data/\(self.check(itemNamed: "vehiclePassportPageSecondID"))/min") ?? "")
                }
            
        }
        SRTSidFront = check(itemNamed: "vehicleCertificatePageFirstID")
        if(!check(itemNamed: "vehicleCertificatePageFirstID").isEmpty){
           
                  DispatchQueue.main.async {
                imagesSRTS.replaceObject(at: 0, with: self.load(url: "\(domain)v0/Attachments/data/\(self.check(itemNamed: "vehicleCertificatePageFirstID"))/min") ?? "")
                }
            
            }
        SRTSidBack = check(itemNamed: "vehicleCertificatePageSecondID")
        if(!check(itemNamed: "vehicleCertificatePageSecondID").isEmpty){
           
                  DispatchQueue.main.async {
                imagesSRTS.replaceObject(at: 1, with: self.load(url: "\(domain)v0/Attachments/data/\(self.check(itemNamed: "vehicleCertificatePageSecondID"))/min") ?? "")
                }
           
        }
        
        
        
        
        isMultiDrive = currentFullPolice["unlimitedDrivers"] as! Bool
        
        if(!isMultiDrive){
            let driversArray = currentFullPolice["drivers"] as! Array<Any>
            countDriver = driversArray.count
            for i in 0..<countDriver{
              
                if(i==0){
                    idDriverArray[i] = self.checkDriver(key: "id", index: i)
                    policyDriverArray[i] = self.checkDriver(key: "policy", index: i)
                    vu1Driver1 = self.checkDriver(key: "driverLicensePageFirstID", index: i)
                    vu2Driver1 = self.checkDriver(key: "driverLicensePageSecondID", index: i)
                    if(!self.checkDriver(key: "driverLicensePageFirstID", index: i).isEmpty){
                              DispatchQueue.main.async {
                                imagesDriver.replaceObject(at: 0, with: self.load(url: "\(domain)v0/Attachments/data/\(self.checkDriver(key: "driverLicensePageFirstID", index: i))/min") ?? "")
                            }
                        
                    }
                    if(!self.checkDriver(key: "driverLicensePageSecondID", index: i).isEmpty){
                       
                              DispatchQueue.main.async {
                                imagesDriver.replaceObject(at: 1, with: self.load(url: "\(domain)v0/Attachments/data/\(self.checkDriver(key: "driverLicensePageSecondID", index: i))/min") ?? "")
                            }
                       
                    }
                }
                if(i==1){
                    idDriverArray[i] = self.checkDriver(key: "id", index: i)
                    policyDriverArray[i] = self.checkDriver(key: "policy", index: i)

                    vu1Driver2 = self.checkDriver(key: "driverLicensePageFirstID", index: i)
                    vu2Driver2 = self.checkDriver(key: "driverLicensePageSecondID", index: i)
                    if(!self.checkDriver(key: "driverLicensePageFirstID", index: i).isEmpty){
                       
                              DispatchQueue.main.async {
                                imagesDriver.replaceObject(at: 2, with: self.load(url: "\(domain)v0/Attachments/data/\(self.checkDriver(key: "driverLicensePageFirstID", index: i))/min") ?? "")
                            }
                       
                    }
                    if(!self.checkDriver(key: "driverLicensePageSecondID", index: i).isEmpty){
                       
                              DispatchQueue.main.async {
                                imagesDriver.replaceObject(at: 3, with: self.load(url: "\(domain)v0/Attachments/data/\(self.checkDriver(key: "driverLicensePageSecondID", index: i))/min") ?? "")
                            }
                        
                    }
                }
                if(i==2){
                    idDriverArray[i] = self.checkDriver(key: "id", index: i)
                    policyDriverArray[i] = self.checkDriver(key: "policy", index: i)

                    vu1Driver3 = self.checkDriver(key: "driverLicensePageFirstID", index: i)
                    vu2Driver3 = self.checkDriver(key: "driverLicensePageSecondID", index: i)
                    if(!self.checkDriver(key: "driverLicensePageFirstID", index: i).isEmpty){
                       
                              DispatchQueue.main.async {
                                imagesDriver.replaceObject(at: 4, with: self.load(url: "\(domain)v0/Attachments/data/\(self.checkDriver(key: "driverLicensePageFirstID", index: i))/min") ?? "")
                            }
                        
                    }
                    if(!self.checkDriver(key: "driverLicensePageSecondID", index: i).isEmpty){
                        
                              DispatchQueue.main.async {
                                imagesDriver.replaceObject(at: 5, with: self.load(url: "\(domain)v0/Attachments/data/\(self.checkDriver(key: "driverLicensePageSecondID", index: i))/min") ?? "")
                            }
                        
                    }
                }
                if(i==3){
                    idDriverArray[i] = self.checkDriver(key: "id", index: i)
                    policyDriverArray[i] = self.checkDriver(key: "policy", index: i)

                    vu1Driver4 = self.checkDriver(key: "driverLicensePageFirstID", index: i)
                    vu2Driver4 = self.checkDriver(key: "driverLicensePageSecondID", index: i)
                    if(!self.checkDriver(key: "driverLicensePageFirstID", index: i).isEmpty){
                        
                              DispatchQueue.main.async {
                                imagesDriver.replaceObject(at: 6, with: self.load(url: "\(domain)v0/Attachments/data/\(self.checkDriver(key: "driverLicensePageFirstID", index: i))/min") ?? "")
                            }
                        
                    }
                    if(!self.checkDriver(key: "driverLicensePageSecondID", index: i).isEmpty){
                        
                              DispatchQueue.main.async {
                                imagesDriver.replaceObject(at: 7, with: self.load(url: "\(domain)v0/Attachments/data/\(self.checkDriver(key: "driverLicensePageSecondID", index: i))/min") ?? "")
                            }
                        
                    }
                }
                
            }
        }
     
    }

    func checkDriver(key: String, index:Int) -> String {
        let driversArray = currentFullPolice["drivers"] as! Array<Any>
        let driver = driversArray[index] as! [String:Any]
        if(driver[key] is NSNull){
            return ""
        }
        if(driver[key] is Int){
            return String(driver[key] as! Int)
        }
        return driver[key] as! String
    }
    func setMessage(_ text:String) {
    
            let alertController = UIAlertController(title: "Внимание!", message: text, preferredStyle: .alert)
            let alertAction = UIAlertAction( title : "OK" ,
                                             style : .default) { action in
                                               
            }
            
            alertController.addAction(alertAction)
            self.present(alertController, animated: false, completion: nil)
            
    }
    
    func check(itemNamed name: String) ->String {
        if(currentFullPolice[name] is NSNull){
            return ""
        }
        if(currentFullPolice[name] is Int){
            return String(currentFullPolice[name] as! Int)
        }
        return currentFullPolice[name] as! String
    }
    
    func load(url: String) -> UIImage?{
        let data = try? Data(contentsOf: NSURL(string: url)! as URL)
           if(data != nil){
               var image = UIImage(data: data!)
               if(image==nil){
                   image = drawPDFfromURL(url: NSURL(string: url)! as URL)
               }
               return image!
           }else{
               return nil
           }

    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func drawPDFfromURL(url: URL) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        guard let page = document.page(at: 1) else { return nil }
        
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            
            ctx.cgContext.drawPDFPage(page)
        }
        
        return img
    }
   //верхняя
    @IBAction func showInsurance(_ sender: Any) {
        if(state==0){
            
             let viewController = self.storyboard?.instantiateViewController(withIdentifier: "insuranceVC") as! InsuranceViewController
            viewController.needCard = currentFullPolice["payCardNumber"] is NSNull
            viewController.needCreator = currentFullPolice["creatorPhone"] is NSNull
            
             self.present(viewController, animated: true, completion: nil)
            
        }
        if(state==3){
             if(!(currentFullPolice["super"] is NSNull)){
                getPatchRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)/state/5", completion: {
                    result in
                    getRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)", completion: {
                        result in
                        DispatchQueue.main.async{
                            currentFullPolice = result["eosagoPolicy"] as! [String : Any]
                            state = currentFullPolice["state"] as! Int
                            isPaid = currentFullPolice["paid"] as! Bool
                            if(!(currentFullPolice["insuranceCompany"] is NSNull)){
                                insuranceID = String(currentFullPolice["insuranceCompany"] as! Int)
                            }else{
                                insuranceID = ""
                            }
                            self.reloadState()
                            getRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)/OpenURL?company=\(insuranceID)&isSuper=true", completion: {
                                result in
                                DispatchQueue.main.async {
                                    if (result["error"] as? String) != nil {
                                        self.setMessage("Произошла ошибка на сервере")
                                    }else{
                                        let resultPolice = result["result"] as! [String:Any]
                                        if(!(resultPolice["companyURL"] is NSNull)){
                                            self.paidURL = URL(string: resultPolice["companyURL"] as! String)
                                            let svc = SFSafariViewController(url: self.paidURL)
                                            self.present(svc, animated: true, completion: nil)
                                        }
                                    }
                                }
                            })
                            
                        }
                    })
                    
                    
                    })
             }else{
                getPatchRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)/state/5", completion: {
                    result in
                    DispatchQueue.main.async{
                        self.refresh(completion:nil)
                        
                    }
                })
            }
        }
        
        if(state==6){
            getRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)/setSuperPay?company=\(insuranceID)", completion:{ result in
                if (result["errors"] as? NSNull) != nil {
                    DispatchQueue.main.async {
                        self.setMessage((result["errors"] as! NSArray)[0] as! String)
                    }
                }else{
                    self.refresh()
                }
               
                
            })
        }
    }
    
    //нижняя
    @IBAction func editing(_ sender: Any) {
        if(state == 7){
            let alert = UIAlertController(title: "Внимание", message: "Введите СМС-код", preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                textField.placeholder = "СМС-код"
            }
           
            alert.addAction(UIAlertAction(title: "Отправить", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
                if(textField!.text!.count>0){
                    getPatchRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)/sms?code=\(textField!.text ?? "")", completion: {_ in
                        self.refresh()
                    })
                }
            }))
           
            self.present(alert, animated: true, completion: nil)
        }
        if(state==0){
            
                self.loadPhotos()
                isEdit = true
                activeItem = 1
                let storyboard = UIStoryboard(name: "OSAGO", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "osagoVC") as! MainOsagoController
                self.present(viewController, animated: true, completion: nil)
            
        }
        if(state==3){
            getPatchRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)/state/4", completion: {
                result in
                self.refresh()
            })
        }
        if(state==6){
            getRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)/OpenURL?company=\(insuranceID)&isSuper=true", completion: {
                result in
                if (result["error"] as? String) != nil {
                    self.setMessage("Произошла ошибка на сервере")
                }else{
                DispatchQueue.main.async {
                    if(!(result["result"] is NSNull)){
                        let resultPolice = result["result"] as! [String:Any]
                        if(!(resultPolice["companyURL"] is NSNull)){
                            self.paidURL = URL(string: resultPolice["companyURL"] as! String)
                            let svc = SFSafariViewController(url: self.paidURL)
                            self.present(svc, animated: true, completion: nil)
                        }
                    }
                }
                    
                }
            })
            
        }
        if(state==254){
            if(isPaid){
                let image = self.load(url: "\(domain)v0/attachments/data/\(String(currentFullPolice["pageID"] as! Int))")
                let appImage = ViewerImage.appImage(forImage: image!)
                let viewer = AppImageViewer(originImage: image!, photos: [appImage], animatedFromView: buttonNext)
               
                present(viewer, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "Внимание", message: "Вы действительно хотите оплатить?", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Нет", style: .destructive, handler: nil))
                alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
                    
                   
                    postReq(URLString: "\(domain)v0/balanceOperations/debit/8/\(mainID)", completion: {_ in
                        
                        self.refresh()
                    })
                }))
                 self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        if(state==254 && isPaid){
            let image = self.load(url: "\(domain)v0/attachments/data/\(String(currentFullPolice["pageID"] as! Int))")
            
            let imageToShare = [image!]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [ .airDrop, .postToFacebook ]
            
            self.present(activityViewController, animated: true, completion: nil)
        }else{
            let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotation.toValue = NSNumber(value: Double.pi * 2)
            rotation.duration = 1
            rotation.isCumulative = true
            rotation.repeatCount = 1
            self.refreshShare.layer.add(rotation, forKey: "rotationAnimation")
            self.refresh(completion:nil)
        }
    }
    
    func refresh(completion: (() -> Void)? = nil){
        
        getRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)", completion: {
            result in
            DispatchQueue.main.async{
                currentFullPolice = result["eosagoPolicy"] as! [String : Any]
                state = currentFullPolice["state"] as! Int
                isPaid = currentFullPolice["paid"] as! Bool
                if(!(currentFullPolice["insuranceCompany"] is NSNull)){
                    insuranceID = String(currentFullPolice["insuranceCompany"] as! Int)
                }else{
                    insuranceID = ""
                }
                
                self.reloadState()
                
            }
        })
    }
    
    func configView(state: Int, isPaid: Bool, isInsurance:Bool)  {
        var status:String!
        var colorText:UIColor!
        var backgroundColor:UIColor!
        
         colorText = UIColorFromRGB(rgbValue: 0x3289EA, alphaValue: 1)
         backgroundColor = UIColorFromRGB(rgbValue: 0x3289EA, alphaValue: 0.2)
         status = "В ОБРАБОТКЕ";
         buttonNext.isHidden=true
        
        if(state == 0){
            if(isInsurance){
                colorText = UIColorFromRGB(rgbValue: 0x00DF6E, alphaValue: 1)
                backgroundColor = UIColorFromRGB(rgbValue: 0x00DF6E, alphaValue: 0.2)
                status = "ОТПРАВЬТЕ В ОБРАБОТКУ"
            }else{
                colorText = UIColorFromRGB(rgbValue: 0xF7C060, alphaValue: 1)
                backgroundColor = UIColorFromRGB(rgbValue: 0xF7C060, alphaValue: 0.2)
                status = "НОВАЯ ЗАЯВКА"
               
            }
           buttonNext.isHidden=false
        }
        if(state == 6){
            buttonNext.isHidden=false
        }
        if(state == 7){
            colorText = UIColorFromRGB(rgbValue: 0x9984FC, alphaValue: 1)
            backgroundColor = UIColorFromRGB(rgbValue: 0x9984FC, alphaValue: 0.2)
            status = "УКАЖИТЕ СМС-КОД"
             buttonNext.isHidden=false
        }
        
        if(state == 1){
            colorText = UIColorFromRGB(rgbValue: 0x4ACAE8, alphaValue: 1)
            backgroundColor = UIColorFromRGB(rgbValue: 0x4ACAE8, alphaValue: 0.2)
            status = "ЗАЯВКА ОТПРАВЛЕНА"
            buttonNext.isHidden=true
        }
        
        if(state == 3){
            colorText = UIColorFromRGB(rgbValue: 0xCDCE20, alphaValue: 1)
            backgroundColor = UIColorFromRGB(rgbValue: 0xCDCE20, alphaValue: 0.2)
            status = "ПРИМИТЕ УСЛОВИЯ"
            buttonNext.isHidden=false
        }
        
        if(state == 4){
            colorText = UIColorFromRGB(rgbValue: 0xE47171, alphaValue: 1)
            backgroundColor = UIColorFromRGB(rgbValue: 0xE47171, alphaValue: 0.2)
            status = "ЗАЯВКА ОТМЕНЕНА"
            buttonNext.isHidden=true
            chooseBtn.isHidden=true
        }
        
        if(state == 254){
            if(isPaid){
                colorText = UIColorFromRGB(rgbValue: 0xB0C977, alphaValue: 1)
                backgroundColor = UIColorFromRGB(rgbValue: 0xB0C977, alphaValue: 0.2)
                status = "УСПЕШНО ОФОРМЛЕНА"
                buttonNext.isHidden=true
            }else{
                colorText = UIColorFromRGB(rgbValue: 0xFACE54, alphaValue: 1)
                backgroundColor = UIColorFromRGB(rgbValue: 0xFACE54, alphaValue: 0.2)
                status = "ОЖИДАЕТ ОПЛАТЫ"
               buttonNext.isHidden=true
            }
           
        }
        statusView.updateUI(colorText: colorText, colorBackground: backgroundColor, text: status)
        widthStatus.constant = status.widthSize+32
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let headerArray = getHeadNames(dictionary: currentFullPolice)[section] as! NSArray
        return headerArray.count
    }
  
    func numberOfSections(in tableView: UITableView) -> Int {
        return getHeadNames(dictionary: currentFullPolice).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "Cell"
        let cell:FullInfoCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! FullInfoCell
        
        let headerArray = getHeadNames(dictionary: currentFullPolice)[indexPath.section] as! NSArray
        let namesArray = getDataForRows(dictionary: currentFullPolice)[indexPath.section] as! NSArray
        cell.headerLbl.text = headerArray[indexPath.row] as? String
        cell.infoLbl.text = namesArray[indexPath.row] as? String
        
        return cell
    }
    
}

func UIColorFromRGB(rgbValue: UInt, alphaValue: CGFloat) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(alphaValue)
    )
}

extension Formatter {
    func withSeparator() ->NumberFormatter{
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        return formatter
    }
}

extension Int{
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

extension Float {
    var formatFloat: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

