//
//  DriverCalcController.swift
//  RXAgent
//
//  Created by RX Group on 10/09/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit
import SafariServices

class DriverCalcController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
  
    enum TypeDate: Int {
        case startDate = 0
        case birthDayDriver = 1
        case startDriver = 2
    }
    enum TypePicker: Int {
        case period = 0
        case kbm = 1
    }
    var currentPicker:TypePicker!
    var currentType:TypeDate!
   
    var KBMArray:NSMutableArray = []
    
    @IBOutlet weak var table: UITableView!
    var nullField:UITextField!
    var picker:UIPickerView!
    var tempIndexKBM:Int = 4
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData), name: NSNotification.Name("reloadDriver"), object: nil)
        
        for _ in 0..<4{
            driver = DriverModel()
            driversArray.add(driver)
        }
        getDataMethod(key: "InsurancePeriods",getKey: "insurancePeriods", completion:{
            result in
            periodArray = result
        })

        getDataMethod(key: "KBMItems",getKey: "kbmItems", completion:{
            result in
            print(result)
            self.KBMArray = result
        })
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.init(localeIdentifier: "ru") as Locale
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        propertyDateStart = dateFormatter.string(from: Date())
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "YYYY-MM-dd"
        
        dateStartForTable = dateFormatter2.string(from: Date())
        table.reloadData()
        self.table.tableFooterView = UIView()
        self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
    }
    
    @objc func onDidReceiveData(){
        self.table.reloadData()
    }
    
    func getDataMethod(key: String, getKey : String, completion:@escaping (NSMutableArray)->Void){
//        if((UserDefaults.standard.array(forKey: key)) != nil){
//            let array = UserDefaults.standard.value(forKey: key) as! NSArray
//            completion(array.mutableCopy() as! NSMutableArray)
//        }else{
            getRequest(URLString: "\(domain)v0/\(key)", completion:{ result in
                DispatchQueue.main.async{
                    let array = result[getKey] as! NSArray
                    let defaults = UserDefaults.standard
                    defaults.set(array, forKey: key)
                    completion(array.mutableCopy() as! NSMutableArray)
                }
            })
            
//        }
    }
 
    func numberOfSections(in tableView: UITableView) -> Int {
   
        if(isMultiDrive){
            return 1
        }else{
            return 1 + countDriver
        }
    }
    
   
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.init(localeIdentifier: "ru") as Locale
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "YYYY-MM-dd"
        switch currentType {
        case .startDate:
            propertyDateStart = dateFormatter.string(from: sender.date)
            dateStartForTable = dateFormatter2.string(from: sender.date)
        case .birthDayDriver:
            var tempDriver = (driversArray[sender.tag] as! DriverModel)
            tempDriver.birthDayDate = dateFormatter.string(from: sender.date)
            tempDriver.birthSendDate = dateFormatter2.string(from: sender.date)
            driversArray[sender.tag]  = tempDriver
        case . startDriver:
            var tempDriver = (driversArray[sender.tag] as! DriverModel)
            tempDriver.startTimeDate = dateFormatter.string(from: sender.date)
            tempDriver.startSendDate = dateFormatter2.string(from: sender.date)
            driversArray[sender.tag]  = tempDriver
        case .none:
            print("NONE")
        }
        table.reloadData()
    }
    
    func showPicker(_ string: String, index:Int){
        let alert = UIAlertController(title: string, message: "\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        alert.isModalInPopover = true
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view //to set the source of your alert
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // you can set this as per your requirement.
            popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
        }
        let pickerFrame = CGRect(x: 17, y: 52, width: 300, height: 150)
        picker = UIPickerView(frame: pickerFrame)
        picker.delegate = self
        picker.dataSource = self
        picker.tag = index
        alert.addAction(UIAlertAction(title: "Готово", style: .default, handler: {
            _ in
            self.table.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.view.addSubview(picker)
        present(alert, animated: true, completion: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch currentPicker {
        case .period:
            tempIndexPeriod = row
            let period = periodArray[row] as! [String:Any]
            periodTitle = "\(period["title"] as! String)"
            periodID = period["id"] as! Int
        case .kbm:
            tempIndexKBM = row
            let period =  KBMArray[row] as! [String:Any]
            var tempDriver = (driversArray[pickerView.tag] as! DriverModel)
            tempDriver.kbm = "\((period["value"] as! NSNumber).doubleValue)"
            tempDriver.kbmID = "\(period["id"] as! Int)"
            driversArray[pickerView.tag] = tempDriver
        case .none:
            print("NONE")
        }
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (currentPicker == .period){
          let period = periodArray[row] as! [String:Any]
          periodTitle = "\(period["title"] as! String)"
          periodID = period["id"] as! Int
            return periodTitle
        }else{
         
          let period =  KBMArray[row] as! [String:Any]
          var tempDriver = (driversArray[pickerView.tag] as! DriverModel)
            tempDriver.kbm = "\((period["value"] as! NSNumber).doubleValue)"
          tempDriver.kbmID = "\(period["id"] as! Int)"
          driversArray[pickerView.tag] = tempDriver
            return  tempDriver.kbm
            
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(currentPicker == .period){
            return periodArray.count
        }else{
            return KBMArray.count
        }
    }
    
    func showDataPicker(section:Int) {
        let datePickerView = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        } 
            datePickerView.datePickerMode = .date
            datePickerView.locale = NSLocale.init(localeIdentifier: "ru") as Locale
            datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
            datePickerView.tag = section
            nullField = UITextField(frame: .zero)
            nullField.spellCheckingType = .no
       
        let toolbar = UIToolbar()
              toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: UIBarButtonItem.Style.done, target: self, action: #selector(donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
             
              
              toolbar.setItems([spaceButton,doneButton], animated: false)
              nullField.inputAccessoryView = toolbar
              nullField.inputView = datePickerView
              nullField.becomeFirstResponder()
              self.view.addSubview(nullField)
        switch currentType {
        case .startDate:
               datePickerView.minimumDate = (Calendar.current.date(byAdding: .day, value: 0, to: Date())!)
               datePickerView.date = (Calendar.current.date(byAdding: .day, value: 0, to: Date())!)
               datePickerView.maximumDate = (Calendar.current.date(byAdding: .day, value: 60, to: Date())!)
        case .birthDayDriver:
               datePickerView.date = (Calendar.current.date(byAdding: .year, value: -18, to: Date())!)
               datePickerView.maximumDate = (Calendar.current.date(byAdding: .year, value: -18, to: Date())!)
               nullField.delegate = self
        case .startDriver:
               datePickerView.maximumDate = (Calendar.current.date(byAdding: .day, value: 0, to: Date())!)
               nullField.delegate = self
        case .none:
              print("NONE")
        }
       
       
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.init(localeIdentifier: "ru") as Locale
        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "YYYY-MM-dd"
        
        switch currentType {
        case .startDate:
            propertyDateStart = dateFormatter.string(from: datePickerView.date)
            dateStartForTable = dateFormatter2.string(from: datePickerView.date)
        case .birthDayDriver:
            var tempDriver = (driversArray[section] as! DriverModel)
            tempDriver.birthDayDate = dateFormatter.string(from: datePickerView.date)
            tempDriver.birthSendDate = dateFormatter2.string(from: datePickerView.date)
            driversArray[section]  = tempDriver
            self.table.reloadData()
        case .startDriver:
            var tempDriver = (driversArray[section] as! DriverModel)
            tempDriver.startTimeDate = dateFormatter.string(from: datePickerView.date)
            tempDriver.startSendDate = dateFormatter2.string(from: datePickerView.date)
            driversArray[section]  = tempDriver
            self.table.reloadData()
        case .none:
            print("NONE")
        }
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        for i in 0..<countDriver{
            var tempDriver = (driversArray[i] as! DriverModel)
            if(tempDriver.KBC == 10000.0){
                if(tempDriver.birthDayDate != "Не указано" && tempDriver.startTimeDate != "Не указано"){
                    let birthValue = Date().years(from:convertToDate(string: tempDriver.birthSendDate))
                    let startValue = Date().years(from:convertToDate(string: tempDriver.startSendDate))
                        getPatchRequest(URLString: "\(domain)v0/EOSAGOPolicies/kbc/\(birthValue)/\(startValue)", completion: {
                            result in
                       
                            tempDriver.KBC = result["kbc"] as! Double
                            driversArray[i] = tempDriver
                          
                        })
                    break
                }
            }
        }
    }
    
    func convertToDate(string:String)->Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from:string)!
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section==0){
            return 0
        }else{
            return 30
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section==0){
            if(isMultiDrive){
                return 3
            }else{
                return 4
            }
        }else{
            return 4
        }
        
       
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section==0){
            if(indexPath.row==3){
                return 90
            }else{
                return 65
            }
        }else{
            return 65
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section==0){
            if(indexPath.row==0 || indexPath.row==1){
               
                    let cellReuseIdentifier = "celltype"
                    let cell:DriverCalcCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! DriverCalcCell
                 DispatchQueue.main.async{
                    if(indexPath.row==0){
                        cell.titleLbl.text = propertyDateStart
                        cell.subtitlelbl.text = "Дата начала"
                    }else{
                        cell.titleLbl.text = periodTitle
                        cell.subtitlelbl.text = "Срок страхования"
                    }
                }
                    
                    return cell
            
            }else  if(indexPath.row==2){
                let cellReuseIdentifier = "cellSwitch"
                let cell:DriverCalcCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! DriverCalcCell
                 DispatchQueue.main.async{
                    cell.switcher.addTarget(self, action: #selector(self.chooseMultidrive), for: .valueChanged)
                }
                return cell
            }else{
                let cellReuseIdentifier = "cellSegment"
                let cell:DriverCalcCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! DriverCalcCell
                 DispatchQueue.main.async{
                    cell.segmentController.addTarget(self, action: #selector(self.chooseDriverCount), for: .valueChanged)
                }
                return cell
            }
        }else{
            if(indexPath.row==0){
                let cellReuseIdentifier = "celltype"
                let cell:DriverCalcCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! DriverCalcCell
                cell.titleLbl.text = (driversArray[indexPath.section-1] as! DriverModel).birthDayDate
                cell.subtitlelbl.text = "Дата рождения"
                
                return cell
            }else if(indexPath.row==1){
                let cellReuseIdentifier = "celltype"
                let cell:DriverCalcCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! DriverCalcCell
                cell.titleLbl.text = (driversArray[indexPath.section-1] as! DriverModel).startTimeDate
                cell.subtitlelbl.text = "Дата начала стажа"
                
                return cell
            }else if(indexPath.row==2){
                let cellReuseIdentifier = "celltype"
                let cell:DriverCalcCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! DriverCalcCell
                cell.titleLbl.text = (driversArray[indexPath.section-1] as! DriverModel).kbm
                cell.subtitlelbl.text = "Укажите КБМ"
                
                return cell
            }else{
                let cellReuseIdentifier = "cellButton"
                let cell:DriverCalcCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! DriverCalcCell
                
                    cell.getKBMBtn.addTarget(self, action: #selector(getKBM), for: .touchUpInside)
                return cell
            }
            
        }
    }
    
    @objc func getKBM(){
        if let url = URL(string: "https://dkbm-web.autoins.ru/dkbm-web-1.0/kbm.htm"){
            let vc = SFSafariViewController(url: url)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(section==0){
            return UIView()
        }else{
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.table.frame.size.width, height: 30))
            view.backgroundColor = UIColorFromRGB(rgbValue: 0xF6F3F8, alphaValue: 1)
            
            let label = UILabel(frame: CGRect(x: 16, y: 0, width: self.table.frame.size.width
                , height: 30))
            label.text = "Водитель №\(section)"
            label.textAlignment = .left
            label.font = UIFont(name: "Roboto-Regular", size: 15)
            label.textColor = UIColor.black
            view.addSubview(label)
            return view
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section==0){
            if(indexPath.row==0){
                currentType = TypeDate(rawValue:0)
                self.showDataPicker(section: 0)
            }
            if(indexPath.row==1){
                self.showPicker("Укажите период страхования",index: 0)
                currentPicker = TypePicker(rawValue: 0)
                self.picker.selectRow(tempIndexPeriod, inComponent: 0, animated: true)
            }
        }else{
            if(indexPath.row==0){
                currentType = TypeDate(rawValue:1)
                self.showDataPicker(section: indexPath.section-1)
            }else if(indexPath.row==1){
                currentType = TypeDate(rawValue:2)
                self.showDataPicker(section: indexPath.section-1)
            }else if(indexPath.row==2){
                currentPicker = TypePicker(rawValue: 1)
                self.showPicker("Укажите КБМ",index: indexPath.section-1)
                self.picker.selectRow(tempIndexKBM, inComponent: 0, animated: true)
            }
        }
        
    }
    
    @objc func chooseDriverCount(sender: UISegmentedControl){
        countDriver = sender.selectedSegmentIndex+1
        table.reloadData()
    }
    
    @objc func chooseMultidrive(sender:UISwitch){
        isMultiDrive = sender.isOn
        table.reloadData()
    }
    
    @objc func donedatePicker(){
        
        self.view.endEditing(true)
    }

}
extension Date {

func years(from date: Date) -> Int {
    return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    
}
