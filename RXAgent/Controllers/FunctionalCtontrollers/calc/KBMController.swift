//
//  KBMController.swift
//  RXAgent
//
//  Created by RX Group on 29.05.2020.
//  Copyright © 2020 RX Group. All rights reserved.
//

import UIKit

class KBMController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var getKBM: UIButton!
    @IBOutlet weak var table: UITableView!
    var nullField:UITextField!
    var KBMDriverIndex:Int = 0
    @IBOutlet weak var driverTitle: UILabel!
    enum TypeDate: Int {
        case birthDayDriver = 0
        case startDriver = 1
    }
    var currentType:TypeDate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        driverTitle.text = "Водитель №\(KBMDriverIndex+1)"
        self.table.tableFooterView = UIView()
        
        let tapGestureRecognizer = UITapGestureRecognizer()
           tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
           tapGestureRecognizer.cancelsTouchesInView=false
           self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTap(){
        self.checkAvilable()
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row==0){
            let cellReuseIdentifier = "Cell"
            let cell:KBMCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! KBMCell
                cell.textfield.placeholder = "ФИО Водителя"
                cell.textfield.tag = 0
                cell.textfield.delegate = self
                cell.textfield.autocapitalizationType = .words
                cell.textfield.returnKeyType = .done
                
            return cell
        }else if(indexPath.row==1){
            let cellReuseIdentifier = "celltype"
            let cell:KBMCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! KBMCell
                cell.subtitleLbl.text = "Дата рождения"
                cell.titleLbl.text = (driversArray[KBMDriverIndex] as! DriverModel).birthDayDate
            
            return cell
        }else if(indexPath.row==2){
            let cellReuseIdentifier = "Cell"
            let cell:KBMCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! KBMCell
                cell.textfield.delegate = self
                cell.textfield.placeholder = "Серия ВУ"
                cell.textfield.tag = 1
                cell.textfield.autocapitalizationType = .allCharacters
                cell.textfield.returnKeyType = .done
            return cell
        }else if(indexPath.row==3){
            let cellReuseIdentifier = "Cell"
            let cell:KBMCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! KBMCell
                cell.textfield.delegate = self
                cell.textfield.placeholder = "Номер ВУ"
                cell.textfield.tag = 2
                cell.textfield.autocapitalizationType = .allCharacters
                cell.textfield.returnKeyType = .done
            return cell
        }else{
            let cellReuseIdentifier = "celltype"
            let cell:KBMCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! KBMCell
                cell.subtitleLbl.text = "Дата начала стажа"
                cell.titleLbl.text = (driversArray[KBMDriverIndex] as! DriverModel).startTimeDate
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 1){
            currentType = TypeDate(rawValue: 0)
            self.showDataPicker()
        }else if(indexPath.row == 4){
            currentType = TypeDate(rawValue: 1)
            self.showDataPicker()
        }
    }
    
    func showDataPicker() {
        let datePickerView = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        } 
            datePickerView.datePickerMode = .date
            datePickerView.locale = NSLocale.init(localeIdentifier: "ru") as Locale
            datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
            datePickerView.tag = KBMDriverIndex
            nullField = UITextField(frame: .zero)
            nullField.spellCheckingType = .no
       
        let toolbar = UIToolbar()
              toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: UIBarButtonItem.Style.done, target: self, action: #selector(checkAvilable))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
             
              
              toolbar.setItems([spaceButton,doneButton], animated: false)
              nullField.inputAccessoryView = toolbar
              nullField.inputView = datePickerView
              nullField.becomeFirstResponder()
              self.view.addSubview(nullField)
        switch currentType {
        case .birthDayDriver:
               datePickerView.date = (Calendar.current.date(byAdding: .year, value: -18, to: Date())!)
               datePickerView.maximumDate = (Calendar.current.date(byAdding: .year, value: -18, to: Date())!)
               nullField.delegate = self
        case .startDriver:
               datePickerView.maximumDate = (Calendar.current.date(byAdding: .day, value: 0, to: Date())!)
               nullField.delegate = self
        case .none:
              print("NONE")
        }
       
       
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.init(localeIdentifier: "ru") as Locale
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "YYYY-MM-dd"
        
        switch currentType {
        case .birthDayDriver:
            var tempDriver = (driversArray[KBMDriverIndex] as! DriverModel)
            tempDriver.birthDayDate = dateFormatter.string(from: datePickerView.date)
            tempDriver.birthSendDate = dateFormatter2.string(from: datePickerView.date)
            driversArray[KBMDriverIndex]  = tempDriver
            self.table.reloadData()
        case .startDriver:
            var tempDriver = (driversArray[KBMDriverIndex] as! DriverModel)
            tempDriver.startTimeDate = dateFormatter.string(from: datePickerView.date)
            tempDriver.startSendDate = dateFormatter2.string(from: datePickerView.date)
            driversArray[KBMDriverIndex]  = tempDriver
            self.table.reloadData()
        case .none:
            print("NONE")
        }
        
    }
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.init(localeIdentifier: "ru") as Locale
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "YYYY-MM-dd"
        switch currentType {
        case .birthDayDriver:
            var tempDriver = (driversArray[KBMDriverIndex] as! DriverModel)
            tempDriver.birthDayDate = dateFormatter.string(from: sender.date)
            tempDriver.birthSendDate = dateFormatter2.string(from: sender.date)
            driversArray[KBMDriverIndex]  = tempDriver
        case . startDriver:
            var tempDriver = (driversArray[KBMDriverIndex] as! DriverModel)
            tempDriver.startTimeDate = dateFormatter.string(from: sender.date)
            tempDriver.startSendDate = dateFormatter2.string(from: sender.date)
            driversArray[KBMDriverIndex]  = tempDriver
        case .none:
            print("NONE")
        }
        table.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.checkAvilable()
        
        return true
    }
//    var nameDriver:String = ""
//         var serialDriver:String = ""
//         var numberDriver:String = ""
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField.tag == 0){
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            var tempDriver = (driversArray[KBMDriverIndex] as! DriverModel)
            tempDriver.nameDriver = updatedText
            driversArray[KBMDriverIndex]  = tempDriver
            return updatedText.count <= 100
        }else if(textField.tag == 1){
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            var tempDriver = (driversArray[KBMDriverIndex] as! DriverModel)
            tempDriver.serialDriver = updatedText
            driversArray[KBMDriverIndex]  = tempDriver
            return updatedText.count <= 4
        }else{
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            var tempDriver = (driversArray[KBMDriverIndex] as! DriverModel)
            tempDriver.numberDriver = updatedText
            driversArray[KBMDriverIndex]  = tempDriver
            return updatedText.count <= 6
        }
    }
    
    @objc func checkAvilable(){
        self.view.endEditing(true)
        var tempDriver = (driversArray[KBMDriverIndex] as! DriverModel)
        if(tempDriver.KBC == 10000.0){
            if(tempDriver.birthDayDate != "Не указано" && tempDriver.startTimeDate != "Не указано"){
                let birthValue = Date().years(from:convertToDate(string: tempDriver.birthSendDate))
                let startValue = Date().years(from:convertToDate(string: tempDriver.startSendDate))
                    getPatchRequest(URLString: "\(domain)v0/EOSAGOPolicies/kbc/\(birthValue)/\(startValue)", completion: {
                            result in
                            tempDriver.KBC = result["kbc"] as! Double
                            driversArray[self.KBMDriverIndex] = tempDriver
                        DispatchQueue.main.async {
                                if(tempDriver.KBC != 10000.0 && !tempDriver.serialDriver.isEmpty && !tempDriver.numberDriver.isEmpty && !tempDriver.nameDriver.isEmpty){
                                    self.getKBM.isEnabled = true
                                }else{
                                    self.getKBM.isEnabled = false
                                }
                        }
                        
                        
                            
                    })
                }
        }else{
            if(tempDriver.KBC != 10000.0 && !tempDriver.serialDriver.isEmpty && !tempDriver.numberDriver.isEmpty && !tempDriver.nameDriver.isEmpty){
                self.getKBM.isEnabled = true
            }else{
                self.getKBM.isEnabled = false
            }
        }
    }
    
    @IBAction func getKBMPost(_ sender: Any) {

        var tempDriver = (driversArray[KBMDriverIndex] as! DriverModel)
        let dict = [
            "isIndividual": "true",
            "date": "\(tempDriver.startSendDate)",
            "unlimited": "true",
            "fullName":"\(tempDriver.nameDriver)",
            "dateOfBirth":"\(tempDriver.birthSendDate)",
            "series":"\(tempDriver.serialDriver)",
            "number":"\(tempDriver.numberDriver)"
            ] as [String:Any]
        postRequest(JSON: dict, URLString: "\(domain)v0/KBM", completion: {
            result in
            DispatchQueue.main.async {
               let kbm = ((result["kbm"] as! [String:Any])["kbm"] as! NSNumber).doubleValue
                   tempDriver.kbm = "\(kbm)"
                   driversArray[self.KBMDriverIndex] = tempDriver
                    NotificationCenter.default.post(name: Notification.Name("reloadDriver"), object: nil)
                   self.navigationController?.popViewController(animated: true)
                  
            }
           
         })
    }
    
    func convertToDate(string:String)->Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from:string)!
    }
}
