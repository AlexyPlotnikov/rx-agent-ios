//
//  Painment.swift
//  RXAgent
//
//  Created by RX Group on 16.07.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import Foundation


struct PaimentStruct:Codable{
    var mainPrice:Int
    var addPrice:Int
    var totalPrice:Int
}


class Paiment{
    private static var shared : Paiment?

    class func sharedInstance() -> Paiment {
        guard let uwShared = shared else {
            shared = Paiment()
            return shared!
        }
        return uwShared
    }
    
    class func reload() {
            shared = nil
        }
    
    var paiment:PaimentStruct?
   
    func loadPaiment(profileID:String, categoryID:Int, tipID:Int, paimentReady:@escaping ((Bool, PaimentStruct?))->Void){
        getRequest(URLString: newDomain + "/api/v1/AgentsRecords/agents/\(profileID)/tips/\(tipID)/categories/\(categoryID)", needSecretKey: true, completion: {
            result in
            DispatchQueue.main.async {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                    self.paiment = try! JSONDecoder().decode(PaimentStruct.self, from: jsonData)
                    paimentReady((true, self.paiment))
                }catch{
                    paimentReady((false, nil))
                }
            }
        })
    }
    
    var readyToPay:Bool{
        return paiment?.totalPrice != 0
    }
}
