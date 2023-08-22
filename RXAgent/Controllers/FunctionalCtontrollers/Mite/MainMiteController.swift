//
//  MainMiteController.swift
//  RXAgent
//
//  Created by RX Group on 17.03.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import SPIndicator
import UIKit

class MainMiteController: UIViewController {

    var container: MiteContainerController!
    @IBOutlet weak var stepper: CalcStepperView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var stepLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    
    
    var isIndicatorViewed = false
    var currentStep = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextBtn.layer.cornerRadius = 10
        stepper.countItems = 3
        stepper.delegate = self
        container!.segueIdentifierReceivedFromParent("stepThree")
        container!.segueIdentifierReceivedFromParent("firstStep")
        
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "container"{
            container = (segue.destination as! MiteContainerController)
            container.animationDurationWithOptions = (0.2, .curveEaseIn)
        }
    }

    @IBAction func close(_ sender: Any) {
        let alert = UIAlertController(title: "Внимание", message: "Вы действительно хотите прервать заполнение заявки?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
            self.dismiss(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func nextStep(_ sender: Any) {
        if(currentStep == 0){
            if(MiteModel.sharedInstance().miteItem.items.count < 1){
                if(!isIndicatorViewed){
                    self.isIndicatorViewed = true
                    SPIndicator.present(title: "Добавьте застрахованное лицо", haptic: .error, completion:{
                        self.isIndicatorViewed = false
                    })
                }
            }else{
                if(MiteModel.sharedInstance().tempMite.fullName != "" || MiteModel.sharedInstance().tempMite.fullName != ""){
                    if(!isIndicatorViewed){
                        self.isIndicatorViewed = true
                        SPIndicator.present(title: "У вас есть недобавленное застрахованное лицо", haptic: .error, completion: {
                            self.isIndicatorViewed = false
                        })
                    }
                }else{
                    NotificationCenter.default.post(name: Notification.Name("reloadRegion"), object: nil)
                    nextBtn.setTitle("Продолжить", for: .normal)
                    self.currentStep = 1
                    stepper.nextStep()
                    stepLbl.text = "Шаг 2 из 3"
                    titleLbl.text = "Страхователь"
                    container!.segueIdentifierReceivedFromParent("secondStep")
                    return
                }
                
            }
        }
        
        if(currentStep == 1){
            
            
            if(!isIndicatorViewed){
                if(MiteModel.sharedInstance().miteItem.dob.count == 11){
                    MiteModel.sharedInstance().miteItem.dob.removeLast()
                }
                if(MiteModel.sharedInstance().miteItem.passportDate.count == 11){
                    MiteModel.sharedInstance().miteItem.passportDate.removeLast()
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.mm.yyyy"
                var dict = [String:Any]()
                var newWord = ""
                for word in MiteModel.sharedInstance().miteItem.fullName{
                    if(word != " " && word != "."){
                        newWord = newWord + "\(word)"
                    }
                }
                if newWord.isEmpty {
                    dict["cell"] = 0
                    dict["text"] = "Укажите ФИО"
                }else if(MiteModel.sharedInstance().miteItem.fullName.count < 1){
                    dict["cell"] = 0
                    dict["text"] = "Укажите ФИО"
                }else  if(MiteModel.sharedInstance().miteItem.dob.count < 10){
                    dict["cell"] = 2
                    dict["text"] = "Укажите дату рождения"
                }else  if(!validateDate(dateStr: MiteModel.sharedInstance().miteItem.dob)){
                    dict["cell"] = 2
                    dict["text"] = "Некорректная дата рождения"
                }else if(!self.checkDate(dateTemp: MiteModel.sharedInstance().miteItem.dob)){
                    dict["cell"] = 2
                    dict["text"] = "Дата рождения не может быть больше 100 лет"
                }else if(self.getYearDefferent(firstYear: MiteModel.sharedInstance().miteItem.dob, secondYear: dateFormatter.string(from: Date())) < 18){
                    dict["cell"] = 2
                    dict["text"] = "Страхователь должен быть совершеннолетним"
                }else if(MiteModel.sharedInstance().miteItem.passportSeries.count < 4){
                    dict["cell"] = 3
                    dict["text"] = "Укажите серию паспорта"
                }else if(MiteModel.sharedInstance().miteItem.passportNumber.count < 6){
                    dict["cell"] = 3
                    dict["text"] = "Укажите номер паспорта"
                }else if(MiteModel.sharedInstance().miteItem.passportRegistrator.count < 1){
                    dict["cell"] = 4
                    dict["text"] = "Укажите кем выдан паспорт"
                }else  if(MiteModel.sharedInstance().miteItem.passportDate.count < 10){
                    dict["cell"] = 5
                    dict["text"] = "Укажите дату выдачи паспорта"
                }else if(!validateDate(dateStr: MiteModel.sharedInstance().miteItem.passportDate)){
                    dict["cell"] = 5
                    dict["text"] = "Некорректная дата выдачи паспорта"
                }else if(!self.checkDate(dateTemp: MiteModel.sharedInstance().miteItem.passportDate)){
                    dict["cell"] = 5
                    dict["text"] = "Дата выдачи не может быть больше 100 лет"
                }else if(self.getYearDefferent(firstYear: MiteModel.sharedInstance().miteItem.dob, secondYear: MiteModel.sharedInstance().miteItem.passportDate) < 14){
                    dict["cell"] = 5
                    dict["text"] = "Некорректная дата выдачи паспорта"
                }else if(MiteModel.sharedInstance().miteItem.address.count < 1){
                    dict["cell"] = 6
                    dict["text"] = "Укажите регион"
                }else if(MiteModel.sharedInstance().adressName.count < 1){
                    dict["cell"] = 7
                    dict["text"] = "Укажите населенный пункт"
                }else if(MiteModel.sharedInstance().miteItem.house.count < 1){
                    dict["cell"] = 9
                    dict["text"] = "Укажите номер дома"
                }else{
                    
                        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reloadProgram"),object: nil))
                        nextBtn.setTitle("Сохранить", for: .normal)
                        self.currentStep = 2
                        stepper.nextStep()
                        stepLbl.text = "Шаг 3 из 3"
                        titleLbl.text = "Данные о полисе"
                        container!.segueIdentifierReceivedFromParent("stepThree")
                        return
                
                   
                }
                
                NotificationCenter.default.post(name: Notification.Name("updateCell"), object: nil,userInfo: dict)
            }
            
            
        }
        
        if(self.currentStep == 2){
            if(self.validateMite()){
            var dict = MiteModel.sharedInstance().miteItem.asDictionary
           // print(dict)
            var itemsTmp:[[String:Any]] = []
            for item in MiteModel.sharedInstance().miteItem.items{
                var tmpItem = item.asDictionary
                let dob = tmpItem["dob"] as! String
                tmpItem["dob"] = self.formatDate(jsonDate: dob)
                itemsTmp.append(tmpItem)
            }
            dict["phone"] = (dict["phone"] as! String).replacingOccurrences(of: "+7", with: "")
            dict["phone"] = (dict["phone"] as! String).replacingOccurrences(of: " ", with: "")
            dict["phone"] = (dict["phone"] as! String).replacingOccurrences(of: "(", with: "")
            dict["phone"] = (dict["phone"] as! String).replacingOccurrences(of: ")", with: "")
            dict["items"] = itemsTmp
            dict["region"] = Profile.shared.profile!.region!.id
            let dob = dict["dob"] as! String
            dict["dob"] = self.formatDate(jsonDate:dob)
            
            let passD = dict["passportDate"] as! String
            dict["passportDate"] = self.formatDate(jsonDate:passD)
            
            
          //  print(dict)
            postRequest(JSON: dict, URLString: domain + "v0/MitePolicies", completion: {
                result in
                DispatchQueue.main.async {
                    if((result["errors"] as? Array<Any>) != nil){
                        self.setMessage((result["errors"] as! Array)[0])
                    }else{
                        NotificationCenter.default.post(name: Notification.Name("close"), object: nil)
                        SPIndicator.present(title: "Заявка успешно создана", haptic: .error, completion: {
                            
                        })
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                
            })
            }else{
                self.isIndicatorViewed = true
                    SPIndicator.present(title: "Пожалуйста, заполните все этапы", haptic: .error, completion: {
                        self.isIndicatorViewed = false
                    })
                    
            }
        }
        
        
    }
    
    func getYearDefferent(firstYear:String, secondYear:String) -> Int{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.mm.yyyy"
        let calendar = NSCalendar.current as NSCalendar

        let date1 = calendar.startOfDay(for: dateFormatter.date(from: firstYear)!)
        let date2 = calendar.startOfDay(for: dateFormatter.date(from: secondYear)!)

        let flags = NSCalendar.Unit.year
        let components = calendar.components(flags, from: date1, to: date2, options: [])
        return components.year!
    }
    
    func setMessage(_ text:String) {
        DispatchQueue.main.async{
            let alertController = UIAlertController(title: "Внимание!", message:
                text , preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    func checkDate(dateTemp:String)->Bool{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        if(dateFormatter.date(from: dateTemp) == nil){
            return false
        }else{
            let components = dateFormatter.date(from: dateTemp)!.get(.year)
            if let year = components.year {
                if(year < Date().get(.year).year! - 100){
                    return false
                }else{
                    return true
                }
            }else{
                return false
            }
            
        }
       
    }
    
    func validateMite() -> Bool{
        if(MiteModel.sharedInstance().miteItem.items.count < 1){
           return false
        }else{
            if(MiteModel.sharedInstance().tempMite.fullName != "" || MiteModel.sharedInstance().tempMite.fullName != ""){
                return false
            }else{
                    if(MiteModel.sharedInstance().miteItem.fullName.count < 1){
                        
                        return false
                    }else if(MiteModel.sharedInstance().miteItem.dob.count < 10){
                        return false
                    }else if(!validateDate(dateStr: MiteModel.sharedInstance().miteItem.dob)){
                        return false
                    }else if(MiteModel.sharedInstance().miteItem.passportSeries.count < 4){
                        return false
                    }else if(MiteModel.sharedInstance().miteItem.passportNumber.count < 6){
                        return false
                    }else if(MiteModel.sharedInstance().miteItem.passportRegistrator.count < 1){
                        return false
                    }else if(MiteModel.sharedInstance().miteItem.passportDate.count < 10){
                        return false
                    }else if(!validateDate(dateStr: MiteModel.sharedInstance().miteItem.passportDate)){
                        return false
                    }else if(MiteModel.sharedInstance().miteItem.address.count < 1){
                        return false
                    }else if(MiteModel.sharedInstance().miteItem.house.count < 1){
                        return false
                    }else{
                        return true
                    }
                }
            
            
        }
       
    }
    
    func validateDate(dateStr:String) -> Bool{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
   
    if let date = dateFormatter.date(from:dateStr) {
            if(date <= Date()){
                if(dateStr.count < 10){
                    return false
                }else{
                    return true
                   
                }
            }else{
                return false
            }
            
        } else {
            return false
        }
    }
    
    func formatDate(jsonDate:String) -> String{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd.MM.yyyy"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd"
        
        
        let date = dateFormatterGet.date(from: jsonDate)
        
        return dateFormatterPrint.string(from: date!)
    }
    
}

extension MainMiteController:CalcStepperViewDelegate{
    func stepClicked(index: Int) {
        self.currentStep = index - 1
        stepper.activeItem = index
        stepLbl.text = "Шаг \(index) из 3"
        if(self.currentStep == 0){
            titleLbl.text = "Застрахованные лица"
            container!.segueIdentifierReceivedFromParent("firstStep")
            
        }
        if(self.currentStep == 1){
            NotificationCenter.default.post(name: Notification.Name("reloadRegion"), object: nil)
            titleLbl.text = "Страхователь"
            container!.segueIdentifierReceivedFromParent("secondStep")
        }
        if(self.currentStep == 2){
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reloadProgram"),object: nil))
            nextBtn.setTitle("Сохранить", for: .normal)
            titleLbl.text = "Данные о полисе"
            container!.segueIdentifierReceivedFromParent("stepThree")
        }else{
            nextBtn.setTitle("Продолжить", for: .normal)
        }
    }
    
    
}

extension MainMiteController:UIGestureRecognizerDelegate{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (navigationController?.viewControllers.count ?? 0) > 1
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

