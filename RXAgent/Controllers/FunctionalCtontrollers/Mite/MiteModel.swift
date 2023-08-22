//
//  MiteModel.swift
//  RXAgent
//
//  Created by RX Group on 21.03.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import Foundation

struct Mite:Codable{
    var items: [ClientMite]
    var provider: Int = 615
    var insuranceProgram: Int = 2
    var region: Int
    var fullName: String
    var dob: String
    var phone: String
    var passportSeries: String
    var passportNumber: String
    var passportDate: String
    var passportRegistrator: String
    var address: String
    var street:String
    var house:String
    var housing:String
    var flat: String
    
    var asDictionary : [String:Any] {
      let mirror = Mirror(reflecting: self)
      let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
        guard let label = label else { return nil }
        return (label, value)
      }).compactMap { $0 })
      return dict
    }
}

struct ClientMite:Codable{
    var fullName:String
    var dob:String
    var asDictionary : [String:Any] {
      let mirror = Mirror(reflecting: self)
      let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
        guard let label = label else { return nil }
        return (label, value)
      }).compactMap { $0 })
      return dict
    }
}

class MiteModel{
    private static var shared : MiteModel?

    class func sharedInstance() -> MiteModel {
        guard let uwShared = shared else {
            shared = MiteModel()
            return shared!
        }
        return uwShared
    }
    
    var adressName:String = ""
    
    var miteItem:Mite = Mite(items: [], provider: 615, insuranceProgram: 2, region: 0, fullName: "", dob: "", phone: "", passportSeries: "", passportNumber: "", passportDate: "", passportRegistrator: "", address: "", street: "",  house: "", housing: "", flat: "")
    
    var tempMite:ClientMite = ClientMite(fullName: "", dob: "")
    
    func reload(){
        miteItem = Mite(items: [], provider: 615, insuranceProgram: 2, region: 0, fullName: "", dob: "", phone: "", passportSeries: "", passportNumber: "", passportDate: "", passportRegistrator: "", address: "", street: "",  house: "", housing: "", flat: "")
    }
}


