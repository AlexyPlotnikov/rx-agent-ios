//
//  PaimentController.swift
//  RXAgent
//
//  Created by RX Group on 16.07.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import UIKit

class PaimentController: UIViewController {

    @IBOutlet weak var table: UITableView!
    let profileID = String(format: "%04d", Profile.shared.profile?.contractor?.id ?? 0)
    let categoryID = Category.sharedInstance().currentCategoryID!
    let tipID = Address.sharedInstance().currentAddress.id
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Paiment.sharedInstance().loadPaiment(profileID: profileID, categoryID: categoryID, tipID: tipID) { (loaded, _) in
            if(loaded){
                self.table.reloadData()
            }
        }
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
        self.table.reloadData()
        self.view.endEditing(true)
    }

}

extension PaimentController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Paiment.sharedInstance().paiment != nil{
            return 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PaimentCell
            cell.textFieldView.textField.delegate = self
            cell.textFieldView.needImage = true
            cell.textFieldView.placeholder = "Укажите общую стоимость ТО"
            cell.textFieldView.subtitleText = "Общая стоимость"
            cell.textFieldView.textField.text = "\(Paiment.sharedInstance().paiment!.totalPrice) ₽"
            cell.textFieldView.textField.keyboardType = .numberPad
            self.addToolBarTextfield(textField: cell.textFieldView.textField)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellText", for: indexPath) as! PaimentCell
            cell.mainPricelbl.text = "\(Paiment.sharedInstance().paiment!.mainPrice) ₽"
            cell.addPrice.text = "\(Paiment.sharedInstance().paiment!.addPrice) ₽"
            return cell
        }
    }
    
}

extension PaimentController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = textField.text!.replacingOccurrences(of: " ₽", with: "")
    }
 
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            var newString = (text as NSString).replacingCharacters(in: range, with: string)
            newString = newString.replacingOccurrences(of: " ₽", with: "")
            if Paiment.sharedInstance().paiment != nil{
                Paiment.sharedInstance().paiment!.totalPrice = Int(newString) ?? 0
                Paiment.sharedInstance().paiment!.addPrice = Paiment.sharedInstance().paiment!.totalPrice - Paiment.sharedInstance().paiment!.mainPrice
//                self.table.reloadData()
            }
        }
       
        return true
    }
}
