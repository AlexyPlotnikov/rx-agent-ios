//
//  Promo.swift
//  RXAgent
//
//  Created by RX Group on 17.01.2023.
//  Copyright © 2023 RX Group. All rights reserved.
//

import Foundation

struct Discount:Codable{
    var discount:DiscountOsago
}

struct DiscountOsago:Codable{
    var eosago:DiscountModel
}

struct DiscountModel:Codable{
    var cost:Int?
    var percent:Int?
    
    var foreignCost:Int?
    var foreignPercent:Int?
    
    var turboCost:Int?
    var turboPercent:Int?
}


class DiscountObject{
    private static var shared : DiscountObject?

    class func sharedInstance() -> DiscountObject {
        guard let uwShared = shared else {
            shared = DiscountObject()
            return shared!
        }
        return uwShared
    }
    
    var discount:DiscountModel?
    var promoText:String?
}
