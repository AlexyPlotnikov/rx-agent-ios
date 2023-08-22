//
//  DetailController.swift
//  RXAgent
//
//  Created by RX Group on 03/09/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

class DetailController: UIViewController,UISearchResultsUpdating,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var table: UITableView!
    var filteredTableData = [[String:Any]]()
    var arrayRegion:NSMutableArray = []
    var arrayCity:NSMutableArray = []
    @IBOutlet weak var searchBar: UISearchBar!
    var isMite:Bool = false
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(isRegion){
            getDataMethod(key: "Regions", getKey: "regions", completion:{
                result in
                self.arrayRegion = result
                self.getDataMethod(key: "EOSAGOCities",getKey: "eosagoCities", completion:{
                    result in
                    self.arrayCity = result
                    self.table.reloadData()
                })
            })
           
           // searchBar.delegate = self
            searchBar.setTextFieldColor(color: UIColor.lightGray)
            searchBar.searchBarStyle = .minimal
            titleLbl.text = "Регион"
        }else{
            
             table.tableHeaderView = UIView()
            getDataMethod(key: "EOSAGOCities",getKey: "eosagoCities", completion:{
                result in
                self.arrayCity = result
                let predicate = NSPredicate(format: "region = %@", regionCVID as CVarArg)
                let searchDataSource = self.arrayCity.filter { predicate.evaluate(with: $0) } as NSArray
                self.arrayCity = searchDataSource.mutableCopy() as! NSMutableArray
              
                let dict = "{\"id\":\"\",\"region\":\"\",\"title\":\"Другие города и населенные пункты\"}"
                self.arrayCity.add(dict.convertToDictionary() as Any)
                self.titleLbl.text = "Населенный пункт"
                self.table.reloadData()
            })
           
        }
        
       
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredTableData.removeAll(keepingCapacity: false)
        var predicate:NSPredicate!
        if(searchBar.text!.isInt){
            predicate = NSPredicate(format: "code CONTAINS[c] %@", searchBar.text!)
            
        }else{
            predicate = NSPredicate(format: "title CONTAINS[c] %@", searchBar.text! )
        }
        let array = (arrayRegion as NSArray).filtered(using: predicate)
        filteredTableData = array as! [[String : Any]]
        self.table.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
       
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  (filteredTableData.count>0) {
            return filteredTableData.count
        } else {
            if(isRegion){
                return arrayRegion.count
            }else{
                return arrayCity.count
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
         cell.tintColor = .black
         if(filteredTableData.count>0) {
            cell.selectionStyle = .none
            cell.textLabel!.font = UIFont(name: "Roboto-Regular", size: 17)
            let region = filteredTableData[indexPath.row]
                cell.textLabel?.text = "\((region["code"] as! String)) \((region["title"] as! String))"
   
        }else{
          
            cell.selectionStyle = .none
            cell.textLabel!.font = UIFont(name: "Roboto-Regular", size: 17)
            if(isRegion){
                let region = arrayRegion[indexPath.row] as! [String:Any]
                cell.textLabel?.text = "\((region["code"] as! String)) \((region["title"] as! String))"
            }else{
                let city = arrayCity[indexPath.row] as! [String:Any]
                cell.textLabel?.text = (city["title"] as! String)
            }
            
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(isRegion){
                let region:[String:Any]!
             if  (filteredTableData.count>0) {
                region = filteredTableData[indexPath.row]
             }else{
                 region = (arrayRegion[indexPath.row] as! [String:Any])
            }
            if(!isMite){
                regionCalc = (region["title"] as! String)
                regionCVID = (region["id"] as! CVarArg)
                regionID = String(region["id"] as! Int)
                ownerModel.regionID = regionID
                ownerModel.regionName = regionCalc
                let predicate = NSPredicate(format: "region = %@", region["id"] as! CVarArg)
                let searchDataSource = arrayCity.filter { predicate.evaluate(with: $0) } as NSArray
                let tempArray = searchDataSource.mutableCopy() as! NSMutableArray
                cityCalc = "Не выбрано"
                needCity = tempArray.count>0
            }else{
                regionCVID = (region["id"] as! CVarArg)
                MiteModel.sharedInstance().miteItem.address = (region["title"] as? String ?? "")
                MiteModel.sharedInstance().adressName = ""
                NotificationCenter.default.post(name: Notification.Name("reloadRegion"), object: self)
               
            }
            self.navigationController?.popViewController(animated: true)
        }else{
            let city = arrayCity[indexPath.row] as! [String:Any]
            cityCalc = (city["title"] as! String)
            if(!isMite){
                if(cityCalc != "Другие города и населенные пункты"){
                    cityID = String(city["id"] as! Int)
                    ownerModel.cityID = cityID
                    ownerModel.cityName = cityCalc
                }else{
                    cityID = ""
                    ownerModel.cityName = "Другие города и населенные пункты"
                }
            }else{
                MiteModel.sharedInstance().adressName = city["title"] as? String ?? ""
                NotificationCenter.default.post(name: Notification.Name("reloadRegion"), object: self)
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension UISearchBar {
    
    private func getViewElement<T>(type: T.Type) -> T? {
        
        let svs = subviews.flatMap { $0.subviews }
        guard let element = (svs.filter { $0 is T }).first as? T else { return nil }
        return element
    }
    
    func setTextFieldColor(color: UIColor) {
        
        if let textField = getViewElement(type: UITextField.self) {
            switch searchBarStyle {
            case .minimal:
                textField.layer.backgroundColor = color.cgColor
                textField.layer.cornerRadius = 6
                
            case .prominent, .default:
                textField.backgroundColor = color
            }
        }
    }
}
