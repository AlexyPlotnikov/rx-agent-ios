//
//  PropertyController.swift
//  RXAgent
//
//  Created by RX Group on 19/08/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit
import SwiftUI


class PropertyController: UIViewController{
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
    var containerViewController: MainOsagoController?
    var isEdit = false
    var titleArray:[String] = ["Дата и период", "Данные страхователя", "Ваши данные", "Комментарий"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.scrollToRow(at: IndexPath(row: 0, section: 0) as IndexPath, at: .top, animated: true)
        getDataMethod(key: "InsurancePeriods",getKey: "insurancePeriods", completion:{
            result in
            periodArray = result
        })
        sendBtn.isHidden = !isEdit
        
        if(propertyDateStart.isEmpty && dateStartForTable.isEmpty){
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.init(localeIdentifier: "ru") as Locale
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        propertyDateStart = dateFormatter.string(from: self.calculateNewDate())
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "YYYY-MM-dd"
        
        dateStartForTable = dateFormatter2.string(from: self.calculateNewDate())
        }
        
        self.table.tableFooterView = UIView()
        self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        
        self.registerEvents()
    }
    
    func registerEvents(){
        
        registerForKeyboardWillShowNotification(self.table)
        registerForKeyboardWillHideNotification(self.table, usingBlock: {_ in
            self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        })

        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
        tapGestureRecognizer.cancelsTouchesInView=false
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
    func drawEmptyPhotos()->Bool{
       
        if(fullNameInsurance.count < 1){
            setMessage("Необходимо заполнить фамилию страхователя")
            return false
        }
        if(phoneInsurance.count > 1){
            if(phoneInsurance.hasPrefix("7")){
                if(!phoneInsurance.hasPrefix("79")){
                    setMessage("Некорректный номер страхователя")
                    return false
                }
            }else{
                if(!phoneInsurance.hasPrefix("9")){
                    setMessage("Некорректный номер страхователя")
                    return false
                }
            }
        }else{
            setMessage("Номер страхователя не заполнен")
            return false
        }
        
        if(creatorInsurance.count < 1){
            setMessage("Необходимо заполнить ваше имя")
            return false
        }
        
        if(creatorPhone.count > 1){
            if(creatorPhone.hasPrefix("7")){
                if(!creatorPhone.hasPrefix("79")){
                    setMessage("Ваш номер телефона некорректный")
                    return false
                }
            }else{
                if(!creatorPhone.hasPrefix("9")){
                    setMessage("Ваш номер телефона некорректный")
                    return false
                }
            }
        }else{
            setMessage("Ваш номер телефона не заполнен")
            return false
        }
       
        return propertyIsFull()
    }
    
    @IBAction func sendEditServer(_ sender: Any) {
        if(self.drawEmptyPhotos()){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "offerVC") as! OfferController
            viewController.isEdit = true
            self.present(viewController, animated: true)
        }else{
            self.setMessage("Заполнены не все поля")
        }
    }
    
    func setMessage(_ text:String) {
        DispatchQueue.main.async{
            let alertController = UIAlertController(title: "Внимание!", message:
                text , preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
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
}

//MARK: инпут textView
extension PropertyController:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColorFromRGB(rgbValue: 0xADADAD, alphaValue: 1) {
            textView.text = nil
            textView.textColor = UIColor.black
            
        }
        self.table.scrollToRow(at: IndexPath(row: 0, section: 3), at: .bottom, animated: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Введите комментарий"
            textView.textColor = UIColorFromRGB(rgbValue: 0xADADAD, alphaValue: 1)
        }
       
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        commentAgent = textView.text + text
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

//MARK: пикеры
extension PropertyController:UIPickerViewDelegate, UIPickerViewDataSource{
    
    func showDataPicker(textField:UITextField) {
            let datePickerView = UIDatePicker()
            datePickerView.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        }
            datePickerView.minimumDate = (Calendar.current.date(byAdding: .day, value: 4, to: Date())!)
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "YYYY-MM-dd"
            datePickerView.date = dateFormatter2.date(from: dateStartForTable)!
            datePickerView.maximumDate = (Calendar.current.date(byAdding: .day, value: 60, to: Date())!)
            datePickerView.locale = NSLocale.init(localeIdentifier: "ru") as Locale
    
            textField.addToolBar()
            textField.inputView = datePickerView
        
            datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)

        }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.init(localeIdentifier: "ru") as Locale
        dateFormatter.dateFormat = "dd MMMM yyyy"

        propertyDateStart = dateFormatter.string(from: sender.date)

        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "YYYY-MM-dd"

        dateStartForTable = dateFormatter2.string(from: sender.date)
        if let cell = self.table.cellForRow(at: IndexPath(row: 0, section: 0)) as? PropertyCell{
            cell.textField.text = propertyDateStart
        }

    }
    
    func showPicker(_ string: String){
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 200)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 200))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(tempIndexPeriod, inComponent: 0, animated: true)
        vc.view.addSubview(pickerView)
        let editRadiusAlert = UIAlertController(title: string, message: "", preferredStyle: .alert)
        editRadiusAlert.setValue(vc, forKey: "contentViewController")
        editRadiusAlert.addAction(UIAlertAction(title: "Готово", style: .default, handler: {_ in
            let period = periodArray[tempIndexPeriod] as! [String:Any]
            periodTitle = "\(period["title"] as! String)"
            periodID = period["id"] as! Int
            self.table.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            self.registerEvents()
        }))
        editRadiusAlert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        self.present(editRadiusAlert, animated: true)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            tempIndexPeriod = row
            let period = periodArray[row] as! [String:Any]
            periodTitle = "\(period["title"] as! String)"
            periodID = period["id"] as! Int
        
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let period = periodArray[row] as! [String:Any]
        periodTitle = "\(period["title"] as! String)"
        periodID = period["id"] as! Int
        
        return periodTitle
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return periodArray.count
    }
}

//MARK: Инпуты textField
extension PropertyController:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField.tag == 10){
            self.showDataPicker(textField: textField)
        }
        
        if(textField.tag == 11){
            //textField.resignFirstResponder()
            self.showPicker("Период стархования")
        }
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        var updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        let positionOriginal = textField.beginningOfDocument
        let cursorLocation = textField.position(from: positionOriginal, offset: (range.location + NSString(string: string).length))
        
        if(textField.tag == 20){
            let allowedCharacters = CharacterSet(charactersIn:"АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЬЫЪЧШЩЭЮЯабвгдеёжзийклмнопрстуфхцчшщьыъэюяABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ").inverted
            let components = string.components(separatedBy: allowedCharacters)
            let filtered = components.joined(separator: "")
              
            if string == filtered {
                fullNameInsurance = updatedText
                return true
            }else{
                return false
            }
        }
        if(textField.tag == 21){
            
            
            if(updatedText.hasPrefix("8")){
                updatedText = "7"
            }
            if(!updatedText.hasPrefix("7") && !updatedText.hasPrefix("+")){
                updatedText = "7" + updatedText
            }
            if(updatedText.count <= 18){
                phoneInsurance = updatedText
                if(phoneInsurance.hasPrefix("7")){
                    phoneInsurance.remove(at: phoneInsurance.startIndex)
                }
                phoneInsurance = phoneInsurance.replacingOccurrences(of: "+", with: "")
                phoneInsurance = phoneInsurance.replacingOccurrences(of: " ", with: "")
                phoneInsurance = phoneInsurance.replacingOccurrences(of: "(", with: "")
                phoneInsurance = phoneInsurance.replacingOccurrences(of: ")", with: "")

            }
           
           
           
            textField.text = format(with: "+X (XXX) XXX XX XX", phone: updatedText)
            if let cursorLoc = cursorLocation {
                    textField.selectedTextRange = textField.textRange(from: cursorLoc, to: cursorLoc)
                }
           
           return false
        }
        
        if(textField.tag == 30){
            let allowedCharacters = CharacterSet(charactersIn:"АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЬЫЪЧШЩЭЮЯабвгдеёжзийклмнопрстуфхцчшщьыъэюяABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ").inverted
            let components = string.components(separatedBy: allowedCharacters)
            let filtered = components.joined(separator: "")
              
            if string == filtered {
                creatorInsurance = updatedText
                return true
            }else{
                return false
            }
            
        }
        if(textField.tag == 31){
            if(updatedText.hasPrefix("8")){
                updatedText = "7"
            }
            if(!updatedText.hasPrefix("7") && !updatedText.hasPrefix("+")){
                updatedText = "7" + updatedText
            }
            if(updatedText.count <= 18){
                creatorPhone = updatedText
                if(creatorPhone.hasPrefix("7")){
                    creatorPhone.remove(at: creatorPhone.startIndex)
                }
                creatorPhone = creatorPhone.replacingOccurrences(of: "+", with: "")
                creatorPhone = creatorPhone.replacingOccurrences(of: " ", with: "")
                creatorPhone = creatorPhone.replacingOccurrences(of: "(", with: "")
                creatorPhone = creatorPhone.replacingOccurrences(of: ")", with: "")
            }
           
            textField.text = format(with: "+X (XXX) XXX XX XX", phone: updatedText)
            if let cursorLoc = cursorLocation {
                    textField.selectedTextRange = textField.textRange(from: cursorLoc, to: cursorLoc)
                }
            return false
            
        }
        
        
        return true
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
     
        return true
    }
}

//MARK: Таблица
extension PropertyController:UITableViewDelegate,UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleArray[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section != titleArray.count - 1){
            return 2
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section != titleArray.count - 1){
             return 72
        }else{
             return 100
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            let cellReuseIdentifier = "cellField"
            let cell:PropertyCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! PropertyCell
    
                cell.textField.smallPlaceholderText = propertySubtitle[indexPath.section][indexPath.row]
                cell.textField.text = (indexPath.row == 0 ? propertyDateStart:periodTitle)
                cell.textField.tag = indexPath.row == 0 ? 10:11
                cell.textField.delegate = self
            
            return cell
        }else if(indexPath.section == 1){
            
            let cellReuseIdentifier = "cellInsurance"
            let cell:PropertyCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! PropertyCell
                cell.textField.tag = indexPath.row == 0 ? 20:21
            if(!phoneInsurance.hasPrefix("7")){
                phoneInsurance = "7" + phoneInsurance
            }
                cell.textField.text = indexPath.row == 0 ? fullNameInsurance:format(with: "+X (XXX) XXX XX XX", phone: phoneInsurance)
                cell.textField.addToolBar()
                cell.textField.keyboardType = indexPath.row == 0 ? .default:.numberPad
                cell.textField.placeholder = propertySubtitle[indexPath.section][indexPath.row]
                cell.textField.smallPlaceholderText = propertySubtitle[indexPath.section][indexPath.row]
                cell.textField.delegate = self
            
            return cell
        } else if(indexPath.section == 2){
            let cellReuseIdentifier = "cellClient"
            let cell:PropertyCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! PropertyCell
                cell.textField.tag = indexPath.row == 0 ? 30:31
            if(!creatorPhone.hasPrefix("7")){
                creatorPhone = "7" + creatorPhone
            }
                cell.textField.text = indexPath.row == 0 ? creatorInsurance:format(with: "+X (XXX) XXX XX XX", phone: creatorPhone)
            
                cell.textField.addToolBar()
                cell.textField.keyboardType = indexPath.row == 0 ? .default:.numberPad
                cell.textField.placeholder = propertySubtitle[indexPath.section][indexPath.row]
                cell.textField.smallPlaceholderText = propertySubtitle[indexPath.section][indexPath.row]
                cell.textField.delegate = self
           
                
            return cell
        }else{
            let cellReuseIdentifier = "commentCell"
            let cell:PropertyCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! PropertyCell
            
            if(commentAgent.isEmpty){
                cell.commentView.text = "Введите комментарий"
                cell.commentView.textColor = UIColorFromRGB(rgbValue: 0xADADAD, alphaValue: 1)
            }else{
                cell.commentView.text = commentAgent
                cell.commentView.textColor = UIColor.black
            }
            cell.commentView.delegate = self
            return cell
        }
    }
    
}


extension UITableView {

    func isCellVisible(section:Int, row: Int) -> Bool {
        guard let indexes = self.indexPathsForVisibleRows else {
            return false
        }
        return indexes.contains {$0.section == section && $0.row == row }
    }  }


extension String {
    func applyPatternOnNumbers(pattern: String, replacmentCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: self)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacmentCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
}
