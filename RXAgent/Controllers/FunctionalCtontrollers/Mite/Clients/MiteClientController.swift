//
//  MiteClientController.swift
//  RXAgent
//
//  Created by RX Group on 18.02.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit

class MiteClientController: UIViewController {
    
    @IBOutlet weak var headerBody: UIView!
    @IBOutlet weak var costPolicelbl: UILabel!
    @IBOutlet weak var table: UITableView!
    var activeTextField:YVTextField!
    var isGenerate:Bool = true
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerBody.layer.cornerRadius = 12
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        self.countClients(count: 0)
        let tapGestureRecognizer = UITapGestureRecognizer()
            tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
            tapGestureRecognizer.cancelsTouchesInView=false
            self.view.addGestureRecognizer(tapGestureRecognizer)
       
        registerForKeyboardWillHideNotification(self.table,usingBlock: {
            result in
            self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
        })
        registerForKeyboardWillShowNotification(self.table)
        
    }
    
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
    func countClients(count:Int){
        getRequest(URLString: domain + "v0/MitePolicies/calc?program=2&items=\(count)", completion: {
            result in
            DispatchQueue.main.async {
             
                self.costPolicelbl.text = "\((result["result"] as? [String:Any] ?? [:])["costClient"] as? Int ?? 0) ₽"
            }
        })
    }
    
    @objc func addClient(){
        if(MiteModel.sharedInstance().tempMite.fullName.count < 1){
            self.setErrorMessage(isName: true,text: "Укажите ФИО")
        }
       
       
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
        if(MiteModel.sharedInstance().tempMite.dob.count == 11){
            MiteModel.sharedInstance().tempMite.dob.removeLast()
        }
       
        if let date = dateFormatter.date(from:MiteModel.sharedInstance().tempMite.dob) {
                if(date <= Date()){
                    if(MiteModel.sharedInstance().tempMite.dob.count < 10){
                        self.setErrorMessage(isName: false,text: "Укажите дату рождения")
                    }else{
                        //Добавление клиента в массив
                        if(!self.checkDate(dateTemp: MiteModel.sharedInstance().tempMite.dob)){
                            self.setErrorMessage(isName: false,text: "Дата рождения не может быть больше 100 лет")
                            return
                        }
                        if(MiteModel.sharedInstance().tempMite.fullName.count < 1){
                            self.setErrorMessage(isName: true,text: "Укажите ФИО")
                        }else{
                            if (MiteModel.sharedInstance().miteItem.items.contains(where: {$0.fullName.replacingOccurrences(of: " ", with: "") == MiteModel.sharedInstance().tempMite.fullName.replacingOccurrences(of: " ", with: "") })) {
                                self.setErrorMessage(isName: true,text: "Застрахованный с таким ФИО уже есть")
                            }else{
                                var newWord = ""
                                for word in MiteModel.sharedInstance().tempMite.fullName{
                                    if(word != " " && word != "."){
                                        newWord = newWord + "\(word)"
                                    }
                                }
                                if newWord.isEmpty {
                                    self.setErrorMessage(isName: true,text: "Укажите ФИО")
                                }else{
                                    self.newClient()
                                }
                                
                            }
                        }
                    }
                }else{
                    self.setErrorMessage(isName: false,text: "Некорректная дата рождения")
                }
                
            } else {
                self.setErrorMessage(isName: false,text: "Укажите дату рождения")
            }
    }
    
    
    @objc func addNewClient(){
        isGenerate = true
        self.table.scrollToBottomRow()
        self.table.reloadData()
    }
    
    func setErrorMessage(isName:Bool,text:String){
        let index = MiteModel.sharedInstance().miteItem.items.count
        let cell = self.table.cellForRow(at: IndexPath(row: index, section: 0)) as! MiteClientCell
        if(isName){
            cell.fullNameField.errorMessage = text
        }else{
            cell.dobField.errorMessage = text
        }
    }
    
    func newClient(){
        isGenerate = false
        MiteModel.sharedInstance().miteItem.items.append(MiteModel.sharedInstance().tempMite)
        self.table.scrollToBottomRow()
        self.table.reloadData()
        self.countClients(count: MiteModel.sharedInstance().miteItem.items.count)
        MiteModel.sharedInstance().tempMite = ClientMite(fullName: "", dob: "")
    }
    
    @objc func removeClient(index:UIButton){
        MiteModel.sharedInstance().miteItem.items.remove(at: index.tag)
        if(MiteModel.sharedInstance().miteItem.items.count == 0){
            isGenerate = true
        }
        self.table.reloadData()
        self.countClients(count: MiteModel.sharedInstance().miteItem.items.count)
        
    }
    
    
    @objc func removeCreate(){
        MiteModel.sharedInstance().tempMite = ClientMite(fullName: "", dob: "")
        isGenerate = false
        self.table.reloadData()
    }
}


extension MiteClientController:UITableViewDelegate,UITableViewDataSource{
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MiteModel.sharedInstance().miteItem.items.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == MiteModel.sharedInstance().miteItem.items.count){
            if(isGenerate){
                return 245
            }else{
                return 62
            }
        }else{
            return 87
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == MiteModel.sharedInstance().miteItem.items.count){
            if(isGenerate){
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellAdd", for: indexPath) as! MiteClientCell
                print("123")
                cell.fullNameField.text = ""
                cell.dobField.text = ""
                cell.fullNameField.setNeedsDisplay()
                cell.dobField.setNeedsDisplay()
                cell.fullNameField.addToolBar()
                cell.dobField.addToolBar()
                cell.addBtn.addTarget(self, action: #selector(addClient), for: .touchUpInside)
                cell.fullNameField.delegate = self
                cell.dobField.delegate = self
                cell.fullNameField.tag = 0
                cell.dobField.tag = 1
                cell.removeBtnCreate.isHidden = MiteModel.sharedInstance().miteItem.items.count == 0
                cell.removeBtnCreate.addTarget(self, action: #selector(removeCreate), for: .touchUpInside)
                
                return cell
            }else{
                //кнопка добавить
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellAddBtn", for: indexPath) as! MiteClientCell
                cell.addNewClient.addTarget(self, action: #selector(addNewClient), for: .touchUpInside)
                
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellReady", for: indexPath) as! MiteClientCell
            cell.clientNameLbl.text = MiteModel.sharedInstance().miteItem.items[indexPath.row].fullName
            cell.clientDobLbl.text = MiteModel.sharedInstance().miteItem.items[indexPath.row].dob
            cell.removeBtnReady.tag = indexPath.row
            cell.removeBtnReady.addTarget(self, action: #selector(removeClient(index:)), for: .touchUpInside)
            return cell
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
    
}

extension MiteClientController:UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = (textField as! YVTextField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField.tag == 0){
            if(MiteModel.sharedInstance().tempMite.fullName.count < 1){
                self.setErrorMessage(isName: true,text: "Укажите ФИО")
            }
            if(MiteModel.sharedInstance().tempMite.fullName.count < 1){
                self.setErrorMessage(isName: true,text: "Укажите ФИО")
            }else{
                if(MiteModel.sharedInstance().miteItem.items.contains(where: {$0.fullName.replacingOccurrences(of: " ", with: "") == MiteModel.sharedInstance().tempMite.fullName.replacingOccurrences(of: " ", with: "") })) {
                    self.setErrorMessage(isName: true,text: "Застрахованный с таким ФИО уже есть")
                }
            }
        }else if(textField.tag == 1){
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
        if(MiteModel.sharedInstance().tempMite.dob.count == 11){
            MiteModel.sharedInstance().tempMite.dob.removeLast()
        }
       
        if let date = dateFormatter.date(from:MiteModel.sharedInstance().tempMite.dob) {
                if(date <= Date()){
                    if(MiteModel.sharedInstance().tempMite.dob.count < 10){
                        self.setErrorMessage(isName: false,text: "Укажите дату рождения")
                    }else{
                        //Добавление клиента в массив
                        if(!self.checkDate(dateTemp: MiteModel.sharedInstance().tempMite.dob)){
                            self.setErrorMessage(isName: false,text: "Дата рождения не может быть больше 100 лет")
                            return
                        }
                    }
                }else{
                    self.setErrorMessage(isName: false,text: "Некорректная дата рождения")
                }
                
            } else {
                self.setErrorMessage(isName: false,text: "Укажите дату рождения")
            }
        }
        
        
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
//        let rangeNew = updatedText.rangeOfCharacter(from: .whitespaces)
//           if ((textField.text?.count)! == 0 && rangeNew  != nil)
//           || ((textField.text?.count)! > 0 && textField.text?.last  == "  " && rangeNew != nil)  {
//               return false
//           }
        
        if textField.tag == 0 {
            if(self.checkName(name: updatedText)){
                MiteModel.sharedInstance().tempMite.fullName = updatedText
               
                return true
            }else{
                return false
            }
            
        }
        
        
        if textField.tag == 1 {
            MiteModel.sharedInstance().tempMite.dob = updatedText
            
            if (textField.text?.count == 2) || (textField.text?.count == 5) {
                    if !(string == "") {
                        textField.text = (textField.text)! + "."
                    }
                }
            
    
                return !(textField.text!.count > 9 && (string.count ) > range.length)
            }
            else {
                return true
            }
    }
    
    func checkName(name:String)->Bool{
        let allowedCharacters = "ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЁЯЧСМИТЬБЮйцукенгшщзхъфывапролджэёячсмитьбю -."
        let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
        let typedCharacterSet = CharacterSet(charactersIn: name)
       
        return allowedCharacterSet.isSuperset(of: typedCharacterSet)
    }
   
}

extension UITableView {
    func scrollToBottomRow() {
        DispatchQueue.main.async {
            guard self.numberOfSections > 0 else { return }

            // Make an attempt to use the bottom-most section with at least one row
            var section = max(self.numberOfSections - 1, 0)
            var row = max(self.numberOfRows(inSection: section) - 1, 0)
            var indexPath = IndexPath(row: row, section: section)

            // Ensure the index path is valid, otherwise use the section above (sections can
            // contain 0 rows which leads to an invalid index path)
            while !self.indexPathIsValid(indexPath) {
                section = max(section - 1, 0)
                row = max(self.numberOfRows(inSection: section) - 1, 0)
                indexPath = IndexPath(row: row, section: section)

                // If we're down to the last section, attempt to use the first row
                if indexPath.section == 0 {
                    indexPath = IndexPath(row: 0, section: 0)
                    break
                }
            }

            // In the case that [0, 0] is valid (perhaps no data source?), ensure we don't encounter an
            // exception here
            guard self.indexPathIsValid(indexPath) else { return }

            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    func indexPathIsValid(_ indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        return section < self.numberOfSections && row < self.numberOfRows(inSection: section)
    }
}


extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

//    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
//        return calendar.component(component, from: self)
//    }
}
