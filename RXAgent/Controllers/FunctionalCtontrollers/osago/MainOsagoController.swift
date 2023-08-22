//
//  MainOsagoController.swift
//  RXAgent
//
//  Created by RX Group on 05/08/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

var currentView = 0

class MainOsagoController: UIViewController,UIGestureRecognizerDelegate,StepperViewDelegate {

    @IBOutlet weak var steper: StepperView!
    var containerViewController: InsaranceOSAGOController?
    var ownerViewController: OwnerController?
    var vehicleController: VehicleController?
    var driverController: DriverController?
    var cardController: CardController?
    var propertyController: PropertyController?
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var nextStepBtn: UIButton!
    @IBOutlet weak var emptylbl: UILabel!
    @IBOutlet weak var stepNameLbl: UILabel!
    @IBOutlet weak var insuranceView: UIView!
    @IBOutlet weak var ownerView: UIView!
    @IBOutlet weak var vehicleContainer: UIView!
    @IBOutlet weak var driverContainer: UIView!
    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var propertyContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
      
       
        
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: NSNotification.Name(rawValue: "closeosago"), object: nil)
        
        
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        activeItem = 1
        steper.count = 5
        if(isEdit){
            if(!hasDKPInsurance && !hasRegInsurance){
                countRowsOwner=2
                countRows = 2
            }
            if(hasDKPInsurance && !hasRegInsurance){
                countRowsOwner=3
                 countRows = 3
            }
            if(!hasDKPInsurance && hasRegInsurance){
                countRowsOwner=3
                 countRows = 3
            }
            if(hasDKPInsurance && hasRegInsurance){
                countRowsOwner=4
                 countRows = 4
            }
            closeBtn.setImage(UIImage(named: "close"), for: .normal)
            var stepCount = 4
            if(isOwner){
                stepCount -= 1
            }
            if(isMultiDrive){
                stepCount -= 1
            }
            steper.count = stepCount
            steper.maxIndex = stepCount
            steper.setNeedsDisplay()
        }
        steper.delegate=self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @objc func close(){
        self.dismiss(animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? InsaranceOSAGOController,
            segue.identifier == "insuranceSegue" {
            vc.containerViewController = self
            containerViewController = vc
        }
        if let vc = segue.destination as? OwnerController,
            segue.identifier == "ownerSegue" {
            vc.containerViewController = self
            ownerViewController = vc
        }
        
        if let vc = segue.destination as? VehicleController,
            segue.identifier == "vehicleSegue" {
            vc.containerViewController = self
            vehicleController = vc
        }
        
        if let vc = segue.destination as? DriverController,
            segue.identifier == "driverSegue" {
            vc.containerViewController = self
            driverController = vc
        }
        
        if let vc = segue.destination as? CardController,
            segue.identifier == "cardSegue" {
            vc.containerViewController = self
            cardController = vc
        }
        
        if let vc = segue.destination as? PropertyController,
            segue.identifier == "propertySegue" {
            vc.containerViewController = self
            propertyController = vc
        }
    }

    @IBAction func back(_ sender: Any) {
        
        if(isEdit){
            isEdit=false
            self.dismiss(animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Внимание", message: "Вы действительно хотите прервать заполнение заявки?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
                clearAgregator()
               self.navigationController?.popViewController(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func choseSteper(isOwner: Bool){
        if(isOwner){
             steper.count = 5
        }else{
             steper.count = 6
        }
        steper.setNeedsDisplay()
    }
  
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (navigationController?.viewControllers.count ?? 0) > 1
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func nextStep(_ sender: Any) {
        if(isEdit){
            var tempMaxIndex = steper.count
            var tempActive = activeItem
            if(isOwner){
                if(tempActive==1){
                    tempActive+=1
                }
            }else{
                tempMaxIndex-=1
            }
         //  print(tempActive, tempMaxIndex)
            if(tempActive == tempMaxIndex){
                nextStepBtn.setImage(UIImage(named: "doneBtn"), for: .normal)

            }else if(tempActive<tempMaxIndex){
                nextStepBtn.setImage(UIImage(named: "nextBtn"), for: .normal)
            }else{
                self.checkEmptyController()
                return
            }
        }
       
        if(activeItem==1){
            if((containerViewController?.drawEmptyPhotos())!){
                emptylbl.isHidden = true
                steper.nextItem()
                if(isOwner){
                    vehicleContainer.isHidden=false
                    vehicleController?.table.reloadData()
                    stepNameLbl.text = "Транспортное средство"
                }else{
                     stepNameLbl.text = "Собственник"
                     ownerView.isHidden = false
                    if(!hasDKPInsurance && !hasRegInsurance){
                        countRowsOwner=2
                    }
                    if(hasDKPInsurance && !hasRegInsurance){
                        countRowsOwner=3
                    }
                    if(!hasDKPInsurance && hasRegInsurance){
                        countRowsOwner=3
                    }
                    if(hasDKPInsurance && hasRegInsurance){
                        countRowsOwner=4
                    }
                     ownerViewController?.table1owner.reloadData()
                     ownerViewController?.table2owner.reloadData()
                }
                insuranceView.isHidden = true
                driverContainer.isHidden = true
                cardContainer.isHidden = true
                propertyContainer.isHidden = true
               
                return
                
            }else{
                emptylbl.text = "Заполните все необходимые поля"
                emptylbl.isHidden = false
            }
        }
        if(activeItem==2){
            if((ownerViewController?.drawEmptyPhotos())!){
                emptylbl.isHidden = true
                vehicleContainer.isHidden = false
                ownerView.isHidden = true
                insuranceView.isHidden = true
                driverContainer.isHidden = true
                cardContainer.isHidden = true
                propertyContainer.isHidden = true
                vehicleController?.table.reloadData()
                stepNameLbl.text = "Транспортное средство"
                steper.nextItem()
                return
            }else{
                emptylbl.text = "Заполните все необходимые поля"
                emptylbl.isHidden = false
            }
        }
        if(activeItem==3){
            if((vehicleController?.drawEmptyPhotos())!){
                emptylbl.isHidden = true
                vehicleContainer.isHidden=true
                ownerView.isHidden = true
                insuranceView.isHidden = true
                driverContainer.isHidden = false
                cardContainer.isHidden = true
                propertyContainer.isHidden = true
                stepNameLbl.text = "Водители"
                //подставить
                steper.nextItem()
                return
            }else{
                emptylbl.text = "Заполните все необходимые поля"
                emptylbl.isHidden = false
            }
        }
        if(activeItem==4){
            if((driverController?.drawEmptyPhotos())!){
                emptylbl.isHidden = true
                vehicleContainer.isHidden=true
                ownerView.isHidden = true
                insuranceView.isHidden = true
                driverContainer.isHidden = true
                cardContainer.isHidden = false
                propertyContainer.isHidden = true
                stepNameLbl.text = (hidePayCard ?? false) ? "Время для оплаты полиса":"Карта и время работы"
                //подставить
                steper.nextItem()
                return
            }else{
                emptylbl.text = "Заполните все необходимые поля"
                emptylbl.isHidden = false
            }
        }
        if(activeItem==5){
            if((cardController?.drawEmptyPhotos())!){
                emptylbl.isHidden = true
                vehicleContainer.isHidden=true
                ownerView.isHidden = true
                insuranceView.isHidden = true
                driverContainer.isHidden = true
                cardContainer.isHidden = true
                propertyContainer.isHidden = false
                stepNameLbl.text = "Условия"
                nextStepBtn.setImage(UIImage(named: "doneBtn"), for: .normal)
                steper.nextItem()
                propertyController?.table.reloadData()
                
                return
            }else{
                emptylbl.text = "Заполнены не все данные"
                emptylbl.isHidden = false
            }
        }
        if(activeItem==6){
            if((propertyController?.drawEmptyPhotos())!){
                self.checkEmptyController()
                emptylbl.isHidden = true
            }else{
                emptylbl.text = "Заполните все необходимые поля"
                emptylbl.isHidden = false
            }
        }else{
            nextStepBtn.setImage(UIImage(named: "nextBtn"), for: .normal)
        }
        
    }
  
    func checkEmptyController(){
        if(!isEdit){
        if(!checkInsuranceAccess().isEmptIns){
            self.stepClicked(index: 1)
            activeItem=1
            steper.setNeedsDisplay()
          _ = containerViewController?.drawEmptyPhotos()
            return
        }
        if(!isOwner){
            if(!checkOwnerAccess().isEmptIns){
                self.stepClicked(index: 2)
                activeItem=2
                steper.setNeedsDisplay()
                if(!hasDKPInsurance && !hasRegInsurance){
                    countRowsOwner=2
                }
                if(hasDKPInsurance && !hasRegInsurance){
                    countRowsOwner=3
                }
                if(!hasDKPInsurance && hasRegInsurance){
                    countRowsOwner=3
                }
                if(hasDKPInsurance && hasRegInsurance){
                    countRowsOwner=4
                }
                ownerViewController?.table1owner.reloadData()
                ownerViewController?.table2owner.reloadData()
                _ = ownerViewController?.drawEmptyPhotos()
                return
            }
            if(!checkVehicleAccess().isEmptIns){
                self.stepClicked(index: 3)
                activeItem=3
                steper.setNeedsDisplay()
                _ = vehicleController?.drawEmptyPhotos()
                return
            }
            
            if(!checkDriverAccess().isEmptIns){
                self.stepClicked(index: 4)
                activeItem=4
                steper.setNeedsDisplay()
                _ = driverController?.drawEmptyPhotos()
                return
            }
            if(!cardValidate()){
                self.stepClicked(index: 5)
                activeItem=5
                steper.setNeedsDisplay()
                _ = cardController?.drawEmptyPhotos()
                return
            }
            if(!checkPropertyAccess().isEmptIns){
                self.stepClicked(index: 6)
                activeItem=6
                steper.setNeedsDisplay()
                _ = propertyController?.drawEmptyPhotos()
                return
            }
        }else{
            if(!checkVehicleAccess().isEmptIns){
                self.stepClicked(index: 2)
                activeItem=3
                steper.setNeedsDisplay()
                _ = vehicleController?.drawEmptyPhotos()
                return
            }
            
            if(!checkDriverAccess().isEmptIns){
                self.stepClicked(index: 3)
                activeItem=4
                steper.setNeedsDisplay()
                _ = driverController?.drawEmptyPhotos()
                return
            }
            if(!cardValidate()){
                self.stepClicked(index: 4)
                activeItem=5
                steper.setNeedsDisplay()
                _ = cardController?.drawEmptyPhotos()
                return
            }
            if(!checkPropertyAccess().isEmptIns){
                self.stepClicked(index: 5)
                activeItem=6
                steper.setNeedsDisplay()
                _ = propertyController?.drawEmptyPhotos()
                return
            }
        }
        self.sendJSONtoServer()
        }else{
            if(!checkInsuranceAccess().isEmptIns){
                self.stepClicked(index: 1)
                activeItem=1
                steper.setNeedsDisplay()
                _ = containerViewController?.drawEmptyPhotos()
                return
            }
            if(!isOwner){
                if(!checkOwnerAccess().isEmptIns){
                    self.stepClicked(index: 2)
                    activeItem=2
                    steper.setNeedsDisplay()
                    if(!hasDKPInsurance && !hasRegInsurance){
                        countRowsOwner=2
                    }
                    if(hasDKPInsurance && !hasRegInsurance){
                        countRowsOwner=3
                    }
                    if(!hasDKPInsurance && hasRegInsurance){
                        countRowsOwner=3
                    }
                    if(hasDKPInsurance && hasRegInsurance){
                        countRowsOwner=4
                    }
                    ownerViewController?.table1owner.reloadData()
                    ownerViewController?.table2owner.reloadData()
                    _ = ownerViewController?.drawEmptyPhotos()
                    return
                }
                if(!checkVehicleAccess().isEmptIns){
                    self.stepClicked(index: 3)
                    activeItem=3
                    steper.setNeedsDisplay()
                    _ = vehicleController?.drawEmptyPhotos()
                    return
                }
                
                if(!checkDriverAccess().isEmptIns){
                    self.stepClicked(index: 4)
                    activeItem=4
                    steper.setNeedsDisplay()
                    _ = driverController?.drawEmptyPhotos()
                    return
                }
            }else{
                if(!checkVehicleAccess().isEmptIns){
                    self.stepClicked(index: 2)
                    activeItem=3
                    steper.setNeedsDisplay()
                    _ = vehicleController?.drawEmptyPhotos()
                    return
                }
                
                if(!checkDriverAccess().isEmptIns){
                    self.stepClicked(index: 3)
                    activeItem=4
                    steper.setNeedsDisplay()
                    _ = driverController?.drawEmptyPhotos()
                    return
                }
               
            }
            self.openProperty()
        }
        
        
    }
    
    func stepClicked(index: Int) {
        nextStepBtn.setImage(UIImage(named: "nextBtn"), for: .normal)
        if(isEdit){
            let tempMaxIndex = steper.count
            var tempActive = activeItem
            if(isOwner){
                if(tempActive>=1){
                    tempActive-=1
                }
            }
            if(tempActive == tempMaxIndex){
                nextStepBtn.setImage(UIImage(named: "doneBtn"), for: .normal)
                
            }else if(tempActive<tempMaxIndex){
                nextStepBtn.setImage(UIImage(named: "nextBtn"), for: .normal)
            }else{
                self.checkEmptyController()
                return
            }
        }
        if(index==1){
                emptylbl.isHidden = true
                vehicleContainer.isHidden=true
                ownerView.isHidden = true
                insuranceView.isHidden=false
                driverContainer.isHidden = true
                cardContainer.isHidden = true
            propertyContainer.isHidden = true
            stepNameLbl.text = "Страхователь"
        }
        if(index==2){
             if(isOwner){
                emptylbl.isHidden = true
                vehicleContainer.isHidden=false
                ownerView.isHidden = true
                insuranceView.isHidden=true
                 driverContainer.isHidden = true
                cardContainer.isHidden = true
                propertyContainer.isHidden = true
                stepNameLbl.text = "Транспортное средство"
                vehicleController?.table.reloadData()
             }else{
                if(!hasDKPInsurance && !hasRegInsurance){
                    countRowsOwner=2
                }
                if(hasDKPInsurance && !hasRegInsurance){
                    countRowsOwner=3
                }
                if(!hasDKPInsurance && hasRegInsurance){
                    countRowsOwner=3
                }
                if(hasDKPInsurance && hasRegInsurance){
                    countRowsOwner=4
                }
                ownerViewController?.table1owner.reloadData()
                ownerViewController?.table2owner.reloadData()
                emptylbl.isHidden = true
                vehicleContainer.isHidden=true
                ownerView.isHidden = false
                insuranceView.isHidden=true
                 driverContainer.isHidden = true
                cardContainer.isHidden = true
                propertyContainer.isHidden = true
                stepNameLbl.text = "Собственник"
            }
        }
        if(index==3){
            if(isOwner){
                emptylbl.isHidden = true
                vehicleContainer.isHidden=true
                ownerView.isHidden = true
                insuranceView.isHidden=true
                driverContainer.isHidden = false
                cardContainer.isHidden = true
                propertyContainer.isHidden = true
                stepNameLbl.text = "Водители"
            }else{
                emptylbl.isHidden = true
                vehicleContainer.isHidden=false
                ownerView.isHidden = true
                insuranceView.isHidden=true
                driverContainer.isHidden = true
                cardContainer.isHidden = true
                propertyContainer.isHidden = true
                stepNameLbl.text = "Транспортное средство"
                vehicleController?.table.reloadData()
            }
        }
        if(index==4){
            if(isOwner){
                emptylbl.isHidden = true
                vehicleContainer.isHidden=true
                ownerView.isHidden = true
                insuranceView.isHidden=true
                driverContainer.isHidden = true
                cardContainer.isHidden = false
                propertyContainer.isHidden = true
                stepNameLbl.text = (hidePayCard ?? false) ? "Время для оплаты полиса":"Карта и время работы"
            }else{
                emptylbl.isHidden = true
                vehicleContainer.isHidden=true
                ownerView.isHidden = true
                insuranceView.isHidden=true
                driverContainer.isHidden = false
                cardContainer.isHidden = true
                propertyContainer.isHidden = true
                stepNameLbl.text = "Водители"
            }
        }
        if(index==5){
            if(isOwner){
                stepNameLbl.text = "Условия"
                emptylbl.isHidden = true
                vehicleContainer.isHidden=true
                ownerView.isHidden = true
                insuranceView.isHidden=true
                driverContainer.isHidden = true
                cardContainer.isHidden = true
                propertyContainer.isHidden = false
                nextStepBtn.setImage(UIImage(named: "doneBtn"), for: .normal)
            }else{
                stepNameLbl.text = (hidePayCard ?? false) ? "Время для оплаты полиса":"Карта и время работы"
                emptylbl.isHidden = true
                vehicleContainer.isHidden=true
                ownerView.isHidden = true
                insuranceView.isHidden=true
                driverContainer.isHidden = true
                cardContainer.isHidden = false
                propertyContainer.isHidden = true
            }
        }
        if(index==6){
            stepNameLbl.text = "Условия"
            emptylbl.isHidden = true
            vehicleContainer.isHidden=true
            ownerView.isHidden = true
            insuranceView.isHidden=true
            driverContainer.isHidden = true
            cardContainer.isHidden = true
            propertyContainer.isHidden = false
            nextStepBtn.setImage(UIImage(named: "doneBtn"), for: .normal)
        }
      
    }
   
    func openProperty(){
        let storyboard = UIStoryboard(name: "OSAGO", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "propertyVC") as! PropertyController
        viewController.isEdit = true
        self.present(viewController, animated: true)
    }
    
    func sendJSONtoServer()  {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "offerVC") as! OfferController
        viewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(viewController, animated: true)
        }
}
