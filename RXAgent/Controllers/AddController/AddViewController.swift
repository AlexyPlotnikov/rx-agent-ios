//
//  AddViewController.swift
//  RXAgent
//
//  Created by RX Group on 28/01/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

class AddViewController: UIViewController,UIViewControllerTransitioningDelegate{
    
    struct Module{
        var name: String
        var imageName: String
        var controllerName:String
        var storyboardName:String
        var descriptionName:String
    }
    
    enum AddModule:Int{
       case osago = 0
       case calculator
       case mite
       case pto
       
    }
    

    @IBOutlet weak var table: UITableView!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.table.isUserInteractionEnabled=true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func openController(nameController:String, storyboardName:String){
        if(Profile.shared.profileLoaded){
            if(Profile.shared.profile!.contractor!.modules!.contains(8)){
                let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: nameController)
                self.navigationController?.pushViewController(viewController , animated: true)
                clearAgregator()
                self.table.isUserInteractionEnabled=false
                isEdit = false
            }else{
                setMessage("У Вас не подключен модуль Е-ОСАГО")
            }
        }
    }
    
   
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getModule(indexModule:Int) -> Module{
        let needModule = AddModule(rawValue: indexModule)
        switch needModule {
        case .osago:
            return Module(name: "Е-ОСАГО", imageName: "osagoIcon", controllerName: "osagoVC", storyboardName: "OSAGO",descriptionName: "Страхование без осмотра автомобиля и похода в офис")
        case .calculator:
            return Module(name: "Расчет Е-ОСАГО", imageName: "calcIcon", controllerName: "calcVC", storyboardName: "Calculator",descriptionName: "Расчет стоимости страхования автомобиля")
        case .pto:
            return Module(name: "Техосмотр", imageName: "TO", controllerName: "appointmentVC", storyboardName: "PTO",descriptionName: "Расчет стоимости страхования автомобиля")
        case .mite:
            return Module(name: "Антиклещ", imageName: "miteIcon", controllerName: "miteVC", storyboardName: "Mite",descriptionName: "Страхование от укуса клеща")
        case .none:
            return Module(name: "", imageName: "", controllerName: "", storyboardName: "", descriptionName: "")
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
    
    func reloadAllModulesPTO(){
        Category.reload()
        DatePTOModel.reload()
        Address.reload()
        Paiment.reload()
        
    }

}

extension AddViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:AddCell = self.table.dequeueReusableCell(withIdentifier: "cell") as! AddCell
        let module = self.getModule(indexModule: indexPath.row)
        cell.iconAdd.image = UIImage(named: module.imageName)
        cell.nameLbl.text = module.name
        cell.descriptionlbl.text = module.descriptionName

        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if(indexPath.row == 2){
//            TORecords.shared.getRecordInfo(canCreate: {
//                                            canCreate in
//                if(canCreate){
//                    self.reloadAllModulesPTO()
//                    self.openController(nameController: self.getModule(indexModule: indexPath.row).controllerName,storyboardName: self.getModule(indexModule: indexPath.row).storyboardName)
//
//                }else{
//                    self.setMessage("У Вас не подключен модуль запись на ТО")
//                }
//            })
//        }else{
        if(indexPath.row == 2){
            if(Profile.shared.profile?.region != nil){
                if(Profile.shared.profile?.contractor?.inviteType == 4){
                    MiteModel.sharedInstance().reload()
                }else{
                    self.setMessage("Вам необходимо активировать модуль, обратитесь в техническую поддержку по телефону +7 (383) 319-40-22")
                    return
                }
               
            }else{
                self.setMessage("Вам необходимо указать регион продаж, обратитесь в техническую поддержку по телефону +7 (383) 319-40-22")
                return
            }
        }
            self.openController(nameController: self.getModule(indexModule: indexPath.row).controllerName,storyboardName: self.getModule(indexModule: indexPath.row).storyboardName)
//        }
    
    }
}
