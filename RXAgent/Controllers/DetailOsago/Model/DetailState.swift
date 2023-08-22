//
//  DetailState.swift
//  RXAgent
//
//  Created by RX Group on 01.07.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import Foundation

struct EosagoPolicyModel:Codable{
    var eosagoPolicy:DetailStateModel?
}

struct DetailStateModel:Codable{
    var insurantFullName:String?
    var insurantPhone:String?
    var textStatus:String?
    var creatorPhone:String?
    var creatorFullName:String?
    var insurancePeriod:Int?
    var startDate:String?
    var companyState:Int?
    var agentComment:String?
    var insurantIsOwner:Bool?
    var hasSaleContract:Bool?
    var ownerHasTemporaryRegistration:Bool?
    var vehicleDocID:Int?
    var insurantDocumentPageFirstID:Int?
    var insurantDocumentPageSecondID:Int?
    var saleContractPageID:Int?
    var ownerTemporaryRegistrationPageID:Int?
    var ownerDocumentPageFirstID:Int?
    var ownerDocumentPageSecondID:Int?
    var vehiclePassportPageFirstID:Int?
    var vehiclePassportPageSecondID:Int?
    var vehicleCertificatePageFirstID:Int?
    var vehicleCertificatePageSecondID:Int?
    var unlimitedDrivers:Bool?
    var drivers:[Drivers]?
    var state:Int?
    var paid:Bool?
    var vehicleModel:String?
    var vehicleMark:String?
    var ownerDate:String?
    var insurantDate:String?
    var cost:Double?
    var insuranceCompany:CompanyEnum?
    var pageID:Int?
    var baseCost:Int?
    var payCardFirstName:String?
    var payCardLastName:String?
    var payCardMonth:String?
    var payCardYear:String?
    var payCardNumber:String?
    var payCardCVC:String?
    var creatorSaturdayTimeEnd:String?
    var creatorSaturdayTimeStart:String?
    var creatorSundayTimeEnd:String?
    var creatorSundayTimeStart:String?
    var creatorWeekdaysTimeEnd:String?
    var creatorWeekdaysTimeStart:String?
    var payCardURL:String?
    var promocodeText:String?
}

enum CompanyEnum:Int, Codable, Equatable{
    case INSURANCE_ALPHA_ID = 1
    case INSURANCE_INGOS_ID = 2
    case INSURANCE_RGS_ID = 3
    case INSURANCE_RESO_ID = 4
    case INSURANCE_VSK_ID = 9
    case INSURANCE_NASKO_ID = 32
    case INSURANCE_RENESSANS_ID = 11
    case INSURANCE_ZETTA_SUPER_ID = 13
    case INSURANCE_SOGLASIE_SUPER_ID = 8
   // case INSURANCE_SOGAS_ID = 7
    case INSURANCE_RX_ID = 313
    case OTHER
    
    public init(from decoder: Decoder) throws {
            guard let rawValue = try? decoder.singleValueContainer().decode(Int.self) else {
                self = .OTHER
                return
            }
            self = CompanyEnum(rawValue: rawValue) ?? .OTHER
        }
}

struct Drivers:Codable{
    var driverLicensePageFirstID:Int?
    var driverLicensePageSecondID:Int?
    var fullName:String?
    var id:String?
    var policy:Int?
}

class DetailState{
    
}


