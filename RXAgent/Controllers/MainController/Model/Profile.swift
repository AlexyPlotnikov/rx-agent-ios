//
//  Profile.swift
//  RXAgent
//
//  Created by RX Group on 30.06.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import Foundation

struct DataProfile:Codable {
    let id:Int
    let roleID:Int
    let fullName:String
    let shortName:String
    let email:String?
    let phone:String?
    let avatarID:Int?
    let avatarMinID:Int?
    let isSystemAdmin:Bool
    let contractor:Contractor?
    let region:Region?
    
}

struct Region:Codable{
    let id:Int
    let code:String
    let fiasid:String
    let title:String
}

struct Contractor:Codable {
    let id:Int
    let kvState:Int?
    let balance:Double?
    let modules:[Int]?
    let inviteType:Int?
    let balanceRefillCard:Int?
    let tariff:Int?
}

struct MainProfile:Codable {
    let profile:DataProfile
}


class Profile {
    
    static let shared = Profile()
    
    var profile: DataProfile?
    
    func loadProfile(profileReady:@escaping ((Bool, DataProfile?))->Void){
        
        getRequest(URLString: "\(domain)v0/Employees/me", completion: {
            result in
            DispatchQueue.main.async {
                if(result["error"] == nil){
                    do {
                        //  print(result)
                        //сериализация справочника в Data, чтобы декодировать ее в структуру
                        let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                        self.profile = try! JSONDecoder().decode(MainProfile.self, from: jsonData).profile
                        profileReady((true, self.profile))
                    }catch{
                        
                    }
                }else{
                    profileReady((false, nil))
                }
            }
        })
    }
    
    var avatarLoaded:Bool{
        return self.profile?.avatarMinID != nil
    }
    
    var profileLoaded:Bool{
        return self.profile != nil
    }
    
    func reloadProfile(complete:@escaping ()->Void){
        self.loadProfile { _ in
            complete()
        }
    }
}
