//
//  TORecords.swift
//  RXAgent
//
//  Created by RX Group on 12.07.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import Foundation


struct Record:Codable{
    let id:Int
    let createEmployeeId:Int
    let branchAddress:String?
    let date:String?
    let originalPrice:Int?
    let price:Int?
    let phone:String?
    let car:String?
    let gosnumber:String?
    let fio:String?
    let status:Int?
    let categoryId:Int
    let time:String?
    let comment:String?
    let state:Int?
}

struct CreateRecord:Codable{
    let id:Int
    let canCreateRecordPto:Bool
}


class TORecords{
    static let shared = TORecords()
    private var mainRecords:[Record]?
    var records:[[Record]]?
    var searchRecord:Record?
    
    var profileID:String{
        return String(format: "%04d", Profile.shared.profile?.contractor?.id ?? 0)
    }
    
    func loadTORecords(recordReady:@escaping ((Bool, [[Record]]?))->Void){
                getArrayRequest(URLString: newDomain + "/api/v1/AgentsRecords/agents/\(self.profileID)/records", needSecretKey: true, completion: {
                    result in
                    DispatchQueue.main.async {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                            self.mainRecords = try! JSONDecoder().decode([Record].self, from: jsonData)
                            let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                           
                            self.records = self.mainRecords?.groupSort(byDate: { dateFormatter.date(from: $0.date!)! })
                            recordReady((true, self.records))
                        }catch{
                            recordReady((false, nil))
                        }
                    }
                })
           
        
    }
    
    func getRecordInfo(canCreate:@escaping (Bool)->Void){
        getRequest(URLString: newDomain + "/api/v1/AgentsRecords/agents/\(self.profileID)/info", needSecretKey: true, completion: {
            result in
            DispatchQueue.main.async {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                    let canCreat = try! JSONDecoder().decode(CreateRecord.self, from: jsonData).canCreateRecordPto
                  
                    canCreate(canCreat)
                }catch{
                    canCreate(false)
                }
            }
        })
    }
    
    func searchRecord(index:Int)->Record?{
            searchRecord = mainRecords?.first(where: {$0.id == index})
            return mainRecords?.first(where: {$0.id == index})
    }
    
    func getRecordByParam(isSearch:Bool, section:Int, index:Int) -> Record?{
        return isSearch ? searchRecord:records?[section][index]
    }
}
