//
//  NeedInfoController.swift
//  RXAgent
//
//  Created by RX Group on 09.06.2020.
//  Copyright © 2020 RX Group. All rights reserved.
//

import UIKit


class NeedInfoController: UIViewController {

    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var creatorContainer: UIView!
    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var stepper: CalcStepperView!
    @IBOutlet weak var titleLbl: UILabel!
    var insurance:Insurance!
    @IBOutlet weak var loadingView: UIView!
    
    var step:Int = 0
    
    var needCreator:Bool = false
    var needCard:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(needCard){
            titleLbl.text = "Карта"
            cardContainer.isHidden=false
            creatorContainer.isHidden=true
            stepper.countItems = 2
        }else{
            titleLbl.text = "Данные заполнителя"
            stepper.countItems = 1
            cardContainer.isHidden=true
            creatorContainer.isHidden=false
            step = 1
        }
    }
    

  
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextStep(_ sender: Any) {
        if(step == 0){
            if(!cardNumber.isEmpty && !cardYear.isEmpty && !cardMonth.isEmpty && !cardCvc.isEmpty && !creditLastName.isEmpty && !creditFirstName.isEmpty){
                stepper.nextStep()
                step = 1
                titleLbl.text = "Данные заполнителя"
                cardContainer.isHidden=true
                creatorContainer.isHidden=false
                currentFullPolice["payCardPaymentSystem"] = "1"
                currentFullPolice["payCardFirstName"] = creditFirstName
                currentFullPolice["payCardLastName"] = creditLastName
                currentFullPolice["payCardMonth"] = cardMonth
                currentFullPolice["payCardYear"] = cardYear
                currentFullPolice["payCardNumber"] = cardNumber
                currentFullPolice["payCardCVC"] = cardCvc
                nextBtn.setImage(UIImage(named: "doneBtn"), for: .normal)
                return
            }else{
                setMessage("Укажите карту для оплаты")
            }
        }
        if(step == 1){
            if(!creatorInsurance.isEmpty && creatorPhone.count == 10){
                currentFullPolice["creatorFullName"] = creatorInsurance
                currentFullPolice["creatorPhone"] = creatorPhone
                currentFullPolice["agentComment"] = commentInsurance
                nextBtn.isEnabled = false
                loadingView.isHidden = false
                putRequest(JSON: currentFullPolice, URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)", completion: {
                    result in
                    if(self.insurance == nil){
                        //отправка в РХ
                        getPatchRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)/dispatch", completion: {
                            result in
                             DispatchQueue.main.async{
                            if(result["errors"] == nil){
                             isEdit=false
                             activeItem=1
                             clearAgregator()
                             
                                self.dismiss(animated: true, completion:{
                                    NotificationCenter.default.post(name: Notification.Name("close"), object: nil)
                                })
                            }else{
                                let errors = (result["errors"] as? NSArray)?[0] as? String ?? result["error"] as! String
                                self.nextBtn.isEnabled = true
                                self.loadingView.isHidden = true
                                self.setMessage(errors)
                            }
                            }
                        })
                    }else{
                        //отправка компаний в API
                        getPatchRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)/superDispatch?company=\(self.insurance.insuranceID!)", completion: {
                           result in
                           DispatchQueue.main.async{
                               self.dismiss(animated: true, completion: {
                                   NotificationCenter.default.post(name: Notification.Name("close"), object: nil)
                               })
                           }
                        })
                    }
                    
                })
            }else{
                setMessage("Поля заполнены не полностью")
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
