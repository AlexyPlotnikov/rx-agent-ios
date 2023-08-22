//
//  InsurerController.swift
//  RXAgent
//
//  Created by RX Group on 23.03.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit

class InsurerController: UIViewController {

    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
        
        let tapGestureRecognizer = UITapGestureRecognizer()
            tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
            tapGestureRecognizer.cancelsTouchesInView=false
            self.view.addGestureRecognizer(tapGestureRecognizer)
        registerForKeyboardWillShowNotification(self.table)
        registerForKeyboardWillHideNotification(self.table, usingBlock: {_ in
            self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
        })
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadRegion),
                                               name: NSNotification.Name("reloadRegion"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCell(notification:)),
                                               name: NSNotification.Name("updateCell"),
                                               object: nil)
        
    }
    
    @objc func updateCell(notification:NSNotification){
        if let indexCell = notification.userInfo?["cell"] as? Int{
            
            switch indexCell {
            case 0:
                let indexPath = IndexPath(row: 1, section: 0)
                self.table.scrollToRow(at: indexPath, at: .top, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let cell = self.table.cellForRow(at: indexPath) as? InsurerCell{
                    cell.fioField.errorMessage = (notification.userInfo?["text"] as! String)
                }}
            case 2:
                let indexPath = IndexPath(row: 1, section: 0)
                self.table.scrollToRow(at: indexPath, at: .top, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let cell = self.table.cellForRow(at: indexPath) as? InsurerCell{
                    cell.dobField.errorMessage = (notification.userInfo?["text"] as! String)
                }
                }
            case 3:
                let indexPath = IndexPath(row: 2, section: 0)
                self.table.scrollToRow(at: indexPath, at: .top, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let cell = self.table.cellForRow(at: indexPath) as? InsurerCell{
                    cell.seriesPassField.errorMessage = (notification.userInfo?["text"] as! String)
                }}
            case 4:
                let indexPath = IndexPath(row: 2, section: 0)
                self.table.scrollToRow(at: indexPath, at: .top, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let cell = self.table.cellForRow(at: indexPath) as? InsurerCell{
                    cell.registratorField.errorMessage = (notification.userInfo?["text"] as! String)
                }}
            case 5:
                let indexPath = IndexPath(row: 2, section: 0)
                self.table.scrollToRow(at: indexPath, at: .top, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let cell = self.table.cellForRow(at: indexPath) as? InsurerCell{
                    cell.regDateField.errorMessage = (notification.userInfo?["text"] as! String)
                }}
            case 6:
                let indexPath = IndexPath(row: 3, section: 0)
                self.table.scrollToRow(at: indexPath, at: .top, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let cell = self.table.cellForRow(at: indexPath) as? InsurerCell{
                    cell.regionField.errorMessage = (notification.userInfo?["text"] as! String)
                }}
            case 7:
                let indexPath = IndexPath(row: 3, section: 0)
                self.table.scrollToRow(at: indexPath, at: .top, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let cell = self.table.cellForRow(at: indexPath) as? InsurerCell{
                    cell.cityField.errorMessage = (notification.userInfo?["text"] as! String)
                }}
            case 9:
                let indexPath = IndexPath(row: 3, section: 0)
                self.table.scrollToRow(at: indexPath, at: .top, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let cell = self.table.cellForRow(at: indexPath) as? InsurerCell{
                    cell.numberHouseField.errorMessage = (notification.userInfo?["text"] as! String)
                }}
            default:
                break
            }
            
            
        }
    }
    
    @objc func reloadRegion(){
        self.table.reloadData()
    }

    @objc func handleTap(){
        self.view.endEditing(true)
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
    
}



extension InsurerController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
         return 4
       
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0){
            let date = Calendar.current.date(byAdding: .year, value: -18, to: Date())
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "dd.MM.yyyy"
            let tempItems = MiteModel.sharedInstance().miteItem.items.filter({dateFormatterGet.date(from:$0.dob)!<=date!})
            if(tempItems.count > 0){
                return 72
            }else{
                return 0
            }
        }else if(indexPath.row == 1 || indexPath.row == 2){
            return 246
        }else{
            if(MiteModel.sharedInstance().miteItem.address == ""){
                return 88
            }else{
                return 467
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "insuredCell") as! InsurerCell
            
            return cell
        }
        if(indexPath.row == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "insurerInfoCell") as! InsurerCell
            if(MiteModel.sharedInstance().miteItem.fullName.count != 0){
                cell.fioField.text = MiteModel.sharedInstance().miteItem.fullName
                cell.fioField.setNeedsDisplay()
            }
            if(MiteModel.sharedInstance().miteItem.dob.count != 0){
                cell.dobField.text = MiteModel.sharedInstance().miteItem.dob
                cell.dobField.setNeedsDisplay()
            }
            cell.fioField.addToolBar()
            cell.phoneNumberField.addToolBar()
            cell.dobField.addToolBar()
            
            
            return cell
        }else if(indexPath.row == 2){
            let cell = tableView.dequeueReusableCell(withIdentifier: "passportCell") as! InsurerCell
            cell.seriesPassField.addToolBar()
            cell.registratorField.addToolBar()
            cell.regDateField.addToolBar()
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "regCell") as! InsurerCell
            if(MiteModel.sharedInstance().miteItem.address != ""){
                cell.regionField.errorMessage = nil
                cell.regionField.text = MiteModel.sharedInstance().miteItem.address
            }
            if(MiteModel.sharedInstance().adressName != ""){
                cell.regionField.errorMessage = nil
            }
                cell.cityField.text = MiteModel.sharedInstance().adressName
//            }
            cell.regionField.addToolBar()
            cell.cityField.addToolBar()
            cell.streetField.addToolBar()
            cell.numberHouseField.addToolBar()
            cell.housingField.addToolBar()
            cell.flatField.addToolBar()
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row==0){
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "insurerVC") as! InsurerNavigationController
            let presentationController = SheetModalPresentationController(presentedViewController: viewController,
                                                                                  presenting: self,
                                                                                  isDismissable: true)
            
            viewController.transitioningDelegate = presentationController
            viewController.modalPresentationStyle = .custom
         
            self.present(viewController, animated: true)
        }
    }
}


extension InsurerController:UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.mm.yyyy"
        var dict = [String:Any]()
        if(textField.tag == 0 && MiteModel.sharedInstance().miteItem.fullName.count < 1){
            dict["cell"] = 0
            dict["text"] = "Укажите ФИО"
        }else  if(textField.tag == 2 && MiteModel.sharedInstance().miteItem.dob.count < 10){
            dict["cell"] = 2
            dict["text"] = "Укажите дату рождения"
        }else  if(textField.tag == 2 && !validateDate(dateStr: MiteModel.sharedInstance().miteItem.dob)){
            dict["cell"] = 2
            dict["text"] = "Некорректная дата рождения"
        }else if(textField.tag == 2 && !self.checkDate(dateTemp: MiteModel.sharedInstance().miteItem.dob)){
            dict["cell"] = 2
            dict["text"] = "Дата рождения не может быть больше 100 лет"
        }else if(textField.tag == 2 && self.getYearDefferent(firstYear: MiteModel.sharedInstance().miteItem.dob, secondYear: dateFormatter.string(from: Date())) < 18){
            dict["cell"] = 2
            dict["text"] = "Страхователь должен быть совершеннолетним"
        }else if(textField.tag == 3 && MiteModel.sharedInstance().miteItem.passportSeries.count < 4){
            dict["cell"] = 3
            dict["text"] = "Укажите серию паспорта"
        }else if(textField.tag == 3 && MiteModel.sharedInstance().miteItem.passportNumber.count < 6){
            dict["cell"] = 3
            dict["text"] = "Укажите номер паспорта"
        }else if(textField.tag == 4 && MiteModel.sharedInstance().miteItem.passportRegistrator.count < 1){
            dict["cell"] = 4
            dict["text"] = "Укажите кем выдан паспорт"
        }else  if(textField.tag == 5 && MiteModel.sharedInstance().miteItem.passportDate.count < 10){
            dict["cell"] = 5
            dict["text"] = "Укажите дату выдачи паспорта"
        }else if(textField.tag == 5 && !validateDate(dateStr: MiteModel.sharedInstance().miteItem.passportDate)){
            dict["cell"] = 5
            dict["text"] = "Некорректная дата выдачи паспорта"
        }else if(textField.tag == 5 && !self.checkDate(dateTemp: MiteModel.sharedInstance().miteItem.passportDate)){
            dict["cell"] = 5
            dict["text"] = "Дата выдачи не может быть больше 100 лет"
        }else if(textField.tag == 5 && self.getYearDefferent(firstYear: MiteModel.sharedInstance().miteItem.dob, secondYear: MiteModel.sharedInstance().miteItem.passportDate) < 14){
            dict["cell"] = 5
            dict["text"] = "Некорректная дата выдачи паспорта"
        }else if(textField.tag == 6 && MiteModel.sharedInstance().miteItem.address.count < 1){
            dict["cell"] = 6
            dict["text"] = "Укажите регион"
        }else if(textField.tag == 7 && MiteModel.sharedInstance().adressName.count < 1){
            dict["cell"] = 7
            dict["text"] = "Укажите населенный пункт"
        }else if(textField.tag == 9 && MiteModel.sharedInstance().miteItem.house.count < 1){
            dict["cell"] = 9
            dict["text"] = "Укажите номер дома"
        }
        NotificationCenter.default.post(name: Notification.Name("updateCell"), object: nil,userInfo: dict)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        var newString = (text as NSString).replacingCharacters(in: range, with: string)
        
        if(textField.tag == 0){
            if(self.checkName(name: newString)){
                MiteModel.sharedInstance().miteItem.fullName = newString
                return true
            }else{
                return false
            }
            
        }
        if(textField.tag == 1){
            if(newString.hasPrefix("8")){
                newString = "7"
            }
            if(!newString.hasPrefix("7") && !newString.hasPrefix("+")){
                newString = "7" + newString
            }
            if(newString.count <= 18){
                MiteModel.sharedInstance().miteItem.phone = newString
            }
           
            textField.text = format(with: "+X (XXX) XXX XX XX", phone: newString)
            return false
        }
        if(textField.tag == 2){
            MiteModel.sharedInstance().miteItem.dob = newString
            if (textField.text?.count == 2) || (textField.text?.count == 5) {
                    if !(string == "") {
                        textField.text = (textField.text)! + "."
                    }
                }
            
    
                return !(textField.text!.count > 9 && (string.count ) > range.length)
        }
        
        if(textField.tag == 3){
            textField.text = format(with: "XXXX XXXXXX", phone: newString)
            if(newString.count<=4){
                MiteModel.sharedInstance().miteItem.passportSeries = newString
            }else{
                if(newString.count>11){
                    newString = String(newString.dropLast())
                }
                MiteModel.sharedInstance().miteItem.passportNumber = String(newString.dropFirst(5))
                
            }
            return false
        }
        
        if(textField.tag == 4){
            MiteModel.sharedInstance().miteItem.passportRegistrator = newString
        }
        if(textField.tag == 5){
            MiteModel.sharedInstance().miteItem.passportDate = newString
            if (textField.text?.count == 2) || (textField.text?.count == 5) {
                    if !(string == "") {
                        textField.text = (textField.text)! + "."
                    }
            }
            return !(textField.text!.count > 9 && (string.count ) > range.length)
        }
        
        if(textField.tag == 8){
            MiteModel.sharedInstance().miteItem.street = newString
        }
        
        if(textField.tag == 9){
            MiteModel.sharedInstance().miteItem.house = newString
        }
        
        if(textField.tag == 10){
            MiteModel.sharedInstance().miteItem.housing = newString
        }
        
        if(textField.tag == 11){
            MiteModel.sharedInstance().miteItem.flat = newString
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField.tag == 6){
            textField.resignFirstResponder()
            self.view.endEditing(true)
            isRegion = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "detailVC") as! DetailController
                viewController.isMite = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        if(textField.tag == 7){
            textField.resignFirstResponder()
            self.view.endEditing(true)
            isRegion = false
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "detailVC") as! DetailController
                viewController.isMite = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    
    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex
        
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                result.append(numbers[index])
                index = numbers.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
    
    func checkName(name:String)->Bool{
        let allowedCharacters = "ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЁЯЧСМИТЬБЮйцукенгшщзхъфывапролджэёячсмитьбю -."
        let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
        let typedCharacterSet = CharacterSet(charactersIn: name)
       
        return allowedCharacterSet.isSuperset(of: typedCharacterSet)
    }
}
