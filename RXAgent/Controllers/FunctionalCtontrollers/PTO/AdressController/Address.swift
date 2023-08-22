//
//  Adress.swift
//  RXAgent
//
//  Created by RX Group on 13.07.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import Foundation


struct AddressStruct:Codable{
    let id:Int
    let title:String?
    let address:String?
    let phones:String?
    var haveEmergencyStopSign:Bool?
    var haveFireExtinguisher:Bool?
    var haveFirstAidKit:Bool?
    var haveWindscreen:Bool?
}

class Address{
    private static var shared : Address?

    class func sharedInstance() -> Address {
        guard let uwShared = shared else {
            shared = Address()
            return shared!
        }
        return uwShared
    }
    
    class func reload() {
            shared = nil
        }
    
   
    
    
    var arrayOfAddresses = [AddressStruct]()
    var currentAddress:AddressStruct!
    
    func loadAddress(profileID:String, categoryID:Int, formatedDate:String, time:String, addressReady:@escaping ((Bool, [AddressStruct]?))->Void){
        getArrayRequest(URLString: newDomain + "/api/v1/AgentsRecords/agents/\(profileID)/aviable/tips?category=\(categoryID)&date=\(formatedDate)&time=\(time)", needSecretKey: true, completion: {
            result in
            DispatchQueue.main.async {
                do {
                    print(result)
                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                    self.arrayOfAddresses = try! JSONDecoder().decode([AddressStruct].self, from: jsonData)
                    addressReady((true, self.arrayOfAddresses))
                }catch{
                    addressReady((false, nil))
                }
            }
        })
    }
    
    var needAdditionalParam:Bool{
        return currentAddress.haveEmergencyStopSign ?? false || currentAddress.haveFireExtinguisher ?? false || currentAddress.haveFirstAidKit ?? false || currentAddress.haveWindscreen ?? false
    }
}
