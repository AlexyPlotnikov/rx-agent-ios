//
//  CalculatorController.swift
//  RXAgent
//
//  Created by RX Group on 07/02/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

struct OwnerModel {
    var regionID: String = ""
    var regionName: String = ""
    var cityID:String = ""
    var cityName:String = ""
}
var ownerModel:OwnerModel!

struct VehicleModel {
    var power: String = ""
    var categoryID:categoryVehicle = .b
}
var vehicleModel:VehicleModel!

struct DriverModel{
      var birthDayDate:String = "Не указано"
      var birthSendDate:String = ""
      var startTimeDate:String = "Не указано"
      var startSendDate:String = ""
      var kbm:String = "Не указано"
      var kbmID:String = ""
      var nameDriver:String = ""
      var serialDriver:String = ""
      var numberDriver:String = ""
      var KBC:Double = 10000.0
  }

   var driver:DriverModel!
   var driversArray:NSMutableArray = []
class CalculatorController: UIViewController,UIGestureRecognizerDelegate{
    
    @IBOutlet weak var stepper: CalcStepperView!
    var currentStep:Int = 0
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var ownerContainer: UIView!
    @IBOutlet weak var vehicleContainer: UIView!
    @IBOutlet weak var driverContainer: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        ownerModel = OwnerModel()
        vehicleModel = VehicleModel()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func back(_ sender: Any) {
         self.navigationController?.popViewController(animated: true)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (navigationController?.viewControllers.count ?? 0) > 1
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func nextStep(_ sender: Any) {
        if(ownerModel.regionID != "" && currentStep==0){
            //1 этап
            if(needCity){
                if(ownerModel.cityName == "Другие города и населенные пункты" || !ownerModel.cityName.isEmpty){
                    stepper.nextStep()
                    ownerContainer.isHidden = true
                    vehicleContainer.isHidden = false
                    currentStep += 1
                    titleLbl.text = "Транспорт"
                    return
                }else{
                    setMessage("Заполнены не все поля")
                }
            }else{
                ownerContainer.isHidden = true
                vehicleContainer.isHidden = false
                stepper.nextStep()
                currentStep += 1
                titleLbl.text = "Транспорт"
                return
            }
        }else{
            if(currentStep==0){
                setMessage("Заполнены не все поля")
            }
        }
            
            
            if(currentStep == 1){
            //2 этап
            if(vehicleModel.categoryID == .b){
                if(!vehicleModel.power.isEmpty){
                    vehicleContainer.isHidden = true
                    driverContainer.isHidden = false
                    stepper.nextStep()
                    currentStep += 1
                    titleLbl.text = "О полисе"
                    return
                }else{
                   setMessage("Заполнены не все поля")
                }
            }else{
                vehicleContainer.isHidden = true
                driverContainer.isHidden = false
                stepper.nextStep()
                currentStep += 1
                titleLbl.text = "О полисе"
                return
            }
            }
                //3 этап
            if(currentStep == 2){
                if(!isMultiDrive){
                    var ready = 0
                    for i in 0..<countDriver{
                        if((driversArray[i] as! DriverModel).birthDayDate == "Не указано" || (driversArray[i] as! DriverModel).startTimeDate == "Не указано" || (driversArray[i] as! DriverModel).KBC == 1000 || (driversArray[i] as! DriverModel).kbm == "Не указано"){
                            ready += 1
                        }
                    }
                    if(ready==0){
                        self.sendCalculator()
                    }else{
                        setMessage("Заполнены не все поля")
                    }
                }else{
                    self.sendCalculator()
                }
            }
    }
    func sendCalculator(){
       let tempArray:NSMutableArray = []
       for i in 0..<countDriver{
           tempArray.add(driversArray[i])
       }
       let maxkbc = (tempArray.max(by: {($0 as! DriverModel).KBC < ($1 as! DriverModel).KBC}) as! DriverModel).KBC
       let minkbm = (tempArray.min(by: {($0 as! DriverModel).kbm < ($1 as! DriverModel).kbm}) as! DriverModel)
        var dict = ["isIndividual":"true",
            "kbc":"\(isMultiDrive ? "" : "\(maxkbc)")",
            "minKBM":"\(isMultiDrive ? "1.17" : minkbm.kbm)",
           "region":"\(ownerModel.regionID)",
           "city":"\(ownerModel.cityID)",
           "category":"\(vehicleModel.categoryID.rawValue)",
           "drivers":"\(isMultiDrive ? "" : "\(countDriver)")",
           "period":"\(periodID)",
           "startDate":"\(dateStartForTable)",
           "target":"\(targetVehicleID)"
           ] as [String:Any]
        switch vehicleModel.categoryID {
            case .a:
                dict["withTrailer"] = trailerEmpty
            case .b:
                dict["power"] = power
            case .c:
                dict["withTrailer"] = trailerEmpty
                dict["maxMass16"] = !moreTon
            case .d:
                if(!transportation){
                    dict["maxSeats16"] = morePlaces
                 }
            case .e:
                dict["withTrailer"] = trailerEmpty
        }
        print(dict)
        postRequest(JSON: dict, URLString: "\(domain)v0/newEOSAGOCalculator", completion: {
               result in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "completeVC") as! CompleteCalculatorController
                   viewController.dict = result
                self.navigationController?.pushViewController(viewController, animated: true)

            }
              
        })
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
    var isInt: Bool {
        return Int(self) != nil
    }
}
