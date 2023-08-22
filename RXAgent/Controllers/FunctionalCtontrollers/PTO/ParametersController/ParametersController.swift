//
//  ParametersController.swift
//  RXAgent
//
//  Created by RX Group on 15.07.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import UIKit

class ParametersController: UIViewController {
    
    struct Settings{
        var placeholder:String!
        var subtitle:String!
    }
    struct Parameters {
        var name:String = ""
        var phone:String = ""
        var mark:String = ""
        var gosnumber:String = ""
        var comment:String = ""
        
        var paramReady:Bool{
            return name != "" && phone != "" && phone.count == 17 && mark != "" && gosnumber != ""
        }
    }
    
    var settings = [Settings(placeholder: "Введите имя", subtitle: "Имя клиента"), Settings(placeholder: "Введите номер телефона", subtitle: "Номер телефона клиента"), Settings(placeholder: "Укажите марку и модель автомобиля", subtitle: "Марка и модель"), Settings(placeholder: "Укажите госномер", subtitle: "Госномер"),Settings(placeholder: nil, subtitle: nil)]

    @IBOutlet weak var table: UITableView!
    var parameters = Parameters()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardWillShowNotification(table)
        registerForKeyboardWillHideNotification(table)
    }
    
    func addToolBarTextfield(textField:UITextField){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: UIBarButtonItem.Style.done, target: self, action: #selector(handleTap))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spaceButton,doneButton], animated: false)
        textField.inputAccessoryView = toolbar
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
   
    
}

extension ParametersController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(settings[indexPath.row].placeholder != nil){
            return 72
        }else{
            return 140
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(settings[indexPath.row].placeholder != nil){
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ParammetersCell
            
            cell.textFieldView.placeholder = settings[indexPath.row].placeholder
            cell.textFieldView.textField.delegate = self
            cell.textFieldView.textField.tag = indexPath.row
            self.addToolBarTextfield(textField: cell.textFieldView.textField)
            if(indexPath.row == 1){
                cell.textFieldView.textField.keyboardType = .numberPad
            }else{
                cell.textFieldView.textField.keyboardType = .default
            }
            
            if(indexPath.row == 0){
                cell.textFieldView.textField.autocapitalizationType = .words
            }else{
                cell.textFieldView.textField.autocapitalizationType = .allCharacters
            }
            cell.textFieldView.subtitleText = settings[indexPath.row].subtitle
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellComment", for: indexPath) as! ParammetersCell
            
            cell.commentTextView.delegate = self
            cell.commentTextView.returnKeyType = .done
            return cell
        }
        
        
    }
}

extension ParametersController: UITextFieldDelegate{
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        var newString = (text as NSString).replacingCharacters(in: range, with: string)
        if(textField.tag == 0){
            parameters.name = newString
        }
       
        if(textField.tag == 1){
            if(newString.hasPrefix("8")){
                newString = "7"
            }
            if(!newString.hasPrefix("7") && !newString.hasPrefix("+")){
                newString = "7" + newString
            }
            if(newString.count <= 17){
                parameters.phone = newString
            }
                print(parameters.phone)
                textField.text = format(with: "+X (XXX) XXX-XXXX", phone: newString)
                return false
        }
        if(textField.tag == 2){
            parameters.mark = newString
        }
        if(textField.tag == 3){
                if(self.isValidPassword(newString)){
                    parameters.gosnumber = newString
                }else{
                    return false
                }

        }
       
        return true
    }
    
     func isValidPassword(_ input: String) -> Bool {
                let passwordRegex = "[A-Za-z0-9АВЕКМНОРСТУХавекмнорстух]{0,9}$"
                return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: input)
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
}


extension ParametersController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
                textView.text = nil
                textView.textColor = UIColor.black
            }
        let indexPath = IndexPath(row: self.settings.count-1, section: 0)
        self.table.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
                textView.text = "Комментарий"
                textView.textColor = UIColor.lightGray
            }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newString = textView.text + text
        if (text == "\n") {
                textView.resignFirstResponder()
            }
        parameters.comment = newString
        
        return true
    }
    
}
