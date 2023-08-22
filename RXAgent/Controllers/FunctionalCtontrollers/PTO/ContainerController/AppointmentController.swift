//
//  AppointmentController.swift
//  RXAgent
//
//  Created by RX Group on 22.06.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import UIKit

extension Notification.Name {
    public static let nextStep = Notification.Name(rawValue: "nextStep")
}

struct Maintence{
    var tipId:Int = 0
    var dateTime:String = ""
    var clientName:String = ""
    var clientPhone:String = ""
    var vehicleMarkModel:String = ""
    var vehicleGosnumber:String = ""
    var comment:String = ""
    var vehicleCategoryID:Int = 0
    var sourceRecord:Int = 3
    var createContractorId:Int = 0
    var mainPrice:Int = 0
    var addPrice:Int = 0
    var totalPrice:Int = 0
    var haveFireExtinguisher:Bool = false
    var haveFirstAidKit:Bool = false
    var haveEmergencyStopSign:Bool = false
    var haveWindscreen:Bool = false
    
    var asDictionary : [String:Any] {
      let mirror = Mirror(reflecting: self)
      let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
        guard let label = label else { return nil }
        return (label, value)
      }).compactMap { $0 })
      return dict
    }
}


class AppointmentController: UIViewController {
    
    var container: ContainerViewController!
    @IBOutlet weak var stepper: CalcStepperView!
    @IBOutlet weak var nextStepButton: UIButton!
    @IBOutlet weak var descriptionLbl: UILabel!
    let descriptions = ["Выберите категорию","Выберите дату и время","Выберите пункт ТО","Укажите информацию о клиенте","Укажите стоимость ТО","Выберите дополнительные услуги"]
    
    
    var maintance = Maintence()
    var currentStep = 0
    var maxSteps = 5
    var isLoaded = false
    
    enum Steps:Int{
        case category
        case date
        case address
        case clientInfo
        case cost
        case additional
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUP()
        self.addObserver()
        
    }
    
    fileprivate func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.nextStepAction(_:)), name: .nextStep, object: nil)
    }
    
   fileprivate func setUP(){
        stepper.countItems = maxSteps
        stepper.activeItem = 0
        self.configStep(index: currentStep)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func configStep(index: Int){
        nextStepButton.isHidden = index == 0 || index == 2
        nextStepButton.setImage(index + 1 == maxSteps ? UIImage(named: "sendBtn"):UIImage(named: "nextBtn"), for: .normal)
        descriptionLbl.text = descriptions[index]
        let step = Steps(rawValue: index)
        switch step {
        case .category:
            container!.segueIdentifierReceivedFromParent("firstStep")
        case .date:
            container!.segueIdentifierReceivedFromParent("secondStep")
        case .address:
            container!.segueIdentifierReceivedFromParent("thirdStep")
        case .clientInfo:
            container!.segueIdentifierReceivedFromParent("fourStep")
        case .cost:
            container!.segueIdentifierReceivedFromParent("fiveStep")
        case .additional:
            container!.segueIdentifierReceivedFromParent("sixStep")
        case .none:
            break
            
        }
        stepper.nextStep()
        
    }
    
    @IBAction func nextStepAction(_ sender: Any) {
        if(currentStep == 0){
            maintance.vehicleCategoryID = Category.sharedInstance().currentCategoryID
        }
        
        if(currentStep == 1){
            if(!DatePTOModel.sharedInstance().timeChoosen){
                self.setMessage("Для продолжения необходимо выбрать время записи")
                return
            }else{
                maintance.dateTime = DatePTOModel.sharedInstance().choosenDateFormated + "T" + DatePTOModel.sharedInstance().choosenTime
            }
            
        }
        
        if(currentStep == 2){
            stepper.countItems = Address.sharedInstance().needAdditionalParam ? 6 : 5
            maxSteps = Address.sharedInstance().needAdditionalParam ? 6 : 5
            maintance.tipId = Address.sharedInstance().currentAddress.id
        }
        
        if(currentStep == 3){
            if((container.currentViewController as! ParametersController).parameters.paramReady){
                maintance.clientName = (container.currentViewController as! ParametersController).parameters.name
                maintance.clientPhone = (container.currentViewController as! ParametersController).parameters.phone
                maintance.vehicleMarkModel = (container.currentViewController as! ParametersController).parameters.mark
                maintance.vehicleGosnumber = (container.currentViewController as! ParametersController).parameters.gosnumber
                maintance.comment = (container.currentViewController as! ParametersController).parameters.comment
            }else{
                self.setMessage("Все отмеченые поля должны быть заполнены полностью")
                return
            }
            
        }
        
        if(currentStep == 4){
            if(Paiment.sharedInstance().readyToPay){
                maintance.mainPrice = Paiment.sharedInstance().paiment!.mainPrice
                maintance.addPrice = Paiment.sharedInstance().paiment!.addPrice
                maintance.totalPrice = Paiment.sharedInstance().paiment!.totalPrice
                maintance.createContractorId = Int(String(format: "%04d", Profile.shared.profile?.contractor?.id ?? 0))!
                if(!Address.sharedInstance().needAdditionalParam){
                    self.sendMaintence()
                    return
                }
                
            }else{
                self.setMessage("Для продолжения необходимо заполнить все поля")
                return
            }
        }
        
        if(currentStep == 5){
            maintance.haveEmergencyStopSign = Address.sharedInstance().currentAddress.haveEmergencyStopSign!
            maintance.haveFireExtinguisher = Address.sharedInstance().currentAddress.haveFireExtinguisher!
            maintance.haveFirstAidKit = Address.sharedInstance().currentAddress.haveFirstAidKit!
            maintance.haveWindscreen = Address.sharedInstance().currentAddress.haveWindscreen!
            self.sendMaintence()
            return
        }
        
        
        if(currentStep < maxSteps){
            currentStep+=1
            self.configStep(index: currentStep)
        }
        
    }
    
    func sendMaintence(){
        if(!isLoaded){
            isLoaded = true
            postRequest(JSON: maintance.asDictionary, URLString: newDomain + "/api/v1/Maintenances",needSecretKey: true, completion: {
                result in
                DispatchQueue.main.async {
                    if(result["id"] as? Int != nil){
                        let storyboard = UIStoryboard(name: "PTO", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier: "donePTO") as! DonePTOController
                        viewController.maintence = self.maintance
                        TORecords.shared.loadTORecords { (loaded, records) in
                            DatePTOModel.sharedInstance().reloadModel()
                            self.isLoaded = false
                            self.navigationController?.pushViewController(viewController , animated: true)
                        }
                        
                    }else{
                        self.setMessage("Произошла ошибка, попробуйте еще раз.")
                        return
                    }
                }
                
            })
        }
    }
    
    @IBAction func back(_ sender: Any) {
        let alert = UIAlertController(title: "Внимание", message: "Вы действительно хотите прервать заполнение заявки?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
           self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "container"{
            container = (segue.destination as! ContainerViewController)
            container.animationDurationWithOptions = (0.2, .curveEaseIn)
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

//MARK: - Делегаты для свайпа
extension AppointmentController:UIGestureRecognizerDelegate{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (navigationController?.viewControllers.count ?? 0) > 1
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
