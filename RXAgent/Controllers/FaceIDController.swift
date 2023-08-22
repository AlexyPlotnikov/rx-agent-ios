//
//  FaceIDController.swift
//  Borrower
//
//  Created by RX Group on 09.12.2020.
//

import UIKit
import LocalAuthentication
import AVFoundation

class FaceIDController: UIViewController {
    enum BiometricType {
        case none
        case touch
        case face
    }
    
 
    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var faceIDBtn: UIButton!
    @IBOutlet weak var eraseBtn: UIButton!
    
    @IBOutlet weak var circle1: UIView!
    @IBOutlet weak var circle2: UIView!
    @IBOutlet weak var circle3: UIView!
    @IBOutlet weak var circle4: UIView!
    
    @IBOutlet weak var bottomCircle1: UIView!
    @IBOutlet weak var bottomCircle2: UIView!
    @IBOutlet weak var bottomCircle3: UIView!
    @IBOutlet weak var bottomCircle4: UIView!
    
    
    @IBOutlet weak var number0: UIButton!
    @IBOutlet weak var number1: UIButton!
    @IBOutlet weak var number2: UIButton!
    @IBOutlet weak var number3: UIButton!
    @IBOutlet weak var number4: UIButton!
    @IBOutlet weak var number5: UIButton!
    @IBOutlet weak var number6: UIButton!
    @IBOutlet weak var number7: UIButton!
    @IBOutlet weak var number8: UIButton!
    @IBOutlet weak var number9: UIButton!
    
    @IBOutlet weak var bottomCircles: UIStackView!
    @IBOutlet weak var subtitleLbl: UILabel!
    @IBOutlet weak var loadScreen: UIView!
    @IBOutlet weak var versionlbl: UILabel!
    @IBOutlet weak var debugLbl: UILabel!
    
    
    lazy var emptyColorWhite = UIColor.init(displayP3Red: 178/255, green: 178/255, blue: 178/255, alpha: 1)
    lazy var fillColorWhite = UIColor.init(displayP3Red: 52/255, green: 50/255, blue: 59/255, alpha: 1)
 
    lazy var backgroundWhite = UIColor.white
    lazy var backgroundBlack = UIColor.init(displayP3Red: 25/255, green: 25/255, blue: 27/255, alpha: 1)


    lazy var circlessArray = [circle1,circle2,circle3,circle4]
    lazy var bottomCirclessArray = [bottomCircle1,bottomCircle2,bottomCircle3,bottomCircle4]
    lazy var numbersArray = [number0,number1,number2,number3,number4,number5,number6,number7,number8,number9]
    
    var code:String = ""
    var secondCode:String = ""
    var codePass = ""
    
    var nextStep = false
    
    let context = LAContext()
   
    
    
    var passExist:Bool{
        return UserDefaults.standard.string(forKey: "CodePass") != nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(closeFaceID),
                                               name: NSNotification.Name(rawValue: "closeFaceID"),
                                               object: nil)

        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(openOsagoRemote(_:)),
                                               name: NSNotification.Name(rawValue: "openOsagoFaceID"),
                                               object: nil)
        if(self.passExist){
            let defaults = UserDefaults.standard
            self.codePass = defaults.string(forKey: "CodePass")!
            self.topTitle.text = "Введите PIN-код доступа"
            self.faceIDBtn.isHidden = false
        }else{
            self.topTitle.text = "Установите PIN-код доступа для быстрого входа"
            self.faceIDBtn.isHidden = true
        }
        
        Updates.updatingMode = .automatically
        Updates.notifying = .always
        Updates.appStoreId = "1424869497"
        Updates.checkForUpdates(completion: {
            result in
            switch result {
            case .none:
              
                self.faceID()
                
            case .available(_):
                UpdatesUI.promptToUpdate(result, presentingViewController: self)
            }
        })
        self.configController()
        
    }
    
    @objc func closeFaceID(){
        context.invalidate()
    }
    
    @objc func openOsagoRemote(_ notification:Notification){
       debugLbl.text = "зашел" + " \(notification.userInfo!["id"] as? String ?? "")"
       mainID = notification.userInfo!["id"] as? String ?? ""
    }
    
    
    final func configController(){
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject
        let version = nsObject as! String
        versionlbl.text = "Версия \(version)"
        self.resetCircles()
        
     
        
        if(self.biometricType() == .face){
            faceIDBtn.setImage(UIImage(named:"faceID"), for: .normal)
        }else{
            faceIDBtn.setImage(UIImage(named:"fingerprint"), for: .normal)
        }
    }

    func resetCircles(){
        for circle in circlessArray{
            circle!.backgroundColor =  emptyColorWhite
            circle!.layer.cornerRadius = 4.5
        }
        for circle in bottomCirclessArray{
            circle!.backgroundColor =  emptyColorWhite
            circle!.layer.cornerRadius = 4.5
        }
    }
    func biometricType() -> BiometricType {
        let authContext = LAContext()
        if #available(iOS 11, *) {
            let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            switch(authContext.biometryType) {
            case .none:
                return .none
            case .touchID:
                return .touch
            case .faceID:
                return .face
            @unknown default:
                return .none
            }
        } else {
            return authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touch : .none
        }
    }

    
    
    @IBAction func keyboardTaped(_ sender: UIButton) {
        if(passExist){
            self.bottomCircles.isHidden = true
            self.subtitleLbl.isHidden = true
            self.typeButtons(typeText: "\(sender.tag)", arrayCircles: circlessArray, completion: {
                if(self.code == self.codePass){
                    self.loadScreen.isHidden = false
                    let dict = ["token":deviceToken]
                    print(dict, domain + "v0/EmployeeDevices")
                    postRequest(JSON: dict, URLString:domain + "v0/EmployeeDevices", completion: {
                        result in
                        print(result)
                    })
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainTB")
                    UIApplication.shared.keyWindow?.rootViewController = initialViewController
                    isLoggedIn = true
                    if(!mainID.isEmpty){
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            let name = Notification.Name(rawValue: "openOsago")
                            NotificationCenter.default.post(name: name, object: nil, userInfo:["id":mainID])
                        }
                       
                    }
                }else{
                    self.subtitleLbl.isHidden = false
                    self.subtitleLbl.text = "Вы указали неправильный PIN-код, попробуйте еще раз"
                    AudioServicesPlaySystemSound(1520)
                    self.code = ""
                    self.resetCircles()
                }
            })
        }else{
            if(!nextStep){
                self.nextStep = false
                self.bottomCircles.isHidden = true
                self.subtitleLbl.isHidden = true
                self.subtitleLbl.text = "Повторите PIN-код"
                self.typeButtons(typeText: "\(sender.tag)", arrayCircles: circlessArray, completion: {
                    self.nextStep = true
                    self.bottomCircles.isHidden = false
                    self.subtitleLbl.isHidden = false
                })
                
            }else{
                self.typeButtons(typeText: "\(sender.tag)", arrayCircles: bottomCirclessArray, completion: {
                    if(self.code == self.secondCode){
                        let defaults = UserDefaults.standard
                        defaults.set(self.code, forKey: "CodePass")
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let dict = ["token":deviceToken]
                        print(dict, domain + "v0/EmployeeDevices")
                        postRequest(JSON: dict, URLString:domain + "v0/EmployeeDevices", completion: {
                            result in
                            print(result)
                        })
                        let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainTB")
                        UIApplication.shared.keyWindow?.rootViewController = initialViewController
                        isLoggedIn = true
                        if(!mainID.isEmpty){
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                let name = Notification.Name(rawValue: "openOsago")
                                NotificationCenter.default.post(name: name, object: nil, userInfo:["id":mainID])
                            }
                           
                        }
                    }else{
                        self.nextStep = false
                        self.bottomCircles.isHidden = true
                        self.subtitleLbl.text = "PIN-коды не соответствуют, попробуйте еще раз"
                        self.code = ""
                        self.secondCode = ""
                        AudioServicesPlaySystemSound(1520)
                        self.resetCircles()
                    }
                })
                
            }
        }
//
        
    }
    
    func typeButtons(typeText:String, arrayCircles:[UIView?], completion:@escaping ()->Void){
        
        if((nextStep ? secondCode.count : code.count) <= 3){
            if(nextStep){
                secondCode = secondCode + typeText
            }else{
                code = code + typeText
            }
            AudioServicesPlaySystemSound(1519)
            self.coloredCircle(arrayCorcles: arrayCircles)
        }
        if((nextStep ? secondCode.count : code.count) == 4){
            completion()
        }
    }
    
    
    @IBAction func deleteTaped(_ sender: Any) {
        if((nextStep ? secondCode.count : code.count) > 0){
            if(nextStep){
                secondCode = String(secondCode.dropLast())
            }else{
                code = String(code.dropLast())
            }
            AudioServicesPlaySystemSound(1519)
            self.coloredCircle(arrayCorcles: nextStep ? bottomCirclessArray : circlessArray)
        }
        
    }
    
    func coloredCircle(arrayCorcles:[UIView?]){
        for i in 0..<arrayCorcles.count{
            if(i < (nextStep ? secondCode.count : code.count)){
                arrayCorcles[i]!.backgroundColor = fillColorWhite
            }else{
                arrayCorcles[i]!.backgroundColor = emptyColorWhite
            }
        }
    }
    
    
    
    
    @IBAction func retryFaceID(_ sender: Any) {
        self.faceID()
    }
    
    
    
    func faceID(){
       
           var error: NSError?

           if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
               let reason = "Пожалуйста, используйте авторизацию через Touch ID или введите PIN-код доступа"

               context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                   [weak self] success, authenticationError in

                   DispatchQueue.main.async {
                       if success {
                           let dict = ["token":deviceToken]
                           postRequest(JSON: dict, URLString:domain + "v0/EmployeeDevices", completion: {
                               result in
                             
                           })
                       
                        self!.loadScreen.isHidden = false
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainTB")
                        UIApplication.shared.keyWindow?.rootViewController = initialViewController
                           
                           isLoggedIn = true
                           if(!mainID.isEmpty){
                               DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                   let name = Notification.Name(rawValue: "openOsago")
                                   NotificationCenter.default.post(name: name, object: nil, userInfo:["id":mainID])
                               }
                              
                           }
                       } else {
                           print("LOCKED")
                       }
                   }
               }
           } else {
               
           }
    }

}

func codeSaved(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}

