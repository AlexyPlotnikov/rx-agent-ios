//
//  DetailStateController.swift
//  RXAgent
//
//  Created by RX Group on 29.06.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit
import Lottie

class DetailStateController: UIViewController {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadLotie: AnimationView!
    @IBOutlet weak var topBtn: UIButton!
    @IBOutlet weak var bottombtn: UIButton!
    private let refreshControl = UIRefreshControl()
    var sumTo:Double = 0.0
    
    var viewModel:StateViewModel?
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(closeController), name: NSNotification.Name(rawValue: "close"), object: nil)
        loadLotie.play()
        loadLotie.loopMode = .loop
        loadLotie.contentMode = .scaleAspectFit
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshState()
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.topItem?.title = "Заявка №\(mainID)"
        self.table.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshState), for: .valueChanged)

        postReq(URLString: "https://api.rx-agent.ru/v0/eosagoPolicies/calculator/\(mainID)", completion: {
            result in
            if(result["error"] == nil){
                DispatchQueue.main.async {
                    self.sumTo = (result["eosagoCalculator"] as? [String:Any])?["sumTo"] as? Double ?? 0.0
                    self.table.reloadData()
                }
            }
        })
    }
    
    @objc func refreshState(){
        self.viewModel?.loadOsago(osagoID: mainID, completion: {
            getRequest(URLString: "\(domain)v0/InsurancePeriods", completion:{ result in
                DispatchQueue.main.async{
                    print(result)
                    let array = result["insurancePeriods"] as! NSArray
                    if let period = array.first(where: {($0 as! [String:Any])["id"] as? Int == self.viewModel?.model?.insurancePeriod}) as? [String:Any]{
                        periodTitle = period["title"] as! String
                    }
                    DiscountObject.sharedInstance().promoText = self.viewModel?.model?.promocodeText
                    creditFirstName = self.viewModel?.model?.payCardFirstName ?? ""
                    creditLastName = self.viewModel?.model?.payCardLastName ?? ""
                    cardMonth = self.viewModel?.model?.payCardMonth ?? ""
                    cardYear = self.viewModel?.model?.payCardYear ?? ""
                    cardNumber = self.viewModel?.model?.payCardNumber ?? ""
                    cardCvc =  self.viewModel?.model?.payCardCVC ?? ""
                  //  print(cardNumber, creditFirstName, creditLastName, cardMonth, cardYear, cardCvc)
                    fullNameInsurance = self.viewModel?.model?.insurantFullName ?? ""
                    phoneInsurance = self.viewModel?.model?.insurantPhone ?? ""
                    commentInsurance = self.viewModel?.model?.textStatus ?? "-"
                    commentAgent = self.viewModel?.model?.agentComment ?? ""
                    creatorPhone = self.viewModel?.model?.creatorPhone ?? ""
                    creatorInsurance = self.viewModel?.model?.creatorFullName ?? ""
                    periodID = self.viewModel?.model?.insurancePeriod ?? 0
                    dateStartForTable = self.viewModel?.model?.startDate ?? ""
                    dateStartForTable = dateStartForTable.components(separatedBy: "T")[0]
                    let dateFormatter2 = DateFormatter()
                    dateFormatter2.dateFormat = "YYYY-MM-dd"
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = NSLocale.init(localeIdentifier: "ru") as Locale
                    dateFormatter.dateFormat = "dd MMMM yyyy"
                    if(dateFormatter2.date(from: dateStartForTable)!<=(Calendar.current.date(byAdding: .day, value: 4, to: Date())!)){
                        propertyDateStart = dateFormatter.string(from: self.calculateNewDate())
                        dateStartForTable = dateFormatter2.string(from: self.calculateNewDate())
                    }else{
                        propertyDateStart = dateFormatter.string(from: dateFormatter2.date(from: dateStartForTable)!)
                    }
                    isOwner = self.viewModel?.model?.insurantIsOwner ?? false
                    if(isOwner){
                        countOptions=2
                    }else{
                        countOptions=0
                    }
                    countRowVehicle = 3
                    hasDKPInsurance = self.viewModel?.model?.hasSaleContract ?? false
                    hasRegInsurance = self.viewModel?.model?.ownerHasTemporaryRegistration ?? false
                    needPTS = self.viewModel?.model?.vehicleDocID == 1
                    passport1Ins = "\(self.viewModel?.model?.insurantDocumentPageFirstID ?? 0)"
                    passport2Ins = "\(self.viewModel?.model?.insurantDocumentPageSecondID ?? 0)"
                    DKPIns = "\(self.viewModel?.model?.saleContractPageID ?? 0)"
                    regIns = "\(self.viewModel?.model?.ownerTemporaryRegistrationPageID ?? 0)"
                    passport1Owner = "\(self.viewModel?.model?.ownerDocumentPageFirstID ?? 0)"
                    passport2Owner = "\(self.viewModel?.model?.ownerDocumentPageSecondID ?? 0)"
                    PTSidFront = "\(self.viewModel?.model?.vehiclePassportPageFirstID ?? 0)"
                    PTSidBack = "\(self.viewModel?.model?.vehiclePassportPageSecondID ?? 0)"
                    SRTSidFront = "\(self.viewModel?.model?.vehicleCertificatePageFirstID ?? 0)"
                    SRTSidBack = "\(self.viewModel?.model?.vehicleCertificatePageSecondID ?? 0)"
                    isMultiDrive = self.viewModel?.model?.unlimitedDrivers ?? false
                    saturdayChecked = self.viewModel?.model?.creatorSaturdayTimeEnd != nil && self.viewModel?.model?.creatorSaturdayTimeStart != nil
                    weeklyChecked = self.viewModel?.model?.creatorWeekdaysTimeEnd != nil && self.viewModel?.model?.creatorWeekdaysTimeStart != nil
                    sundayChecked = self.viewModel?.model?.creatorSundayTimeEnd != nil && self.viewModel?.model?.creatorSundayTimeStart != nil
                    
                    if(saturdayChecked){
                        creatorSaturdayTimeEnd = (self.viewModel?.model?.creatorSaturdayTimeEnd)!
                        creatorSaturdayTimeStart = (self.viewModel?.model?.creatorSaturdayTimeStart)!
                    }
                    if(weeklyChecked){
                        creatorWeekdaysTimeEnd = (self.viewModel?.model?.creatorWeekdaysTimeEnd)!
                        creatorWeekdaysTimeStart = (self.viewModel?.model?.creatorWeekdaysTimeStart)!
                    }
                    if(sundayChecked){
                        creatorSundayTimeEnd = (self.viewModel?.model?.creatorSundayTimeEnd)!
                        creatorSundayTimeStart = (self.viewModel?.model?.creatorSundayTimeStart)!
                    }
                    if(!isMultiDrive){
                        countDriver = self.viewModel?.model?.drivers?.count ?? 0
                        for i in 0..<(self.viewModel?.model?.drivers?.count ?? 0){
                            idDriverArray[i] = self.viewModel?.model?.drivers?[i].id ?? ""
                            policyDriverArray[i] = "\(self.viewModel?.model?.drivers?[i].policy ?? 0)"
                            if(i==0){
                                vu1Driver1 = "\(self.viewModel?.model?.drivers?[i].driverLicensePageFirstID ?? 0)"
                                vu2Driver1 = "\(self.viewModel?.model?.drivers?[i].driverLicensePageSecondID ?? 0)"
                                if(vu1Driver1 != "0" && vu2Driver1 != "0"){
                                    imagesDriver.replaceObject(at: 0,with:  self.load(url: domain +  "v0/Attachments/data/\(vu1Driver1)/min") ?? UIImage())
                                    imagesDriver.replaceObject(at: 1,with:  self.load(url: domain +  "v0/Attachments/data/\(vu2Driver1)/min") ?? UIImage())
                                }
                            }
                           if(i==1){
                               vu1Driver2 = "\(self.viewModel?.model?.drivers?[i].driverLicensePageFirstID ?? 0)"
                               vu2Driver2 = "\(self.viewModel?.model?.drivers?[i].driverLicensePageSecondID ?? 0)"
                               if(vu1Driver2 != "0" && vu2Driver2 != "0"){
                                   imagesDriver.replaceObject(at: 2,with:  self.load(url: domain +  "v0/Attachments/data/\(vu1Driver2)/min") ?? UIImage())
                                   imagesDriver.replaceObject(at: 3,with:  self.load(url: domain +  "v0/Attachments/data/\(vu2Driver2)/min") ?? UIImage())
                               }
                           }
                          if(i==2){
                              vu1Driver3 = "\(self.viewModel?.model?.drivers?[i].driverLicensePageFirstID ?? 0)"
                              vu2Driver3 = "\(self.viewModel?.model?.drivers?[i].driverLicensePageSecondID ?? 0)"
                              if(vu1Driver3 != "0" && vu2Driver3 != "0"){
                                  imagesDriver.replaceObject(at: 4,with:  self.load(url: domain +  "v0/Attachments/data/\(vu1Driver3)/min") ?? UIImage())
                                  imagesDriver.replaceObject(at: 5,with:  self.load(url: domain +  "v0/Attachments/data/\(vu2Driver3)/min") ?? UIImage())
                              }
                          }
                         if(i==3){
                             vu1Driver4 = "\(self.viewModel?.model?.drivers?[i].driverLicensePageFirstID ?? 0)"
                             vu2Driver4 = "\(self.viewModel?.model?.drivers?[i].driverLicensePageSecondID ?? 0)"
                             if(vu1Driver4 != "0" && vu2Driver4 != "0"){
                                 imagesDriver.replaceObject(at: 6,with:  self.load(url: domain +  "v0/Attachments/data/\(vu1Driver4)/min") ?? UIImage())
                                 imagesDriver.replaceObject(at: 7,with:  self.load(url: domain +  "v0/Attachments/data/\(vu2Driver4)/min") ?? UIImage())
                             }
                         }
                        }
                    }
                    if(passport1Ins != "0" && passport2Ins != "0"){
                        imagesInsurance.replaceObject(at: 0, with: self.load(url: domain+"v0/Attachments/data/\(passport1Ins)/min") ?? UIImage())
                        imagesInsurance.replaceObject(at: 1, with: self.load(url: domain+"v0/Attachments/data/\(passport2Ins)/min") ?? UIImage())
                    }
                    if(DKPIns != "0"){
                        imagesInsurance.replaceObject(at: 2, with: self.load(url: domain+"v0/Attachments/data/\(DKPIns)/min") ?? UIImage())
                        if !isOwner {
                            imagesOwner.replaceObject(at: 2, with: self.load(url: domain+"v0/Attachments/data/\(DKPIns)/min") ?? UIImage())
                        }
                    }
                    if(regIns != "0"){
                        imagesInsurance.replaceObject(at: 3, with: self.load(url: domain+"v0/Attachments/data/\(regIns)/min") ?? UIImage())
                        if !isOwner {
                            imagesOwner.replaceObject(at: 3, with: self.load(url: domain+"v0/Attachments/data/\(regIns)/min") ?? UIImage())
                        }
                    }
                    if(passport1Owner != "0" && passport2Owner != "0"){
                        imagesOwner.replaceObject(at: 0, with: self.load(url: domain+"v0/Attachments/data/\(passport1Owner)/min") ?? UIImage())
                        imagesOwner.replaceObject(at: 1, with: self.load(url: domain+"v0/Attachments/data/\(passport2Owner)/min") ?? UIImage())
                    }
                    if(PTSidFront != "0" && PTSidBack != "0"){
                        imagesPTS.replaceObject(at: 0, with: self.load(url: domain+"v0/Attachments/data/\(PTSidFront)/min") ?? UIImage())
                        imagesPTS.replaceObject(at: 1, with: self.load(url: domain+"v0/Attachments/data/\(PTSidBack)/min") ?? UIImage())
                    }
                    if(SRTSidFront != "0" && SRTSidBack != "0"){
                        imagesSRTS.replaceObject(at: 0, with: self.load(url: domain+"v0/Attachments/data/\(SRTSidFront)/min") ?? UIImage())
                        imagesSRTS.replaceObject(at: 1, with: self.load(url: domain+"v0/Attachments/data/\(SRTSidBack)/min") ?? UIImage())
                    }
                    
                    
                    self.loadLotie.stop()
                    self.loadingView.isHidden = true
                    self.table.dataSource = self
                    self.table.delegate = self
                    self.table.reloadData()
                    self.refreshControl.endRefreshing()
                }
            })
        })
    }
    
   @objc func closeController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func calculateNewDate() -> Date {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 4, to: today)
        return tomorrow!
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
   
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func aceptButtonAction(_ sender: Any) {
        
        if(state == 3){
            self.loadLotie.play()
            self.loadingView.isHidden = false
            getPatchRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)/state/5", completion: {
                result in
                DispatchQueue.main.async{
                    self.refreshState()
                    
                }
            })
        }else if(state == 254){
            let image = self.load(url: "\(domain)v0/attachments/data/\(self.viewModel?.model?.pageID ?? 0)")
            let appImage = ViewerImage.appImage(forImage: image!)
            let viewer = AppImageViewer(originImage: image!, photos: [appImage], animatedFromView: bottombtn)
           
            present(viewer, animated: true, completion: nil)
        }
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        
        if(state == 0){
            isEdit = true
            activeItem = 1
            let storyboard = UIStoryboard(name: "OSAGO", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "osagoVC") as! MainOsagoController
            self.present(viewController, animated: true, completion: nil)
        }else if(state == 3){
            self.loadLotie.play()
            self.loadingView.isHidden = false
            let alert = UIAlertController(title: "", message: "Вы действительно хотите отменить заявку?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Нет", style: .destructive, handler: {action in
                self.loadLotie.stop()
                self.loadingView.isHidden = true
            }))
            
            alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
                self.loadLotie.play()
                self.loadingView.isHidden = false
                getPatchRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)/state/4", completion: {
                    result in
                    self.refreshState()
                })
            }))
             self.present(alert, animated: true, completion: nil)
            
        }else if(state == 7){
            
                let alert = UIAlertController(title: "", message: "Введите код из СМС", preferredStyle: .alert)
                
                alert.addTextField { (textField) in
                    textField.keyboardType = .phonePad
                    textField.placeholder = "СМС-код"
                }
               
                alert.addAction(UIAlertAction(title: "Отправить", style: .default, handler: { [weak alert] (_) in
                    let textField = alert?.textFields![0]
                    if(textField!.text!.count>0){
                        self.loadLotie.play()
                        self.loadingView.isHidden = false
                        getPatchRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)/sms?code=\(textField!.text ?? "")", completion: {_ in
                            self.refreshState()
                        })
                    }
                }))
               
                self.present(alert, animated: true, completion: nil)
            
        }else if(state == 254){
            if(!isPaid){
                if(hidePayCard ?? false){
//                    let alert = UIAlertController(title: "Оплата", message: "", preferredStyle: .actionSheet)
//                        
//                        alert.addAction(UIAlertAction(title: "Оплатить в страховой компании", style: .default , handler:{ (UIAlertAction)in
//                            print(self.viewModel?.model?.payCardURL)
//                        }))
//                        
//                        alert.addAction(UIAlertAction(title: "Оплачено", style: .default , handler:{ (UIAlertAction)in
//                            print("User click Edit button")
//                        }))
//
//                        alert.addAction(UIAlertAction(title: "Обновить ссылку", style: .destructive , handler:{ (UIAlertAction)in
//                            print("User click Delete button")
//                        }))
//                        
//                        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler:{ (UIAlertAction)in
//                            print("User click Dismiss button")
//                        }))
//
//                        
//                        //uncomment for iPad Support
//                        alert.popoverPresentationController?.sourceView = self.view
//
//                        self.present(alert, animated: true, completion: {
//                            print("completion block")
//                        })
                }else{
                    let alert = UIAlertController(title: "", message: "Вы действительно хотите оплатить заявку? Доплата составит \(self.viewModel?.model?.baseCost ?? 0)₽", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Нет", style: .destructive, handler: nil))
                    alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
                        self.loadLotie.play()
                        self.loadingView.isHidden = false
                        postReq(URLString: "\(domain)v0/balanceOperations/debit/8/\(mainID)", completion: {_ in
                            
                            self.refreshState()
                        })
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }else{
                let image = self.load(url: "\(domain)v0/attachments/data/\(self.viewModel?.model?.pageID ?? 0)")
                
                let imageToShare = [image!]
                let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.excludedActivityTypes = [ .airDrop, .postToFacebook ]
                
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    func calculateStatus(status:Int, isPaied:Bool) -> String{
        state = status
        isPaid = isPaied
        switch status {
        case 0:
            if(viewModel?.model?.ownerDate != nil || viewModel?.model?.insurantDate != nil){
                self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
                topBtn.isHidden = true
                return "Отправьте в обработку"
            }else{
                self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
                topBtn.isHidden = true
                return "Новая заявка"
            }
        case 1:
            self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            topBtn.isHidden = true
            bottombtn.isHidden = true
            
            return "Заявка отправлена"
        case 3:
            self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
            topBtn.isHidden = false
            bottombtn.isHidden = false
            topBtn.setTitle("Принять", for: .normal)
            bottombtn.setTitle("Отказаться", for: .normal)
            return "Примите условия"
        case 4:
            self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            topBtn.isHidden = true
            bottombtn.isHidden = true
            return "Заявка отменена"
        case 7:
            self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
            topBtn.isHidden = true
            bottombtn.isHidden = false
            bottombtn.setTitle("Ввести СМС-код", for: .normal)
            return "Укажите СМС-код"
        case 254:
            if(isPaied){
                self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
                topBtn.isHidden = false
                bottombtn.isHidden = false
                topBtn.setTitle("Посмотреть", for: .normal)
                bottombtn.setTitle("Поделиться", for: .normal)
                return "Успешно оформлена"
            }else{
                self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
                topBtn.isHidden = true
                bottombtn.isHidden = false
                bottombtn.setTitle("Оплатить", for: .normal)
                return "Ожидает оплаты"
            }
        default:
            self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            topBtn.isHidden = true
            bottombtn.isHidden = true
            return "В обработке"
        }
    }

    func parseDate(date:String)->String{
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "YYYY-MM-dd"
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.init(localeIdentifier: "ru") as Locale
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        return dateFormatter.string(from: dateFormatter2.date(from: date)!)
    }
  
    func load(url: String?) -> UIImage?{
        if((url) != nil){
            let data = try? Data(contentsOf: NSURL(string: url!)! as URL)
               if(data != nil){
                   var image = UIImage(data: data!)
                   if(image==nil){
                       image = drawPDFfromURL(url: NSURL(string: url!)! as URL)
                   }
                   return image!
               }else{
                   return nil
               }
        }else{
            return nil
        }
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
}




extension DetailStateController:UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 1 || section == 2){
            return 15
        }else{
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 1){
            return "Комментарий к заявке"
        }else if(section == 2){
            return "Данные о заявке"
        }else{
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0){
            if(viewModel?.model?.state ?? 0 == 4){
                return 0
            }else{
                return 100
            }
        }else if(indexPath.section == 1){
            return commentInsurance.height(withConstrainedWidth: self.table.frame.size.width-32, font: UIFont.systemFont(ofSize: 17)) + 32
        }else{
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if(section == 2){
            return 4
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
        let cellReuseIdentifier = "cellCalculate"
        let cell:DetailStateCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! DetailStateCell
          
            if(viewModel?.model?.state ?? 0 >= 3 || self.sumTo == 0.0){
                cell.calculateLbl.isHidden = self.viewModel?.model?.cost != nil
                cell.costLbl.isHidden = self.viewModel?.model?.cost == nil
                cell.costLbl.text = "\(self.viewModel?.model?.cost ?? 0) ₽"
                cell.descriptionCost.isHidden = self.viewModel?.model?.cost == nil
                cell.descriptionCost.text = "Сумма полиса:"
            }else{
                cell.calculateLbl.isHidden = true
                cell.costLbl.isHidden = false
                cell.costLbl.text = "\(self.sumTo) ₽"
                cell.descriptionCost.isHidden = false
                cell.descriptionCost.text = "Примерная стоимость:"
            }
            let image:UIImage?
            switch self.viewModel?.model?.insuranceCompany {
            case .INSURANCE_ALPHA_ID:
                image = UIImage(named: "ins-alpha")
            case .INSURANCE_INGOS_ID:
                image = UIImage(named: "ins-ingos")
            case .INSURANCE_RX_ID:
                image = UIImage(named: "ins-rx")
            case .INSURANCE_RENESSANS_ID:
                image = UIImage(named: "ins-renesans")
            case .INSURANCE_RESO_ID:
                image = UIImage(named: "ins-reso")
            case .INSURANCE_RGS_ID:
                image = UIImage(named: "ins-rgs")
            case .INSURANCE_SOGLASIE_SUPER_ID:
                image = UIImage(named: "ins-soglas")
            case .INSURANCE_VSK_ID:
                image = UIImage(named: "ins-vsk")
            case .INSURANCE_ZETTA_SUPER_ID:
                image = UIImage(named: "ins-zetta")
                
            default:
                image = UIImage(named: "calculateCar")
            }
            
            cell.insuranceImage.image = image
            
        return cell
        }else if(indexPath.section == 1){
            let cellReuseIdentifier = "commentCell"
            let cell:DetailStateCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! DetailStateCell
                cell.descriptionLbl.text = commentInsurance 
            return cell
        }else if(indexPath.section == 2){
            let cellReuseIdentifier = "cell"
            let cell:DetailStateCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! DetailStateCell
            switch indexPath.row {
            case 0:
                cell.titleLbl.text = "Статус"
                cell.descriptionLbl.text = self.calculateStatus(status: viewModel?.model?.state ?? 0, isPaied: viewModel?.model?.paid ?? false)
            case 1:
                cell.titleLbl.text = "ФИО"
                cell.descriptionLbl.text = viewModel?.model?.insurantFullName ?? "-"
            case 2:
                cell.titleLbl.text = "Период страхования"
                cell.descriptionLbl.text = periodTitle
            case 3:
                cell.titleLbl.text = "Дата начала полиса"
                var newDate = viewModel?.model?.startDate ?? ""
                if let dotRange = newDate.range(of: "T") {
                    newDate.removeSubrange(dotRange.lowerBound..<(newDate.endIndex))
                }
                cell.descriptionLbl.text = self.parseDate(date: newDate)
            
            default:
                cell.titleLbl.text = "Статус"
                cell.descriptionLbl.text = self.calculateStatus(status: (viewModel?.model?.state)!, isPaied: (viewModel?.model?.paid)!)
            }
            return cell
        }else if(indexPath.section == 3){
            let cellReuseIdentifier = "cell"
            let cell:DetailStateCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! DetailStateCell
                cell.titleLbl.text = "Страхователь/Собственник"
            cell.descriptionLbl.text = viewModel?.model?.insurantFullName ?? "-"
            return cell
        }else if(indexPath.section == 4){
            let cellReuseIdentifier = "cell"
            let cell:DetailStateCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! DetailStateCell
                cell.titleLbl.text = "Автомобиль"
            cell.descriptionLbl.text = (viewModel?.model?.vehicleMark ?? "-") + " " + (viewModel?.model?.vehicleModel ?? "")
            return cell
        }else{
            let cellReuseIdentifier = "cell"
            let cell:DetailStateCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! DetailStateCell
                cell.titleLbl.text = "Водители"
            cell.descriptionLbl.text = "\((self.viewModel?.model?.drivers?.count ?? 0)) чел."
            return cell
        }
    }
    
}


