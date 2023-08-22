//
//  PromoController.swift
//  RXAgent
//
//  Created by RX Group on 17.01.2023.
//  Copyright © 2023 RX Group. All rights reserved.
//

import UIKit

class PromoController: UIViewController {

    @IBOutlet weak var promoField: UITextField!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var activeBtn: UIButton!
    @IBOutlet weak var bottomConst: NSLayoutConstraint!
    @IBOutlet weak var greyView: UIView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            greyView.isHidden = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        self.promoField.text = DiscountObject.sharedInstance().promoText ?? ""
        self.activeBtn.isEnabled = (DiscountObject.sharedInstance().promoText ?? "").count > 0
        self.activeBtn.backgroundColor = (DiscountObject.sharedInstance().promoText ?? "").count > 0 ? UIColor.init(displayP3Red: 163/255, green: 205/255, blue: 58/255, alpha: 1) : UIColor.init(displayP3Red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
        self.promoField.becomeFirstResponder()
        self.promoField.delegate = self
        self.setupPromoField()
    }
    
    func setupPromoField(){
        self.promoField.layer.borderColor = UIColor.init(displayP3Red: 163/255, green: 205/255, blue: 58/255, alpha: 1).cgColor
        self.promoField.layer.borderWidth = 1
        self.promoField.layer.cornerRadius = 12
        self.promoField.leftPaddingPoints(16)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print(DiscountObject.sharedInstance().promoText)
    }
    
    @objc internal func keyboardWillShow(_ notification : Notification?) -> Void {
           var _kbSize:CGSize!
           if let info = notification?.userInfo {
               let frameEndUserInfoKey = UIResponder.keyboardFrameEndUserInfoKey
               if let kbFrame = info[frameEndUserInfoKey] as? CGRect {
                   let screenSize = UIScreen.main.bounds
                   let intersectRect = kbFrame.intersection(screenSize)
                   if intersectRect.isNull {
                       _kbSize = CGSize(width: screenSize.size.width, height: 0)
                   } else {
                       _kbSize = intersectRect.size
                   }
                   self.bottomConst.constant = _kbSize.height + 16
               }
           }
       }

    @IBAction func activePromo(_ sender: Any) {
        loading.isHidden = false
        if((self.promoField.text?.count ?? 0)>0){
            DiscountObject.sharedInstance().promoText = self.promoField.text
        }
        if((DiscountObject.sharedInstance().promoText?.count ?? 0)>0){
            let dict = ["Code":DiscountObject.sharedInstance().promoText ?? "", "Target":targetVehicleID, "Category":categoryVehicleID] as [String : Any]
            postRequest(JSON: dict, URLString: domain + "v0/promocodes/discount", completion: {
                result in
                
                do{
                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                    if let discount = try? JSONDecoder().decode(Discount.self, from: jsonData){
                        DiscountObject.sharedInstance().discount = discount.discount.eosago
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatePormo"), object: nil, userInfo:nil)
                            self.dismiss(animated: true)
                            self.loading.isHidden = true
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.loading.isHidden = true
                            self.errorLbl.isHidden = false
                            self.errorLbl.text = (result["errors"] as? [String] ?? [])[0]
                            DiscountObject.sharedInstance().promoText = ""
                        }
                    }
                }catch{
                    
                }
            
            })
        }else{
            self.loading.isHidden = true
            self.errorLbl.text = "Поле с промокодом пустое"
        }
       
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

extension PromoController:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        
        let allowedCharacters = CharacterSet(charactersIn:"АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЬЫЪЧШЩЭЮЯабвгдеёжзийклмнопрстуфхцчшщьыъэюяABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ").inverted
        let components = string.components(separatedBy: allowedCharacters)
           let filtered = components.joined(separator: "")
           print(filtered, string)
           if string == filtered {
//        if (newString.rangeOfCharacter(from: characterSet) != nil) {
           // DiscountObject.sharedInstance().promoText = newString
            self.errorLbl.isHidden = true
            self.activeBtn.isEnabled = newString.count > 0
            self.activeBtn.backgroundColor = newString.count > 0 ? UIColor.init(displayP3Red: 163/255, green: 205/255, blue: 58/255, alpha: 1):UIColor.init(displayP3Red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
              return true
           } else {
              return false
                      
               }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
      
        DispatchQueue.main.async {
            self.errorLbl.isHidden = true
            self.activeBtn.isEnabled = false
            self.activeBtn.backgroundColor = UIColor.init(displayP3Red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
        }
        
        return true
    }
}
