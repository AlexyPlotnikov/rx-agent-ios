//
//  LoginController.swift
//  RXAgent
//
//  Created by RX Group on 25/01/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit
import SafariServices
import AudioToolbox


class LoginController: UIViewController,UITextFieldDelegate {

   
    @IBOutlet weak var loginField: YVTextField!
    var loginString = ""
    
    @IBOutlet weak var passwordField: YVTextField!
    var passwordString = ""
    var showed = false
    @IBOutlet weak var eyeBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let tapGestureRecognizer    = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
        tapGestureRecognizer.cancelsTouchesInView=false
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
   
    
    @IBAction func showPass(_ sender: Any) {
        showed = !showed
        passwordField.isSecureTextEntry = !showed
        eyeBtn.setImage(UIImage(named: showed ? "eyeClose":"eyeOpen"), for: .normal)
    }
    
    @IBAction func reg(_ sender: Any) {
        let destination: NSURL = NSURL(string: "https://accounts.rx-agent.ru/access-request")!
        let safari: SFSafariViewController = SFSafariViewController(url: destination as URL)
        self.present(safari, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.handleTap()
        return true
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == loginField){
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            loginString = updatedText
        }else{
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            passwordString = updatedText
        }
        return true
    }
    
    @IBAction func logIn(_ sender: Any) {
         if(loginString.isEmpty){
            self.setMessage("Введите логин")
            return
        }else if(passwordString.isEmpty){
            self.setMessage("Введите пароль")
            return
        }else{
        let bodyStr = "grant_type=password&client_id=b2b.app.ios&scope=openid profile b2b.api offline_access&username=\(loginString)&password=\(passwordString)"

            postLoginRequest(URLString: "https://accounts.rx-agent.ru/connect/token", body: bodyStr, completion: {
                result in
                print(result)
                if((result["error_description"] as? String) == nil){
                    DispatchQueue.main.async {
                    token = result["access_token"] as! String
                    refresh_token = result["refresh_token"] as! String
                    UserDefaults.standard.set(token, forKey: "token")
                    UserDefaults.standard.set(refresh_token, forKey: "refresh_token")
                        Profile.shared.reloadProfile {
                            TORecords.shared.records = nil
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let initialViewController = storyboard.instantiateViewController(withIdentifier: "FaceID")
                            let object = ["login":self.loginString,"password":self.passwordString] as [String : Any]
                            let defaults = UserDefaults.standard
                            defaults.set(object, forKey: "loginPair")
                            UIApplication.shared.keyWindow?.rootViewController = initialViewController
                        }



                    }
                }else{
                    self.setMessage((result["error_description"] as! String))
                }
            })
     }
    }
  
    @IBAction func reloadPassword(_ sender: Any) {
        let destination: NSURL = NSURL(string: "https://accounts.rx-agent.ru/password")!
        let safari: SFSafariViewController = SFSafariViewController(url: destination as URL)
        self.present(safari, animated: true, completion: nil)
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

extension String {
    func convertToDictionary() -> [String: String]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}


//        let animation = CABasicAnimation(keyPath: "position")
//        animation.duration = 0.1
//        animation.repeatCount = 2
//        animation.autoreverses = true
//        animation.fromValue = NSValue(cgPoint: CGPoint(x: loginField.center.x - 10, y: loginField.center.y))
//        animation.toValue = NSValue(cgPoint: CGPoint(x: loginField.center.x + 10, y: loginField.center.y))
//
//        loginField.layer.add(animation, forKey: "position")
//        UINotificationFeedbackGenerator().notificationOccurred(.error)
