//
//  MiteMainModel.swift
//  RXAgent
//
//  Created by RX Group on 28.03.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import Foundation

struct MitePolicies:Codable{
    var mitePolicies:[MiteMainStruct]
    let meta:MetaDataMite
}

struct MetaDataMite:Codable {
    let per_page: Int
    let total: Int
}

struct MiteMainStruct:Codable{
    let id:Int
    let paid:Bool
    let shortName:String
    let costClient:Double
    let bonus:Double
    let itemsCount:Int
    var createDate:String
}

struct MiteDetailPolice:Codable{
    let mitePolicy:MiteDetailModel
}

struct MiteDetailModel:Codable{
    let id:Int
    let paid:Bool
    let bonus:Double
    let costClient:Double
    let dateFrom:String
    let dateTo:String
    let fullName:String
    let dob:String
    let items:[MiteItemPeople]
}

struct MiteItemPeople:Codable{
    let id:Int
    let fullName:String
    let dob:String
}

//class MiteMainModel{
//
//    private static var shared : MiteMainModel?
//    var meta:MetaData
//
//    class func sharedInstance() -> MiteMainModel {
//        guard let uwShared = shared else {
//            shared = MiteMainModel()
//            return shared!
//        }
//        return uwShared
//    }
//
//
//
//}
