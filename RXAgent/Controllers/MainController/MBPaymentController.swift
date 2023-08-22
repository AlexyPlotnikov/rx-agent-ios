//
//  MBPaymentController.swift
//  RXAgent
//
//  Created by RX Group on 15.03.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit
import WebKit
import SPIndicator

class MBPaymentController: UIViewController,UITextFieldDelegate {

   
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var numberLbl: UILabel!
   
    @IBOutlet weak var encorrectLbl: UILabel!
    @IBOutlet weak var payBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        numberLbl.text = String(format: "№ %04d", Profile.shared.profile?.contractor?.id ?? 0)
        if let userDefaults = UserDefaults.standard.string(forKey: "mail\(Profile.shared.profile?.contractor?.id ?? 0)"){
            emailField.text = userDefaults
        }else{
            emailField.text = Profile.shared.profile?.email ?? ""
        }
        if(emailField.text == ""){
            emailField.becomeFirstResponder()
        }
        emailField.addToolBar()
        
        let tapGestureRecognizer = UITapGestureRecognizer()
            tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
            tapGestureRecognizer.cancelsTouchesInView=false
            self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @IBAction func pay(_ sender: Any) {
        if(emailField.text!.count == 0){
            encorrectLbl.isHidden = false
            encorrectLbl.text = "Укажите почту"
        }else if(!emailField.text!.isValidEmail()){
             encorrectLbl.isHidden = false
             encorrectLbl.text = "Некорректная почта"
        }else{
            payBtn.isEnabled = false
            let dict = ["email": emailField.text!] as [String:Any]
            print(dict)
            postRequest(JSON: dict, URLString: domain + "v0/Balances/email", completion: {
                result in
                print(result)
                DispatchQueue.main.async {
                    if(result["error"] == nil){
                       SPIndicator.present(title: "Письмо с оплатой отправлено на почту", haptic: .error, completion:{

                       })
                       UserDefaults.standard.set(self.emailField.text!, forKey: "mail\(Profile.shared.profile?.contractor?.id ?? 0)")
                       self.dismiss(animated: true)
                    }else{
                        self.payBtn.isEnabled = true
                        self.encorrectLbl.isHidden = false
                        self.encorrectLbl.text = "Некорректная почта"
                    }
                }
            })
        }
        
    }
    
    @objc fileprivate func handleTap(_ tap: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func setMessage(_ text:String) {
        DispatchQueue.main.async{
            let alertController = UIAlertController(title: "Внимание!", message:
                text , preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        encorrectLbl.isHidden = true
    }
    
}

extension String {
    func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
