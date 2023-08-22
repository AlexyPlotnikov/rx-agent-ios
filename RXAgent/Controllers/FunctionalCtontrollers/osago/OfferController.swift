//
//  OfferController.swift
//  RXAgent
//
//  Created by RX Group on 28.04.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit

class OfferController: UIViewController {
    
    struct Tariff:Codable{
        let eosagoTariffItem:TariffItem
    }
    
    struct TariffItem:Codable{
        let costACD:Double
        let costB:Double
        let costE:Double
        let turboCostACD:Double
        let turboCostB:Double
        let turboCostE:Double
        let foreignCostACD:Double
        let foreignCostB:Double
        let foreignCostE:Double
    }
    
    var tariffItem:TariffItem!
    var isSending = false
    var isEdit = false
    @IBOutlet weak var promoView: UIView!
    @IBOutlet weak var pageControll: UIPageControl!
    
    
    @IBOutlet weak var bottomConst: NSLayoutConstraint!
    @IBOutlet weak var promoLbl: UILabel!
    @IBOutlet weak var promoImg: UIImageView!
    @IBOutlet weak var promocodeActiveLbl: UILabel!
    
    
    fileprivate var pageSize: CGSize {
        let layout = self.collectionView?.collectionViewLayout as! ZoomAndSnapFlowLayout
        var pageSize = layout.itemSize
        pageSize.width += layout.minimumLineSpacing
        return pageSize
    }
    
    @IBOutlet weak var animateLoading: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    lazy var offerArray = [Offer(id:1 ,cost: 0, colorCost: UIColor.init(displayP3Red: 91/255, green: 63/255, blue: 101/255, alpha: 1), tariffName: "Базовый", descriptionTariff:["Все цели использования", "Страховая премия до 25 000 ₽", "Период страхования 1 год"] ,imageName: "shieldImage", miniImagesArray: ["base1", "base2", "base3"],tarifTitle: "Основные возможности тарифа:"),
                           Offer(id:2 ,cost: 0, colorCost: UIColor.init(displayP3Red: 163/255, green: 205/255, blue: 58/255, alpha: 1), tariffName: "Турбо-режим", descriptionTariff: ["Страховая премия свыше 25 000 ₽", "Период страхования на 3, 6 месяцев", "Приоритетное оформление от 1 часа"],imageName: "turboImage", miniImagesArray: ["turbo1", "turbo2", "turbo3"],tarifTitle: "Расширение тарифа “Базовый”:"),
                           Offer(id:3 ,cost: 0, colorCost: UIColor(displayP3Red: 234/255, green: 151/255, blue: 29/255, alpha: 1), tariffName: "Иностранный", descriptionTariff:["Иностранное водительское удостоверение", "Иностранный паспорт и вид на жительство", "Оформление по предоплате"], imageName: "globeImg", miniImagesArray: ["foreign1", "foreign2", "foreign3"],tarifTitle: "Расширение тарифа “Базовый”:")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPromoView()
        self.setupCollection()
        self.configurePromo(isActived: DiscountObject.sharedInstance().discount != nil)
     
        
           
        
        
        getRequest(URLString: domain + "v0/eosagoTariffItems?tariff=\(Profile.shared.profile?.contractor?.tariff ?? 0)", completion: {
            result in
            print(result)
            DispatchQueue.main.async{
                do{
                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                    self.tariffItem = try! JSONDecoder().decode(Tariff.self, from: jsonData).eosagoTariffItem
                }catch{
                    
                }  
                if(categoryVehicleID == 2){
                    self.offerArray[1].cost = Int(self.tariffItem.turboCostB)
                    self.offerArray[0].cost = Int(self.tariffItem.costB)
                    self.offerArray[2].cost = Int(self.tariffItem.foreignCostB)
                }else if(categoryVehicleID == 5){
                    self.offerArray[1].cost = Int(self.tariffItem.turboCostE)
                    self.offerArray[0].cost = Int(self.tariffItem.costE)
                    self.offerArray[2].cost = Int(self.tariffItem.foreignCostE)
                }else{
                    self.offerArray[1].cost = Int(self.tariffItem.turboCostACD)
                    self.offerArray[0].cost = Int(self.tariffItem.costACD)
                    self.offerArray[2].cost = Int(self.tariffItem.foreignCostACD)
                }
                self.collectionView.isHidden = false
                self.animateLoading.isHidden = true
                self.collectionView.reloadData()
              
            }
            
        })
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updatePromo),
                                               name: NSNotification.Name(rawValue: "updatePormo"),
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(DiscountObject.sharedInstance().promoText != nil){
            let dict = ["Code":DiscountObject.sharedInstance().promoText ?? "", "Target":targetVehicleID, "Category":categoryVehicleID] as [String : Any]
            postRequest(JSON: dict, URLString: domain + "v0/promocodes/discount", completion: {
                result in
                
                do{
                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                    if let discount = try? JSONDecoder().decode(Discount.self, from: jsonData){
                        DiscountObject.sharedInstance().discount = discount.discount.eosago
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePormo"), object: nil, userInfo:nil)
                            
                        }
                    }else{
                        DispatchQueue.main.async {
                            DiscountObject.sharedInstance().discount = nil
                            DiscountObject.sharedInstance().promoText = nil
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePormo"), object: nil, userInfo:nil)
                            
                        }
                       
                    }
                }catch{
                    
                }
                
            })
        }
    }
    
    @objc func updatePromo(){
        self.configurePromo(isActived: DiscountObject.sharedInstance().discount != nil)
        self.collectionView.reloadData()
    }
    
    func setupCollection(){
        let pointEstimator = RelativeLayoutUtilityClass(referenceFrameSize: self.view.frame.size)
        let layout = ZoomAndSnapFlowLayout()
        
        self.collectionView?.translatesAutoresizingMaskIntoConstraints = false
        layout.itemSize = CGSize(width: pointEstimator.relativeWidth(multiplier: 0.83), height: pointEstimator.relativeHeight(multiplier: 0.62))
               
        layout.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = layout
        
        let spacingLayout = self.collectionView?.collectionViewLayout as! ZoomAndSnapFlowLayout
            spacingLayout.spacingMode = UPCarouselFlowLayoutSpacingMode.overlap(visibleOffset: 20)
    }
    
    func setupPromoView(){
        self.promoView.layer.masksToBounds = false
        self.promoView.layer.shadowColor = UIColor.init(displayP3Red: 154/255, green: 154/255, blue: 154/255, alpha: 0.15).cgColor
        self.promoView.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.promoView.layer.shadowRadius = 6
        self.promoView.layer.shadowOpacity = 1
    }
    
    func configurePromo(isActived:Bool){
        bottomConst.constant = isActived ? 6:16
        promoLbl.text = isActived ? DiscountObject.sharedInstance().promoText:"Промокод"
        promoImg.image = UIImage(named: isActived ? "editPromo":"voucherPromo")
        promocodeActiveLbl.isHidden = !isActived
        
        
    }
   
    @IBAction func back(_ sender: Any) {
        if(self.isEdit){
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
  
    func getOfferByIndex(index:Int) -> Offer{
        return offerArray[index]
    }

    func sendJSONtoServer(tarifID:Int){
       
        if(!isSending){
            isSending=true
        var myarr = [[String:String]]()
        
            if(!isMultiDrive){
                for i in 0..<countDriver{
                    if(i==0){
                    let dict = "{\"driverLicensePageFirstID\":\"\(vu1Driver1)\",\"driverLicensePageSecondID\":\"\(vu2Driver1)\",\"scanTranslationPageID\":\"\"}"
                            myarr.append(dict.convertToDictionary() ?? [:])
                    }
                    if(i==1){
                        let dict = "{\"driverLicensePageFirstID\":\"\(vu1Driver2)\",\"driverLicensePageSecondID\":\"\(vu2Driver2)\",\"scanTranslationPageID\":\"\"}"
                        myarr.append(dict.convertToDictionary() ?? [:])
                    }
                    if(i==2){
                        let dict = "{\"driverLicensePageFirstID\":\"\(vu1Driver3)\",\"driverLicensePageSecondID\":\"\(vu2Driver3)\",\"scanTranslationPageID\":\"\"}"
                        myarr.append(dict.convertToDictionary() ?? [:])
                    }
                    if(i==3){
                        let dict = "{\"driverLicensePageFirstID\":\"\(vu1Driver4)\",\"driverLicensePageSecondID\":\"\(vu2Driver4)\",\"scanTranslationPageID\":\"\"}"
                        myarr.append(dict.convertToDictionary() ?? [:])
                    }
                }
                
            }
        print(DiscountObject.sharedInstance().promoText ?? "")
        var param = ["ownerIsIndividual":"true",
                    "tariffType":tarifID,
                    "insurantIsOwner":"\(isOwner ? "true":"false")",
                    "ownerHasTemporaryRegistration":"\(hasRegInsurance ? "true":"false")",
                    "hasSaleContract":"\(hasDKPInsurance ? "true":"false")",
                    "insurantDocumentPageFirstID":"\(passport1Ins)",
                    "insurantDocumentPageSecondID":"\(passport2Ins)",
                    "ownerTemporaryRegistrationPageID":"\(regIns)",
                    "insurantCountry":"РОССИЯ",
                    "insurantCountryOKSM":"643",
                    "vehicleCategory":"\(String(categoryVehicleID))",
                    "vehicleTarget":"\(String(targetVehicleID))",
                    "vehicleSeats":"",
                    "vehicleNumberIsEmpty":"\(gosNumberEmpty ? "true":"false")",
                    "withTrailer":"\(trailerEmpty ? "true":"false")",
                    "unlimitedDrivers":"\(isMultiDrive ? "true":"false")",
                    "drivers":myarr,
                    "payCardPaymentSystem":"1",
                    "payCardFirstName":"\(creditFirstName)",
                    "payCardLastName":"\(creditLastName)",
                    "payCardMonth":"\(cardMonth)",
                    "payCardYear":"\(cardYear)",
                    "payCardNumber":"\(cardNumber)",
                    "payCardCVC":"\(cardCvc)",
                    "startDate":"\(dateStartForTable)",
                    "insurancePeriod":"\(String(periodID))",
                    "creatorFullName":"\(creatorInsurance)",
                    "creatorPhone":"\(creatorPhone)",
                    "insurantFullName":"\(fullNameInsurance)",
                    "insurantPhone":"\(phoneInsurance)",
                    "isShort":"true",
                    "isPriority":"false",
                    "agentComment":"\(commentAgent)",
                     "PromocodeText":DiscountObject.sharedInstance().promoText ?? ""
                    ] as [String : Any]
                    
                    if(weeklyChecked){
                        param["creatorWeekdaysTimeStart"] = creatorWeekdaysTimeStart
                        param["creatorWeekdaysTimeEnd"] = creatorWeekdaysTimeEnd
                    }
                    if(saturdayChecked){
                        param["creatorSaturdayTimeStart"] = creatorSaturdayTimeStart
                        param["creatorSaturdayTimeEnd"] = creatorSaturdayTimeEnd
                    }
                    if(sundayChecked){
                        param["creatorSundayTimeStart"] = creatorSundayTimeStart
                        param["creatorSundayTimeEnd"] = creatorSundayTimeEnd
                    }
            
            if(!isOwner){
                param["ownerDocumentPageFirstID"] = passport1Owner
                param["ownerDocumentPageSecondID"] = passport2Owner
            }
            
            if(hasDKPInsurance){
                param["saleContractPageID"] = "\(DKPIns)"
                param["noSaleContractPage"] = "\(hasDKPInsurance ? "false":"true")"
            }
            if(needPTS){
                param["noVehicleCertificatePage"] = "true"
                param["vehiclePassportPageFirstID"] = "\(PTSidFront)"
                param["vehiclePassportPageSecondID"] = "\(PTSidBack)"
            }else{
                param["noVehiclePassportPage"] = "true"
                param["vehicleCertificatePageFirstID"] = "\(SRTSidFront)"
                param["vehicleCertificatePageSecondID"] = "\(SRTSidBack)"
            }
            print(param)
            postRequest(JSON:param, URLString: "\(domain)v0/EOSAGOPolicies", completion: {
            result in
        
                let tempdict = result["eosagoPolicy"] as! [String:Any]
                getPatchRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(String(tempdict["id"] as! Int))/dispatch", completion: {
                   result in
                    DispatchQueue.main.async{
                        print("12345",result)
                        if let errors = (result["errors"] as? NSArray)?[0] as? String {
                            let alertController = UIAlertController(title: "Внимание!", message: errors, preferredStyle: .alert)
                            let alertAction = UIAlertAction( title : "OK" ,
                                                             style : .default) { action in
                                    clearAgregator()
                                    NotificationCenter.default.post(name: Notification.Name("close"), object: nil)
                                    self.isSending = false
                                    self.dismiss(animated: true, completion: nil)
                            }
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: false, completion: nil)
                        }else{
                            let alertController = UIAlertController(title: "Заявка создана!", message: "После одобрения от страховой компании Вы получите СМС-уведомление на указанный телефон.", preferredStyle: .alert)
                            let alertAction = UIAlertAction( title : "OK" ,
                                                             style : .default) { action in
                                    clearAgregator()
                                    NotificationCenter.default.post(name: Notification.Name("close"), object: nil)
                                    self.isSending = false
                                    self.dismiss(animated: true, completion: nil)
                            }
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: false, completion: nil)
                        }
                       
                        }
                })
           

        })
        }
    }
    
    func sendPUTJSON(tarifID:Int){
                var myarr = [[String:String]]()
                if(!isMultiDrive){
                    for i in 0..<countDriver{
                        if(i==0){
                            let dict = "{\"policy\":\"\(policyDriverArray[i] as! String)\",\"driverLicensePageFirstID\":\"\(vu1Driver1)\",\"driverLicensePageSecondID\":\"\(vu2Driver1)\",\"scanTranslationPageID\":\"\"}"
                            myarr.append(dict.convertToDictionary() ?? [:])
                        }
                        if(i==1){
                            let dict = "{\"policy\":\"\(policyDriverArray[i] as! String)\",\"driverLicensePageFirstID\":\"\(vu1Driver2)\",\"driverLicensePageSecondID\":\"\(vu2Driver2)\",\"scanTranslationPageID\":\"\"}"
                            myarr.append(dict.convertToDictionary() ?? [:])
                        }
                        if(i==2){
                            let dict = "{\"policy\":\"\(policyDriverArray[i] as! String)\",\"driverLicensePageFirstID\":\"\(vu1Driver3)\",\"driverLicensePageSecondID\":\"\(vu2Driver3)\",\"scanTranslationPageID\":\"\"}"
                            myarr.append(dict.convertToDictionary() ?? [:])
                        }
                        if(i==3){
                            let dict = "{\"policy\":\"\(policyDriverArray[i] as! String)\",\"driverLicensePageFirstID\":\"\(vu1Driver4)\",\"driverLicensePageSecondID\":\"\(vu2Driver4)\",\"scanTranslationPageID\":\"\"}"
                            myarr.append(dict.convertToDictionary() ?? [:])
                        }
                    }
        
                }
        
        
        
                var param = [
                    "ownerHasTemporaryRegistration":"\(hasRegInsurance ? "true":"false")",
                    "tariffType":tarifID,
                    "hasSaleContract":"\(hasDKPInsurance ? "true":"false")",
                    "insurantIsOwner":"\(isOwner ? "true":"false")",
                    "insurantDocumentPageFirstID":"\(passport1Ins)",
                    "insurantDocumentPageSecondID":"\(passport2Ins)",
                    "ownerTemporaryRegistrationPageID":"\(regIns)",
                    "unlimitedDrivers":"\(isMultiDrive ? "true":"false")",
                    "payCardPaymentSystem":"1",
                    "payCardFirstName":"\(creditFirstName)",
                    "payCardLastName":"\(creditLastName)",
                    "payCardMonth":"\(cardMonth)",
                    "payCardYear":"\(cardYear)",
                    "payCardNumber":"\(cardNumber)",
                    "payCardCVC":"\(cardCvc)",
                    "startDate":"\(dateStartForTable)",
                    "insurancePeriod":"\(periodID)",
                    "creatorFullName":"\(creatorInsurance)",
                    "creatorPhone":"\(creatorPhone)",
                    "insurantFullName":"\(fullNameInsurance)",
                    "clientPhone":"\(phoneInsurance)",
                    "agentComment":"\(commentAgent)",
                    "textStatus":"\(commentInsurance)",
                    "isShort":"true",
                    "isPriority":"false",
                    "drivers":myarr,
                    "PromocodeText":DiscountObject.sharedInstance().promoText ?? ""
                    ] as [String : Any]
        
                    print(param)
        
                    if(!isOwner){
                        param["ownerDocumentPageFirstID"] = passport1Owner
                        param["ownerDocumentPageSecondID"] = passport2Owner
                    }
                    if(weeklyChecked){
                        param["creatorWeekdaysTimeStart"] = creatorWeekdaysTimeStart
                        param["creatorWeekdaysTimeEnd"] = creatorWeekdaysTimeEnd
                    }
                    if(saturdayChecked){
                        param["creatorSaturdayTimeStart"] = creatorSaturdayTimeStart
                        param["creatorSaturdayTimeEnd"] = creatorSaturdayTimeEnd
                    }
                    if(sundayChecked){
                        param["creatorSundayTimeStart"] = creatorSundayTimeStart
                        param["creatorSundayTimeEnd"] = creatorSundayTimeEnd
                    }
                if(hasDKPInsurance){
                    param["saleContractPageID"] = "\(DKPIns)"
                    param["noSaleContractPage"] = "\(hasDKPInsurance ? "false":"true")"
                }
                if(needPTS){
                    param["noVehicleCertificatePage"] = "true"
                    param["vehiclePassportPageFirstID"] = "\(PTSidFront)"
                    param["vehiclePassportPageSecondID"] = "\(PTSidBack)"
                }else{
                    param["noVehiclePassportPage"] = "true"
                    param["vehicleCertificatePageFirstID"] = "\(SRTSidFront)"
                    param["vehicleCertificatePageSecondID"] = "\(SRTSidBack)"
                }
                        putRequest(JSON: param, URLString: "\(domain)v0/EOSAGOPolicies/updateShort/\(mainID)", completion: {
                            result in
                            print(result)
                            
                                getPatchRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)/dispatch", completion: {
                                    result in
                                    DispatchQueue.main.async{
                                        print(result)
                                        if let errors = (result["errors"] as? NSArray)?[0] as? String {
                                            let alertController = UIAlertController(title: "Внимание!", message: errors, preferredStyle: .alert)
                                            let alertAction = UIAlertAction( title : "OK" ,
                                                                             style : .default) { action in
                                                    clearAgregator()
                                                    NotificationCenter.default.post(name: Notification.Name("close"), object: nil)
                                                    self.isSending = false
                                                    self.dismiss(animated: true, completion: nil)
                                            }
                                        alertController.addAction(alertAction)
                                        self.present(alertController, animated: false, completion: nil)
                                        }else{
                                            self.isEdit=false
                                            activeItem=1
                                            clearAgregator()
                                            self.view.window!.rootViewController?.dismiss(animated: true, completion: {
                                                NotificationCenter.default.post(name: Notification.Name("close"), object: nil)
                                                NotificationCenter.default.post(name: Notification.Name("closeosago"), object: nil)
                                            })
                                    

                                    }
                                   }
                                })
                         
                            
                                                       
                            
        
                        })
    }
    
    @objc func offerChanged(button:UIButton){
        if(self.isEdit){
            self.sendPUTJSON(tarifID: self.offerArray[button.tag].id)
        }else{
            self.sendJSONtoServer(tarifID: self.offerArray[button.tag].id)
        }
        
    }
    
    func setMessage(_ text:String) {
        let alertController = UIAlertController(title: "Внимание!", message: text, preferredStyle: .alert)
        let alertAction = UIAlertAction( title : "OK" ,
                                         style : .default) { action in
                                           
        }
        alertController.addAction(alertAction)
        self.present(alertController, animated: false, completion: nil)
    }
    
    func categoryName()->String{
        switch categoryVehicleID {
        case 1:
            return "Категория «A»"
        case 2:
            return "Категория «B»"
        case 3:
            return "Категория «C»"
        case 4:
            return "Категория «D»"
        case 5:
            return "Категория «E»"
       
        default:
            return "Категория «B»"
        }
    }
    
    @IBAction func openPromo(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "promoVC") as! PromoController

        self.present(viewController, animated: true)
    }
    
    func getNewCost(index:Int)->(Int?, Int?){
        switch index {
        case 0:
            return (DiscountObject.sharedInstance().discount?.cost, DiscountObject.sharedInstance().discount?.percent)
        case 1:
            return (DiscountObject.sharedInstance().discount?.turboCost, DiscountObject.sharedInstance().discount?.turboPercent)
        case 2:
           
            return (DiscountObject.sharedInstance().discount?.foreignCost, DiscountObject.sharedInstance().discount?.foreignPercent)
        
        default:
            return (0,0)
        }
    }
    
}

extension OfferController:UICollectionViewDelegate, UICollectionViewDataSource{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return offerArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! OfferCell
        
        let offer = self.getOfferByIndex(index: indexPath.row)
        let newCost = self.getNewCost(index: indexPath.row)
        cell.setupCost(oldCost: offer.cost, color: offer.colorCost, newCost: newCost.0, discountPercent: newCost.1)
        cell.backgroundImage.image = UIImage(named: offer.imageName)
        cell.getOfferBtn.backgroundColor = offer.colorCost
        cell.tariffName.text = offer.tariffName
        cell.image1.image = UIImage(named: offer.miniImagesArray[0])
        cell.image2.image = UIImage(named: offer.miniImagesArray[1])
        cell.image3.image = UIImage(named: offer.miniImagesArray[2])
        cell.desc1.text = offer.descriptionTariff[0]
        cell.desc2.text = offer.descriptionTariff[1]
        cell.desc3.text = offer.descriptionTariff[2]
        cell.getOfferBtn.tag = indexPath.row
        cell.getOfferBtn.addTarget(self, action: #selector(offerChanged(button:)), for: .touchUpInside)
        cell.tariffTitle.text = offer.tarifTitle
        cell.categoryTitle.backgroundColor = offer.colorCost.withAlphaComponent(0.1)
        cell.categoryTitle.textColor = offer.colorCost
        cell.categoryTitle.text = self.categoryName()
        cell.categoryTitle.layer.cornerRadius = 14
        cell.categoryTitle.layer.masksToBounds = true
        
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//
//        if !(indexPath.section == 0), !(indexPath.row == 0) {
//            if(!isSending){
//                let indexPath = IndexPath(item: indexPath.row + 1, section: indexPath.section)
//                self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
//            }
//        }
//    }
//
   
    
   
  
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let layout = self.collectionView?.collectionViewLayout as! ZoomAndSnapFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        pageControll.currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
        
    }
   
}


class RelativeLayoutUtilityClass {

    var heightFrame: CGFloat?
    var widthFrame: CGFloat?

    init(referenceFrameSize: CGSize){
        heightFrame = referenceFrameSize.height
        widthFrame = referenceFrameSize.width
    }

    func relativeHeight(multiplier: CGFloat) -> CGFloat{

        return multiplier * self.heightFrame!
    }

    func relativeWidth(multiplier: CGFloat) -> CGFloat{
        return multiplier * self.widthFrame!

    }



}
