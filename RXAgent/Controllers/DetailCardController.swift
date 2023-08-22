//
//  DetailCardController.swift
//  RXAgent
//
//  Created by RX Group on 31.08.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import UIKit

class DetailCardController: UIViewController {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var createBtn: UIButton!
    
    var smallPlaceholderArray:[String] = ["Номер карты","Срок действия","Имя и Фамилия","Код"]
    var placeholderArray:[String] = ["Укажите номер карты", "ММ/ГГ", "Имя и Фамилия", "СVC"]
    
    var isEdit:Bool = false
    var tempCard:CardDetail = CardDetail()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createBtn.setTitle(isEdit ? "Сохранить карту":"Добавить карту", for: .normal)
        self.initTap()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupTextfields()
    }
    
    func initTap(){
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
        tapGestureRecognizer.cancelsTouchesInView=false
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCards"), object: nil, userInfo: nil)
    }
    
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func setupTextfields(){
        if(Cards.sharedInstance().scanedCard != nil){
            let scanedCard = Cards.sharedInstance().scanedCard
            tempCard.fullNameCard = "\(scanedCard!.payCardFirstName ?? "") \(scanedCard!.payCardLastName ?? "")"
            tempCard.numberCard = scanedCard!.payCardNumber!.grouping(every: 4, with: " ")
            tempCard.dateCard = "\(scanedCard!.payCardMonth!)/\(scanedCard!.payCardYear!)"
            tempCard.cvcCard = scanedCard!.payCardCVC
            
            if let cell = self.table.cellForRow(at: IndexPath(row: 0, section: 0)) as? DetailCardCell{
                cell.textField.text = tempCard.numberCard
            }
           
            if(scanedCard!.payCardMonth != "" && scanedCard!.payCardYear != ""){
                if let cell = self.table.cellForRow(at: IndexPath(row: 1, section: 0)) as? DetailCardCell{
                    cell.textField.text = tempCard.dateCard
                }
            }
            
            if let cell = self.table.cellForRow(at: IndexPath(row: 3, section: 0)) as? DetailCardCell{
                cell.textField.text = tempCard.cvcCard
            }

            if(scanedCard!.payCardFirstName != "" || scanedCard!.payCardLastName != ""){
                if let cell = self.table.cellForRow(at: IndexPath(row: 2, section: 0)) as? DetailCardCell{
                    cell.textField.text = tempCard.fullNameCard
                }
            }
            
        }
    }
    
    @IBAction func saveCard(_ sender: Any) {
        let date = tempCard.dateCard?.components(separatedBy: "/")
            
            var month = ""
            var year = ""
            if(date?.count != 1){
                month = date?[0] ?? ""
                year = date?[1] ?? ""
            }
         
        if(((tempCard.numberCard?.replacingOccurrences(of: " ", with: "") ?? "").count )<16){
                self.setMessage("Минимальное количество знаков номера карты 16 символов")
        }else if(((tempCard.dateCard?.replacingOccurrences(of: "/", with: "") ?? "").count)<4 || Int(month) ?? 0>12 || Int(year) ?? 0<21){
                self.setMessage("Пожалуйста, проверьте срок карты")
        }else if(tempCard.cvcCard?.count ?? 0 < 3){
                self.setMessage("Неправильное значение CVC/CVV")
            }else{
                let number = tempCard.numberCard?.replacingOccurrences(of: " ", with: "")
                let cvc = tempCard.cvcCard
                
                let words = tempCard.fullNameCard?.components(separatedBy: " ") ?? []
                var firstName = ""
                var lastName = ""
                if(words.count == 2){
                    firstName = words[0]
                    lastName = words[1]
                }else{
                    firstName = tempCard.fullNameCard ?? ""
                    lastName = ""
                }
                
                if(!Cards.sharedInstance().checkDuplicate(number: number!) ){
                    if(!isEdit){
                        Cards.sharedInstance().scanedCard = Card(payCardLastName: lastName, payCardYear: year, payCardFirstName: firstName, payCardNumber: number, payCardCVC: cvc, payCardMonth: month)
                        Cards.sharedInstance().saveCard()
                    }else{
                        Cards.sharedInstance().saveEditingCard(cardToSave: Card(payCardLastName: lastName, payCardYear: year, payCardFirstName: firstName, payCardNumber: number, payCardCVC: cvc, payCardMonth: month)) { saved in
                            
                        }
                    }
                    self.dismiss(animated: true, completion: nil)
                }else{
                    if(!isEdit){
                        self.setMessage("Карта с таким номером уже сохранена")
                    }else{
                        Cards.sharedInstance().saveEditingCard(cardToSave: Card(payCardLastName: lastName, payCardYear: year, payCardFirstName: firstName, payCardNumber: number, payCardCVC: cvc, payCardMonth: month)) { saved in
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
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
}


extension DetailCardController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return smallPlaceholderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetailCardCell
        
        cell.textField.smallPlaceholderText = smallPlaceholderArray[indexPath.row]
        cell.textField.placeholder = placeholderArray[indexPath.row]
        cell.textField.tag = indexPath.row
        cell.textField.delegate = self
        cell.textField.keyboardType = indexPath.row == 2 ? .default:.numberPad
        cell.textField.returnKeyType = .next
        cell.textField.isSecureTextEntry = indexPath.row == 3
        cell.eyeBtn.isHidden = indexPath.row != 3
        cell.textField.addToolBar()
        if(indexPath.row == 0 && !isEdit){
            cell.textField.becomeFirstResponder()
        }
        
        return cell
    }
    
    
}

extension DetailCardController:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        if (textField.tag == 0 && newString.count <= 23) {
            textField.text = newString.grouping(every: 4, with: " ")
            tempCard.numberCard = newString.grouping(every: 4, with: " ")
            if(newString.count == 19){
                if let cell = self.table.cellForRow(at: IndexPath(row: 1, section: 0)) as? DetailCardCell{
                    cell.textField.becomeFirstResponder()
                }
                
            }
            return false
            
        }else if (textField.tag == 1 && newString.count <= 5){
            textField.text = newString.grouping(every: 2, with: "/")
            tempCard.dateCard = newString.grouping(every: 2, with: "/")
            
            if(newString.count == 5){
                if let cell = self.table.cellForRow(at: IndexPath(row: 2, section: 0)) as? DetailCardCell{
                    cell.textField.becomeFirstResponder()
                }
            }
           return false
        }else  if (textField.tag == 2){
            textField.text = newString
            tempCard.fullNameCard = newString
        }else if (textField.tag == 3 && newString.count <= 3){
            textField.text = newString
            tempCard.cvcCard = newString
            if(newString.count == 3){
                if let cell = self.table.cellForRow(at: IndexPath(row: 3, section: 0)) as? DetailCardCell{
                    cell.textField.resignFirstResponder()
                }
            }
            return false
        }
       
     return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let cell = self.table.cellForRow(at: IndexPath(row: 3, section: 0)) as? DetailCardCell{
            cell.textField.becomeFirstResponder()
        }
        return true
    }
}

extension String {
    func grouping(every groupSize: String.IndexDistance, with separator: Character) -> String {
       let cleanedUpCopy = replacingOccurrences(of: String(separator), with: "")
       return String(cleanedUpCopy.characters.enumerated().map() {
            $0.offset % groupSize == 0 ? [separator, $0.element] : [$0.element]
       }.joined().dropFirst())
    }
}

extension UITextField{
    func addToolBar(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneButtonAction))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spaceButton,doneButton], animated: false)
        self.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonAction(){
            self.resignFirstResponder()
        }
}
