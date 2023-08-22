//
//  StateViewModel.swift
//  RXAgent
//
//  Created by RX Group on 01.07.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import Foundation


class StateViewModel{
    var model:DetailStateModel?
    
    func loadOsago(osagoID:String, completion:@escaping ()->Void){
        getRequest(URLString: domain + "v0/EOSAGOPolicies/\(osagoID)", completion: {
            result in
            print(result)
            do {
                //сериализация справочника в Data, чтобы декодировать ее в структуру
                let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                self.model = try! JSONDecoder().decode(EosagoPolicyModel.self, from: jsonData).eosagoPolicy
                
                completion()
            }catch{

            }
        })
    }
    
    
}
