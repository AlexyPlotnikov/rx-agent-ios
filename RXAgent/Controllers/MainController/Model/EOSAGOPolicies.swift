//
//  EOSAGOPolicies.swift
//  RXAgent
//
//  Created by RX Group on 01.07.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import Foundation
import UIKit


struct Meta:Codable {
   let meta:MetaData
}

struct MetaData:Codable {
    let per_page: Int
    let total: Int
}

struct Police:Codable {
    let eosagoPolicies:[PoliceData]
}

struct PoliceSearch:Codable {
    let eosagoPolicy:PoliceData
}



struct PoliceData:Codable {
    let insuranceCompany:Int?
    let vehicleMark:String?
    let vehicleModel:String?
    let isShort:Bool?
    let createDate:String
    let insurantDate:String?
    let insurantFullName:String?
    let insurantShortName:String?
    let finalBonus:Int?
    let dateSent:String?
    let state:Int
    let ownerDate:String?
    let surcharge:Double?
    let paid:Bool?
    let id:Int
    let `super`:String?
    let baseCost:Double?
}

enum InsuranceEnum:String{
    case vsk = "VSK"
    case reso = "RESO"
    case renesans = "Renessans"
    case alpha = "Alpha"
    case ingos = "Ingos"
}

class EOSAGOPolicies {
    
    static let shared = EOSAGOPolicies()
    
    var policies:[[PoliceData]] = []
    var searchPolicies:PoliceData!
    var meta: MetaData?
    
    func loadPolices(countItems:Int, policiesReady:@escaping ((Bool, [[PoliceData]]?))->Void) {
        getRequest(URLString: "\(domain)v0/EOSAGOPolicies?PerPage=\(countItems)", completion: {
            result in
            DispatchQueue.main.async {
                if(result["error"] == nil){
                    do {
                        //сериализация справочника в Data, чтобы декодировать ее в структуру
                        let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                        let tempPolicies = try! JSONDecoder().decode(Police.self, from: jsonData).eosagoPolicies
                        self.meta = try! JSONDecoder().decode(Meta.self, from: jsonData).meta
                        let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
                       
                        self.policies = tempPolicies.groupSort(byDate: { dateFormatter.date(from: $0.createDate)! })
                        
                        policiesReady((true, self.policies))
                    }catch{
                        
                    }
                }else{
                    policiesReady((false, nil))
                }
            }
        })
    }
    
    func loadSearchPolice(idPolice:String,policiesReady:@escaping ((Bool, PoliceData?))->Void){
        getRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(idPolice)", completion: {
            result in
            DispatchQueue.main.async {
                if(result["error"] == nil){
                    do {
                        //сериализация справочника в Data, чтобы декодировать ее в структуру
                        let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                        self.searchPolicies = try! JSONDecoder().decode(PoliceSearch.self, from: jsonData).eosagoPolicy
                      
                        policiesReady((true, self.searchPolicies))
                    }catch{
                        
                    }
                }else{
                    policiesReady((false, nil))
                }
            }
        })
    }
    
    func getPolicyByParam(isSearch:Bool, index:Int, section:Int)->PoliceData{
        return isSearch ? searchPolicies:policies[section][index]
    }
    
    func isRXPolicy(policy:PoliceData) -> Bool {
        return policy.state == 254 && policy.finalBonus == nil
    }
    
    
    func getCost(policy:PoliceData) -> Int {
        return  Int(policy.surcharge ?? 0.0) + Int(policy.baseCost ?? 0.0)
    }
    
    func needSetInsurance(policy:PoliceData) -> Bool{
        return policy.ownerDate != nil || policy.insurantDate != nil
    }

    func getIcon(policy:PoliceData) -> UIImage{
        if let insurance = InsuranceEnum(rawValue: policy.super ?? "") {
            switch insurance {
            case .vsk:
                return UIImage(named: "vskMini")!
            case .reso:
                return UIImage(named: "ins-reso")!
            case .renesans:
                return UIImage(named: "renessnsMIni")!
            case .alpha:
                return UIImage(named: "alphaMini")!
            case .ingos:
                return UIImage(named: "ingosMini")!
            }
        }else{
            if(policy.super == nil && policy.dateSent != nil){
                return UIImage(named: "RXmini")!
            }else{
                return UIImage(named: "OSAGO_icon")!
            }
            
        }
    
    }
    
}
