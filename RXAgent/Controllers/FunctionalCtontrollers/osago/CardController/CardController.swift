//
//  CardController.swift
//  RXAgent
//
//  Created by RX Group on 19/08/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit
import CardScan



class CardController: UIViewController{
   

   
    @IBOutlet weak var table: UITableView!
    var containerViewController: MainOsagoController?
   
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCards), name: NSNotification.Name(rawValue: "reloadCards"), object: nil)
        registerForKeyboardWillHideNotification(self.table, bottomInset: 40)
        registerForKeyboardWillShowNotification(self.table)
        let tapGestureRecognizer = UITapGestureRecognizer()
            tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
            tapGestureRecognizer.cancelsTouchesInView=false
            self.view.addGestureRecognizer(tapGestureRecognizer)
        self.reloadCards()
        self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        self.table.tableFooterView = UIView()
        getRequest(URLString:domain + "v0/eosagoPolicies/time", completion: {
            result in
            DispatchQueue.main.async {
                saturdayChecked = ((result["eosagoTime"] as! [String:Any])["creatorSaturdayTimeEnd"] as? String != nil) && ((result["eosagoTime"] as! [String:Any])["creatorSaturdayTimeStart"] as? String != nil)
                weeklyChecked = ((result["eosagoTime"] as! [String:Any])["creatorWeekdaysTimeEnd"] as? String != nil) && ((result["eosagoTime"] as! [String:Any])["creatorWeekdaysTimeStart"] as? String != nil)
                sundayChecked = ((result["eosagoTime"] as! [String:Any])["creatorSundayTimeEnd"] as? String != nil) && ((result["eosagoTime"] as! [String:Any])["creatorSundayTimeStart"] as? String != nil)
                print(weeklyChecked, saturdayChecked, sundayChecked)
                if(saturdayChecked){
                    creatorSaturdayTimeEnd = (result["eosagoTime"] as! [String:Any])["creatorSaturdayTimeEnd"] as! String
                    creatorSaturdayTimeStart = (result["eosagoTime"] as! [String:Any])["creatorSaturdayTimeStart"] as! String
                }
                if(weeklyChecked){
                    creatorWeekdaysTimeEnd = (result["eosagoTime"] as! [String:Any])["creatorWeekdaysTimeEnd"] as! String
                    creatorWeekdaysTimeStart = (result["eosagoTime"] as! [String:Any])["creatorWeekdaysTimeStart"] as! String
                }
                if(sundayChecked){
                    creatorSundayTimeEnd = (result["eosagoTime"] as! [String:Any])["creatorSundayTimeEnd"] as! String
                    creatorSundayTimeStart = (result["eosagoTime"] as! [String:Any])["creatorSundayTimeStart"] as! String
                }
                self.table.reloadData()
            }
            
            print(result)
        })
    }
 
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
    @objc func reloadCards(){
        if(!isEdit){
            Cards.sharedInstance().loadCards { (loaded,cards) in
                cardIndex = (Cards.sharedInstance().cardsArray?.count ?? 0) - 1
                self.table.reloadData()
            }
        }
    }
  
    func drawEmptyPhotos()->Bool{
        var weekValid = false
        var saturdayValid = false
        var sundayValid = false
        
        if(weeklyChecked && (creatorWeekdaysTimeStart.isEmpty || creatorWeekdaysTimeEnd.isEmpty)){
            if let cell = self.table.cellForRow(at: IndexPath(row: 0, section: 1)) as? CardCell{
                self.shakeView(view: cell)
            }
        }else{
            weekValid = weeklyChecked
        }
        
        if(saturdayChecked && (creatorSaturdayTimeStart.isEmpty || creatorSaturdayTimeEnd.isEmpty)){
            if let cell = self.table.cellForRow(at: IndexPath(row: 0, section: 2)) as? CardCell{
                self.shakeView(view: cell)
            }
        }else{
            saturdayValid = saturdayChecked
        }
        
        if(sundayChecked && (creatorSundayTimeStart.isEmpty || creatorSundayTimeEnd.isEmpty)){
            if let cell = self.table.cellForRow(at: IndexPath(row: 0, section: 3)) as? CardCell{
                self.shakeView(view: cell)
            }
        }else{
            sundayValid = sundayChecked
        }
        
     
            return cardValidate() && (weekValid || saturdayValid || sundayValid)
        
        
       
    }
 
    func shakeView(view:UIView){
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 10, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 10, y: view.center.y))

        view.layer.add(animation, forKey: "position")
    }

    func replaceObjectToCard(textStr:String)->String{
        if(textStr.count<16){
            return textStr
        }
        var result = ""
        let start = textStr.startIndex;
        let end = textStr.index(textStr.startIndex, offsetBy: textStr.count-4);
        result = "**** **** ***\(textStr.replacingCharacters(in: start..<end, with: "* "))"

        return result
    }
    
   
    func showAlert(){
        let alert = UIAlertController(title: "", message: "Выберите действие", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Отсканировать карту", style: .default , handler:{ (UIAlertAction)in
                self.openScaner()
        }))
        
        alert.addAction(UIAlertAction(title: "Ввести вручную", style: .default , handler:{ (UIAlertAction)in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "detailCardVC") as! DetailCardController
                Cards.sharedInstance().scanedCard = nil
                self.present(vc, animated: true)
        }))

      
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler:{ (UIAlertAction)in
            
        }))

        
        //uncomment for iPad Support
        alert.popoverPresentationController?.sourceView = self.view

        self.present(alert, animated: true, completion: nil)
    }
 
    func openScaner(){
           guard let vc = ScanViewController.createViewController(withDelegate: self) else {
               print("scan view controller not supported on this hardware")
               return
           }
           vc.stringDataSource = self
           vc.hideBackButtonImage = true
           vc.positionCardFont = UIFont.systemFont(ofSize: 16)
           CreditCardUtils.prefixesRegional = ["2200", "2201", "2202", "2203", "2204"]

           self.present(vc, animated: true)
    }

    @objc func switcherChanged(switcher:UISwitch){
        if let cell = self.table.cellForRow(at: IndexPath(row: 0, section: switcher.tag)) as? CardCell{
            switch switcher.tag {
            case 1:
                weeklyChecked = switcher.isOn
            case 2:
                saturdayChecked = switcher.isOn
            case 3:
                sundayChecked = switcher.isOn
            default:
                break
            }
            
            cell.fromField.isEnabled = switcher.isOn
            cell.toField.isEnabled = switcher.isOn
        }
    }
   
    func datePickerChanged(textField:UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        }
            datePickerView.datePickerMode = .time
            datePickerView.minuteInterval = 30
            datePickerView.tag = textField.tag
            textField.addToolBar()
            self.setTimeVariable(index: textField.tag, text: datePickerView.date)
           
            textField.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(datePickerFromValueChanged), for: .valueChanged)
    }
    
  
    @objc func datePickerFromValueChanged(sender:UIDatePicker) {
        self.setTimeVariable(index: sender.tag, text: sender.date)
        
    }
   
    func setTimeVariable(index:Int, text:Date){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let section = index / 10
        let numberLbl = index % 10
        if let cell = self.table.cellForRow(at: IndexPath(row: 0, section: section)) as? CardCell{
            if(numberLbl==0){
                if(section == 1){
                    creatorWeekdaysTimeStart = dateFormatter.string(from: text)
                }else if(section == 2){
                    creatorSaturdayTimeStart = dateFormatter.string(from: text)
                }else{
                    creatorSundayTimeStart = dateFormatter.string(from: text)
                }
                cell.fromField.text = dateFormatter.string(from: text)
            }else{
                if(section == 1){
                    creatorWeekdaysTimeEnd = dateFormatter.string(from: text)
                }else if(section == 2){
                    creatorSaturdayTimeEnd = dateFormatter.string(from: text)
                }else{
                    creatorSundayTimeEnd = dateFormatter.string(from: text)
                }
                cell.toField.text = dateFormatter.string(from: text)
            }
        }
    }

}



extension CardController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0){
            if(indexPath.row == 0 || indexPath.row == (Cards.sharedInstance().cardsArray ?? []).count + 1){
                return (hidePayCard ?? false) ? 0:54
            }else{
                return (hidePayCard ?? false) ? 0:72
            }
        }else{
            return 92
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return (Cards.sharedInstance().cardsArray ?? []).count + 2
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            if(indexPath.row == 0){
                let cellReuseIdentifier = "cellTitle"
                let cell:CardCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! CardCell
                cell.accessoryType = .none
                cell.titlePlaceholderLbl.text = (Cards.sharedInstance().cardsArray ?? []).count > 0 ? "Выберите карту":"Добавьте карту"
                return cell
            }else if((Cards.sharedInstance().cardsArray ?? []).count == indexPath.row-1){
                let cellReuseIdentifier = "cellAdd"
                let cell:CardCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! CardCell
                cell.accessoryType = .none
                return cell
            }else{
                let cellReuseIdentifier = "cell"
                let cell:CardCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! CardCell
                let card = Cards.sharedInstance().cardsArray![indexPath.row-1]
                if(cardIndex == indexPath.row-1){
                    cell.accessoryType = .checkmark
                    cardNumber = card.payCardNumber ?? ""
                    cardYear = card.payCardYear ?? ""
                    cardMonth = card.payCardMonth ?? ""
                    cardCvc = card.payCardCVC ?? ""
                    creditLastName = card.payCardLastName ?? ""
                    creditFirstName = card.payCardFirstName ?? ""
                    print(cardNumber)
                }else{
                    cell.accessoryType = .none
                }
                
                    cell.titleLbl.text = self.replaceObjectToCard(textStr: card.payCardNumber!)
                    cell.subtitleLbl.text = "\(card.payCardFirstName ?? "-") \(card.payCardLastName ?? "")"
                    cell.dateLbl.text = "\(card.payCardMonth ?? "")/\(card.payCardYear ?? "")"
                 return cell
            }
        }else if(indexPath.section == 1){
            let cellReuseIdentifier = "cellTime"
            let cell:CardCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! CardCell
            cell.titleDays.text = "Будние дни"
            cell.fromField.delegate = self
            cell.fromField.tag = 10
            cell.toField.delegate = self
            cell.toField.tag = 11
            cell.fromField.isEnabled = weeklyChecked
            cell.toField.isEnabled = weeklyChecked
            cell.fromField.text = creatorWeekdaysTimeStart
            cell.toField.text = creatorWeekdaysTimeEnd
            cell.switcher.setOn(weeklyChecked, animated: false)
            cell.switcher.tag = indexPath.section
            cell.switcher.addTarget(self, action: #selector(switcherChanged(switcher:)), for: .valueChanged)
            return cell
        }else if(indexPath.section == 2){
            let cellReuseIdentifier = "cellTime"
            let cell:CardCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! CardCell
            cell.titleDays.text = "Суббота"
            cell.fromField.delegate = self
            cell.fromField.tag = 20
            cell.toField.delegate = self
            cell.toField.tag = 21
            cell.fromField.isEnabled = saturdayChecked
            cell.toField.isEnabled = saturdayChecked
            cell.fromField.text = creatorSaturdayTimeStart
            cell.toField.text = creatorSaturdayTimeEnd
            cell.switcher.setOn(saturdayChecked, animated: false)
            cell.switcher.tag = indexPath.section
            cell.switcher.addTarget(self, action: #selector(switcherChanged(switcher:)), for: .valueChanged)
            return cell
        }else{
            let cellReuseIdentifier = "cellTime"
            let cell:CardCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! CardCell
            cell.titleDays.text = "Воскресенье"
            cell.fromField.delegate = self
            cell.fromField.tag = 30
            cell.toField.delegate = self
            cell.toField.tag = 31
            cell.fromField.isEnabled = sundayChecked
            cell.toField.isEnabled = sundayChecked
            cell.fromField.text = creatorSundayTimeStart
            cell.toField.text = creatorSundayTimeEnd
            cell.switcher.setOn(sundayChecked, animated: false)
            cell.switcher.tag = indexPath.section
            cell.switcher.addTarget(self, action: #selector(switcherChanged(switcher:)), for: .valueChanged)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            if((Cards.sharedInstance().cardsArray ?? []).count != indexPath.row-1 && indexPath.row != 0){
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.accessoryType = .checkmark
                    cardIndex = indexPath.row-1
                    self.table.reloadSections(IndexSet(integer: 0), with: .none)
                }
            }else if(indexPath.row != 0){
                self.showAlert()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            if((Cards.sharedInstance().cardsArray ?? []).count != indexPath.row-1 && indexPath.row != 0){
                if let cell = tableView.cellForRow(at: indexPath) {
                        cell.accessoryType = .none

                    }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0){
             return 20
        }else{
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if(section == 0){
            return "Укажите время для оплаты полиса Е-ОСАГО по вашему часовому поясу"
        }else{
            return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Удалить") { (action:UITableViewRowAction, indexPath:IndexPath) in
            Cards.sharedInstance().removeCardByIndex(index: indexPath.row - 1, deleted: { _ in
                self.table.reloadSections(IndexSet(integer: 0), with: .none)
            })
        }
        delete.backgroundColor = .red

        let more = UITableViewRowAction(style: .default, title: "Изменить") { (action:UITableViewRowAction, indexPath:IndexPath) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "detailCardVC") as! DetailCardController
            vc.isEdit = true
            Cards.sharedInstance().scanedCard = Cards.sharedInstance().cardsArray![indexPath.row-1]
            Cards.sharedInstance().editCardIndex = indexPath.row - 1
            self.present(vc, animated: true)
        }
        more.backgroundColor = .orange

        return [delete, more]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(indexPath.section == 0 && (Cards.sharedInstance().cardsArray ?? []).count != indexPath.row-1 && indexPath.row != 0){
            return true
        }else{
            return false
        }
    }

}
//MARK: делегат текстфилда
extension CardController:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
       
        self.datePickerChanged(textField: textField)
    }
}
//MARK: делегат сканера карт
extension CardController: FullScanStringsDataSource {
    func denyPermissionTitle() -> String {
        return ""
    }
    
    func denyPermissionMessage() -> String {
        return ""
    }
    
    func denyPermissionButton() -> String {
        return ""
    }
    
    func scanCard() -> String {
        return "Отсканируйте карту"
    }
    
    func positionCard() -> String {
        return "Держите карту внутри рамки.\nОна будет считана автоматически."
    }
    
    func backButton() -> String {
        return "Закрыть"
    }
    
    func skipButton() -> String {
        return "РУЧНОЙ ВВОД"
    }
    
    
}

extension CardController: ScanDelegate {
   func userDidSkip(_ scanViewController: ScanViewController) {
        self.dismiss(animated: true)
    }

    func userDidCancel(_ scanViewController: ScanViewController) {
        self.dismiss(animated: true)
    }

    func userDidScanCard(_ scanViewController: ScanViewController, creditCard: CreditCard) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "detailCardVC") as! DetailCardController
        let words = creditCard.name?.components(separatedBy: " ") ?? []
        var firstName = ""
        var lastName = ""
        if(words.count == 2){
            firstName = words[0]
            lastName = words[1]
        }
        Cards.sharedInstance().scanedCard = Card(payCardLastName: lastName, payCardYear: creditCard.expiryYear ?? "", payCardFirstName: firstName, payCardNumber: creditCard.number , payCardCVC: creditCard.cvv ?? "", payCardMonth: creditCard.expiryMonth ?? "")

        self.dismiss(animated: true)
        self.present(vc, animated: true)
    }

    func userDidScanQrCode(_ scanViewController: ScanViewController, payload: String) {
        self.dismiss(animated: true)
        print(payload)
    }
}
