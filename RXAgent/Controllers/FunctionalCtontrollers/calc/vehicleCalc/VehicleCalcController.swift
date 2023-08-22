//
//  VehicleCalcController.swift
//  RXAgent
//
//  Created by RX Group on 05/09/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit
import AudioToolbox

enum categoryVehicle: Int {
    case a = 1
    case b = 2
    case c = 3
    case d = 4
    case e = 5
}

class VehicleCalcController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate {
    @IBOutlet weak var table: UITableView!
    var picker:UIPickerView!
    var categoryArray:NSMutableArray = []
    
    var actualCategory = categoryVehicle.b
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.tableFooterView = UIView()
        getDataMethod(key: "VehicleCategories",getKey: "vehicleCategories", completion:{
            result in
            self.categoryArray = result
        })
        let tapGestureRecognizer    = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
        tapGestureRecognizer.cancelsTouchesInView=false
        self.view.addGestureRecognizer(tapGestureRecognizer)
        //личная 1
        //перевозки 5
        //такси 3
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
        textfieldChanged(index: 1)
    }
    
    func addToolBarTextfield(textField:UITextField){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: UIBarButtonItem.Style.done, target: self, action: #selector(handleTap))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spaceButton,doneButton], animated: false)
        textField.inputAccessoryView = toolbar
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch actualCategory {
        case .a:
            
            return 2
        case .b:
            
            return 3
        case .c:
            
            return 3
        case .d:
            if(transportation){
                 return 2
            }else{
                 return 3
            }
           
        case .e:
        
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch actualCategory {
        case .a:
            
            return 65
        case .b:
            if(indexPath.row==2){
                return 90
            }else{
                return 65
            }
        case .c:
            if(indexPath.row==2){
                return 90
            }else{
                return 65
            }
        case .d:
            if(indexPath.row==0){
                return 65
            }else{
                return 90
            }
            
        case .e:
            
            return 65
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row==0){
            let cellReuseIdentifier = "cell"
            let cell:VehicleCalcCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! VehicleCalcCell
            cell.titleLbl.text = categoryVehicleTitle
          
            return cell
        }else{
           
            switch actualCategory {
            case .a:
                let cellReuseIdentifier = "cellSwitch"
                let cell:VehicleCalcCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! VehicleCalcCell
                    cell.switcher.setOn(trailerEmpty, animated: true)
                
                return cell
            case .b:
               
                if(indexPath.row==1){
                    let cellReuseIdentifier = "cellTextField"
                    let cell:VehicleCalcCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! VehicleCalcCell
                    cell.buttonChoose.setTitle("Укажите мощность, Л.С.", for: .normal)
                    cell.nameSubtitle.text = "Мощность, Л.С."
                    cell.nameTextField.keyboardType = .decimalPad
                    cell.nameTextField.addToolBar()
                    cell.nameTextField.delegate = self
                    return cell
                }else{
                    let cellReuseIdentifier = "cellSegment"
                    let cell:VehicleCalcCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! VehicleCalcCell
                    cell.titleSegment.text = "Цель использования"
                    cell.segment.setTitle("Личная", forSegmentAt: 0)
                    cell.segment.setTitle("Такси", forSegmentAt: 1)
                    targetVehicleID = 1
                    cell.segment.selectedSegmentIndex = 0
                    cell.segment.addTarget(self, action: #selector(segmentChoose), for: .valueChanged)
                    cell.segment.tag = 1
                    
                    return cell
                }
            case .c:
                if(indexPath.row==1){
                    let cellReuseIdentifier = "cellSwitch"
                    let cell:VehicleCalcCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! VehicleCalcCell
                    cell.switcher.setOn(trailerEmpty, animated: true)
                    
                    return cell
                }else{
                    let cellReuseIdentifier = "cellSegment"
                    let cell:VehicleCalcCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! VehicleCalcCell
                    cell.titleSegment.text = "Максимальная масса"
                    cell.segment.setTitle("16 тонн и менее", forSegmentAt: 0)
                    cell.segment.setTitle("Более 16 тонн", forSegmentAt: 1)
                    cell.segment.addTarget(self, action: #selector(segmentChoose), for: .valueChanged)
                    cell.segment.tag = 2
                    cell.segment.selectedSegmentIndex = 0
                    moreTon = false
                    return cell
                }
               
            case .d:
                if(indexPath.row==1){
                    let cellReuseIdentifier = "cellSegment"
                    let cell:VehicleCalcCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! VehicleCalcCell
                    cell.titleSegment.text = "Цель использования"
                    cell.segment.setTitle("Личная", forSegmentAt: 0)
                    cell.segment.setTitle("Перевозки", forSegmentAt: 1)
                    cell.segment.addTarget(self, action: #selector(segmentChoose), for: .valueChanged)
                    cell.segment.tag = 3
                    if(transportation){
                        cell.segment.selectedSegmentIndex = 1
                      //  targetVehicleID = 1
                    }else{
                        cell.segment.selectedSegmentIndex = 0
                     //targetVehicleID = 5
                    }
                    
                    return cell
                }else{
                    let cellReuseIdentifier = "cellSegment"
                    let cell:VehicleCalcCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! VehicleCalcCell
                    cell.titleSegment.text = "Количество мест"
                    cell.segment.setTitle("Более 16", forSegmentAt: 0)
                    cell.segment.setTitle("До 16 включительно", forSegmentAt: 1)
                    cell.segment.addTarget(self, action: #selector(segmentChoose), for: .valueChanged)
                    cell.segment.tag = 4
                    morePlaces = false
                    cell.segment.selectedSegmentIndex = 0
                    
                    return cell
                }
            case .e:
                let cellReuseIdentifier = "cellSwitch"
                let cell:VehicleCalcCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! VehicleCalcCell
                cell.switcher.setOn(trailerEmpty, animated: true)
                
                return cell
           
            }
            
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.count == 0 {
            return true
        }
    
        let decimalSeparator = NSLocale.Key.decimalSeparator
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
       
        if prospectiveText.count == 1 {
            if(string==","||string=="0"){
                return false
            }else{
                return true
            }
            
        }
        
        power = prospectiveText.replacingOccurrences(of: ",", with: ".")
        if(power.count>=7){
            power.remove(at: power.index(before: power.endIndex))
        }
        vehicleModel.power = power
        return prospectiveText.isNumeric() &&
            prospectiveText.doesNotContainCharactersIn(matchCharacters: "-e" + decimalSeparator.rawValue) &&
            prospectiveText.count <= 6
    }
   
    func textfieldChanged(index :Int){
        if(actualCategory == .b){
            let section = 0
            let row = index
            let indexPath = IndexPath(row: row, section: section)
            if(table.isCellVisible(section: section, row: row)){
                let cell: VehicleCalcCell = self.table.cellForRow(at: indexPath) as! VehicleCalcCell
                
                UIView.animate(withDuration: 0.4, animations: {
                    if(cell.nameTextField.text!.count>0){
                        cell.buttonChoose.setTitle("", for: .normal)
                        cell.nameSubtitle.isHidden=false
                        cell.nameTextField.isHidden=false
                        cell.buttonChoose.isHidden=true
                    }else{
                        cell.buttonChoose.setTitle("Укажите мощность, Л.С.", for: .normal)
                        cell.nameSubtitle.isHidden=true
                        cell.nameTextField.isHidden=true
                        cell.buttonChoose.isHidden=false
                    }
                    
                    cell.nameTextField.resignFirstResponder()
                    
                })
            }
        }
    }
    
    @objc func segmentChoose(sender: UISegmentedControl){
         AudioServicesPlaySystemSound(1519)
        if(sender.tag==1){
            if(sender.selectedSegmentIndex==0){
                targetVehicleID = 1
            }else{
                targetVehicleID = 3
            }
            
        }
        if(sender.tag==2){
            if(sender.selectedSegmentIndex==0){
                moreTon = false
            }else{
                moreTon = true
            }
        }
        if(sender.tag==3){
            if(sender.selectedSegmentIndex == 0){
                transportation = false
                targetVehicleID = 1
            }else{
                transportation = true
                targetVehicleID = 5
            }
            table.reloadData()
        }
        if(sender.tag==4){
            if(sender.selectedSegmentIndex==0){
                morePlaces = false
            }else{
                morePlaces = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row==0){
            self.showPicker("Укажите категорию ТС")
            
        }
    }
    
    
    func getDataMethod(key: String, getKey : String, completion:@escaping (NSMutableArray)->Void){
        if((UserDefaults.standard.array(forKey: key)) != nil){
            let array = UserDefaults.standard.value(forKey: key) as! NSArray
            completion(array.mutableCopy() as! NSMutableArray)
        }else{
            getRequest(URLString: "\(domain)v0/\(key)", completion:{ result in
                DispatchQueue.main.async{
                    let array = result[getKey] as! NSArray
                    let defaults = UserDefaults.standard
                    defaults.set(array, forKey: key)
                    completion(array.mutableCopy() as! NSMutableArray)
                }
            })
            
        }
    }
    
    
    func showPicker(_ string: String){
        let alert = UIAlertController(title: string, message: "\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        alert.isModalInPopover = true
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        let pickerFrame = CGRect(x: 17, y: 52, width: 300, height: 150)
        picker = UIPickerView(frame: pickerFrame)
        picker.delegate = self
        picker.dataSource = self
        picker.selectRow(categoryVehicleID-1, inComponent: 0, animated: true)
        alert.addAction(UIAlertAction(title: "Готово", style: .default, handler: {
            _ in
            
            self.table.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.view.addSubview(picker)
        
        present(alert, animated: true, completion: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
            let category = self.categoryArray[row] as! [String:Any]
            categoryVehicleTitle = "\(category["title"] as! String) - \(category["shortDescription"] as! String)"
            categoryVehicleID = category["id"] as! Int
            vehicleModel.categoryID = categoryVehicle(rawValue: categoryVehicleID)!
            actualCategory = categoryVehicle(rawValue: categoryVehicleID)!
       
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            let category = self.categoryArray[row] as! [String:Any]
            return "\(category["title"] as! String) - \(category["shortDescription"] as! String)"
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return self.categoryArray.count
     
    }
}
extension String {
    
    // Returns true if the string has at least one character in common with matchCharacters.
    func containsCharactersIn(matchCharacters: String) -> Bool {
        let characterSet = NSCharacterSet(charactersIn: matchCharacters)
        return self.rangeOfCharacter(from: characterSet as CharacterSet) != nil
    }
    
    // Returns true if the string contains only characters found in matchCharacters.
    func containsOnlyCharactersIn(matchCharacters: String) -> Bool {
        let disallowedCharacterSet = NSCharacterSet(charactersIn: matchCharacters).inverted
        return self.rangeOfCharacter(from: disallowedCharacterSet) == nil
    }
    
    // Returns true if the string has no characters in common with matchCharacters.
    func doesNotContainCharactersIn(matchCharacters: String) -> Bool {
        let characterSet = NSCharacterSet(charactersIn: matchCharacters)
        return self.rangeOfCharacter(from: characterSet as CharacterSet) == nil
    }
    
    // Returns true if the string represents a proper numeric value.
    // This method uses the device's current locale setting to determine
    // which decimal separator it will accept.
    func isNumeric() -> Bool
    {
        let scanner = Scanner(string: self)
        
        scanner.locale = NSLocale.current
        
        return scanner.scanDecimal(nil) && scanner.isAtEnd
    }
    public func numberOfOccurrences(_ string: String) -> Int {
        return components(separatedBy: string).count - 1
    }
}


