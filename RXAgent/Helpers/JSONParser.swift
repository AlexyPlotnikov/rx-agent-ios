//
//  JSONParser.swift
//  RXAgent
//
//  Created by RX Group on 04/02/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import Foundation



func getHeadNames(dictionary: [String:Any]) -> NSMutableArray{
    
    let headers: NSMutableArray = []
    
    if(cardIsHave(dictionary: dictionary)){
        headers.add(["Платежная система","Собственник","№ карты","Срок действия","Код CVV/CVC"])
    }
    
    if(insuranceIsHave(dictionary: dictionary)){
         headers.add( ["ФИО Страхователя","Место рождения страхователя","Дата рождения","Телефон","Документ","Серия и номер","Дата выдачи","Кем выдан","Населенный пункт","Улица","Дом","Корпус","Квартира","Индекс"])
    }
    
    if(ownerIsHave(dictionary: dictionary)){
         headers.add(["ФИО Собственника","Место рождения собственника","Дата рождения","Телефон","Документ","Серия и номер","Дата выдачи","Кем выдан","Населенный пункт","Улица","Дом","Корпус","Квартира","Индекс"])
    }
    
    if(vehicleIsHave(dictionary: dictionary)){
         headers.add( ["Модель","Категория","Тип двигателя","Год выпуска","Госномер","VIN","Кузов","Шасси","Цель","Мощность","Разр. макс. масса, кг","Масса без нагрузки, кг", "№ ДК","Срок действия ДК","ПТС","Дата выдачи ПТС","СРТС","Дата выдачи СРТС","Число мест"])
    }
    
    if((dictionary["unlimitedDrivers"] as? Bool) == false){
        if((dictionary["drivers"] is NSNull)){
            let countDrivers = dictionary["drivers"] as! NSArray
            for _ in 1..<countDrivers.count{
                headers.add( ["ФИО","Дата рождения","ВУ","Выдано","Начало стажа"])
            }
        }
    }
    
    return headers
}
func getDataForRows(dictionary: [String:Any])->NSMutableArray{
    let tempArray: NSMutableArray = []
    
    if(cardIsHave(dictionary: dictionary)){
        tempArray.add(getCardData(dictionary: dictionary))
    }
    if(insuranceIsHave(dictionary: dictionary)){
        tempArray.add(getInsuranceData(dictionary: dictionary))
    }
    if(ownerIsHave(dictionary: dictionary)){
        tempArray.add(getOwnerDat(dictionary: dictionary))
    }
    if(vehicleIsHave(dictionary: dictionary)){
        tempArray.add(getVehicleData(dictionary: dictionary))
    }
    if((dictionary["unlimitedDrivers"] as? Bool) == false){
        if((dictionary["drivers"] is NSNull)){
            let countDrivers = dictionary["drivers"] as! NSArray
            for i in 1..<countDrivers.count{
                tempArray.add(getDriverDataAtIndex(dictionary: dictionary, index: i) )
            }
        }
    }
    return tempArray
}


func getCardData(dictionary: [String:Any])->NSMutableArray{
    let tempArray: NSMutableArray = []
    
    if(!(dictionary["payCardPaymentSystem"] is NSNull)){
        if((dictionary["payCardPaymentSystem"] as! Int)==1){
            tempArray.add("VISA")
        }
        if((dictionary["payCardPaymentSystem"] as! Int)==2){
            tempArray.add("MASTERCARD")
        }
        if((dictionary["payCardPaymentSystem"] as! Int)==3){
            tempArray.add("МИР")
        }
        if((dictionary["payCardPaymentSystem"] as! Int)==4){
            tempArray.add("MAESTRO")
        }
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["payCardFirstName"] is NSNull) && !(dictionary["payCardLastName"] is NSNull)){
        tempArray.add("\( dictionary["payCardFirstName"] as? String ?? "") \(dictionary["payCardLastName"] as? String ?? "")")
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["payCardNumber"] is NSNull)){
        tempArray.add(dictionary["payCardNumber"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["payCardMonth"] is NSNull) && !(dictionary["payCardYear"] is NSNull)){
        tempArray.add("\( dictionary["payCardMonth"] as? String ?? "") \(dictionary["payCardYear"] as? String ?? "")")
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["payCardCVC"] is NSNull)){
        tempArray.add(dictionary["payCardCVC"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    return tempArray
}

func getVehicleData(dictionary: [String:Any])->NSMutableArray{
     let tempArray: NSMutableArray = []
    
    
    if(!(dictionary["vehicleModel"] is NSNull)){
        if(!(dictionary["vehicleMark"] is NSNull)){
               tempArray.add("\(dictionary["vehicleMark"] as! String) \(dictionary["vehicleModel"] as! String)")
        }else{
             tempArray.add( dictionary["vehicleModel"] as! String)
        }
     
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["vehicleCategory"] is NSNull)){
        if((dictionary["vehicleCategory"] as! Int)==1){
            tempArray.add("A")
        }
        if((dictionary["vehicleCategory"] as! Int)==2){
            tempArray.add("B")
        }
        if((dictionary["vehicleCategory"] as! Int)==3){
            tempArray.add("C")
        }
        if((dictionary["vehicleCategory"] as! Int)==4){
            tempArray.add("D")
        }
        if((dictionary["vehicleCategory"] as! Int)==5){
            tempArray.add("E")
        }
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["vehicleEngineType"] is NSNull)){
        if((dictionary["vehicleEngineType"] as! Int) != 0){
            if((dictionary["vehicleEngineType"] as! Int)==1){
                tempArray.add("Дизель")
            }
            if((dictionary["vehicleEngineType"] as! Int)==2){
                tempArray.add("Бензин")
            }
            if((dictionary["vehicleEngineType"] as! Int)==3){
                tempArray.add("Дизель-турбо")
            }
            if((dictionary["vehicleEngineType"] as! Int)==4){
                tempArray.add("Бензин-турбо")
            }
            if((dictionary["vehicleEngineType"] as! Int)==5){
                tempArray.add("Газовый")
            }
            if((dictionary["vehicleEngineType"] as! Int)==6){
                tempArray.add("Электро")
            }
            if((dictionary["vehicleEngineType"] as! Int)==7){
                tempArray.add("Гибрид")
            }
            if((dictionary["vehicleEngineType"] as! Int)==8){
                tempArray.add("Другое")
            }
        }else{
            tempArray.add("Нет данных")
        }
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["vehicleYear"] is NSNull)){
        tempArray.add(String(dictionary["vehicleYear"] as! Int))
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["vehicleNumber"] is NSNull)){
        tempArray.add(dictionary["vehicleNumber"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    
    if(!(dictionary["vehicleVIN"] is NSNull)){
        tempArray.add(dictionary["vehicleVIN"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["vehicleBody"] is NSNull)){
        tempArray.add(dictionary["vehicleBody"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["vehicleChassis"] is NSNull)){
        tempArray.add(dictionary["vehicleChassis"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["vehicleTarget"] is NSNull)){
        if((dictionary["vehicleTarget"] as! Int)==1){
            tempArray.add("Личная")
        }
        if((dictionary["vehicleTarget"] as! Int)==2){
            tempArray.add("Учебная езда")
        }
        if((dictionary["vehicleTarget"] as! Int)==3){
            tempArray.add("Такси")
        }
        if((dictionary["vehicleTarget"] as! Int)==4){
            tempArray.add("Прокат/краткосрочная аренда")
        }
        if((dictionary["vehicleTarget"] as! Int)==5){
            tempArray.add("Регулярные пассажирские перевозки/перевозки пассажиров по заказам")
        }
        if((dictionary["vehicleTarget"] as! Int)==6){
            tempArray.add("Прочее")
        }
        if((dictionary["vehicleTarget"] as! Int)==7){
            tempArray.add("Перевозка опасных и легковоспламеняющихся грузов")
        }
        if((dictionary["vehicleTarget"] as! Int)==8){
            tempArray.add("Дорожные и специальные транспортные средства")
        }
        if((dictionary["vehicleTarget"] as! Int)==9){
            tempArray.add("Экстренные и коммунальные службы")
        }
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["vehicleHorsePower"] is NSNull) && !(dictionary["vehicleKWPower"] is NSNull)){
        tempArray.add("\( dictionary["vehicleHorsePower"] as? String ?? "") л.с./ \(dictionary["vehicleKWPower"] as? String ?? "") кВт")
    }else{
         tempArray.add("Нет данных")
    }
    if(!(dictionary["vehicleMaxMass"] is NSNull)){
        tempArray.add(dictionary["vehicleMaxMass"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["vehicleMass"] is NSNull)){
        tempArray.add(dictionary["vehicleMass"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
  
    if(!(dictionary["cardNumber"] is NSNull)){
        tempArray.add(dictionary["cardNumber"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
  
    if(!(dictionary["cardValidity"] is NSNull)){
        tempArray.add(dateFromJSON(dictionary["cardValidity"] as! String))
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["vehiclePassportSeries"] is NSNull) && !(dictionary["vehiclePassportNumber"] is NSNull)){
        tempArray.add("\( dictionary["vehiclePassportSeries"] as? String ?? "") \(dictionary["vehiclePassportNumber"] as? String ?? "")")
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["vehiclePassportDate"] is NSNull)){
        tempArray.add(dateFromJSON(dictionary["vehiclePassportDate"] as! String))
    }else{
        tempArray.add("Нет данных")
    }
   
    if(!(dictionary["vehicleCertificateSeries"] is NSNull) && !(dictionary["vehicleCertificateNumber"] is NSNull)){
        tempArray.add("\( dictionary["vehicleCertificateSeries"] as? String ?? "") \(dictionary["vehicleCertificateNumber"] as? String ?? "")")
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["vehicleCertificateDate"] is NSNull)){
        tempArray.add(dateFromJSON(dictionary["vehicleCertificateDate"] as! String))
    }else{
        tempArray.add("Нет данных")
    }
  
    if(!(dictionary["vehicleSeats"] is NSNull)){
        tempArray.add(dictionary["vehicleSeats"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    return tempArray
}


func getDriverDataAtIndex(dictionary: [String:Any],index: Int)->NSMutableArray{
    let tempArray: NSMutableArray = []
    let driversArray:NSArray = dictionary["drivers"] as! NSArray
    let currentDriver:[String:Any] = driversArray[index] as! [String:Any]
    
    if(currentDriver["fullName"] is NSNull){
        tempArray.add("Нет данных")
    }else{
        tempArray.add(currentDriver["fullName"] as? String as Any)
    }
    if(currentDriver["dateOfBirth"] is NSNull){
        tempArray.add("Нет данных")
    }else{
        tempArray.add(currentDriver["dateOfBirth"] as? String as Any)
    }
    
    if((currentDriver["driverLicenseSeries"] is NSNull)&&(currentDriver["driverLicenseNumber"] is NSNull)){
        tempArray.add("Нет данных")
    }else{
        tempArray.add("\( dictionary["driverLicenseSeries"] as? String ?? "") \(dictionary["driverLicenseNumber"] as? String ?? "")")
    }
    if(currentDriver["driverLicenseDate"] is NSNull){
        tempArray.add("Нет данных")
    }else{
        tempArray.add(currentDriver["driverLicenseDate"] as? String as Any)
    }
    if(currentDriver["startDateExperience"] is NSNull){
        tempArray.add("Нет данных")
    }else{
        tempArray.add(currentDriver["startDateExperience"] as? String as Any)
    }
    return tempArray
}


func getInsuranceData(dictionary: [String:Any]) ->NSMutableArray{
     let tempArray: NSMutableArray = []
    
    if(!(dictionary["insurantFullName"] is NSNull)){
        tempArray.add(dictionary["insurantFullName"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    
    if(!(dictionary["insurantBirthPlace"] is NSNull)){
        tempArray.add(dictionary["insurantBirthPlace"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["insurantDate"] is NSNull)){
        tempArray.add(dateFromJSON(dictionary["insurantDate"] as! String))
    }else{
        tempArray.add("Нет данных")
    }
    
    if(!(dictionary["insurantPhone"]  is NSNull)){
        tempArray.add(dictionary["insurantPhone"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    
    if(!(dictionary["insurantDocumentType"]  is NSNull)){
        tempArray.add(dictionary["insurantDocumentType"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    
    if(!(dictionary["insurantDocumentSeries"] is NSNull) && !(dictionary["insurantDocumentNumber"] is NSNull)){
        tempArray.add("\( dictionary["insurantDocumentSeries"] as? String ?? "") \(dictionary["insurantDocumentNumber"] as? String ?? "")")
    }else{
        tempArray.add("Нет данных")
    }
    
    if(!(dictionary["insurantDocumentDate"]  is NSNull)){
        tempArray.add(dateFromJSON(dictionary["insurantDocumentDate"] as! String))
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["insurantDocumentRegistrator"]  is NSNull)){
        tempArray.add(dictionary["insurantDocumentRegistrator"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["insurantAddress"]  is NSNull)){
        tempArray.add(dictionary["insurantAddress"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["insurantStreet"]  is NSNull)){
        tempArray.add(dictionary["insurantStreet"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["insurantHouse"]  is NSNull)){
        tempArray.add(dictionary["insurantHouse"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["insurantHousing"]  is NSNull)){
        tempArray.add(dictionary["insurantHousing"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["insurantFlat"]  is NSNull)){
        tempArray.add(dictionary["insurantFlat"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["insurantIndex"]  is NSNull)){
        tempArray.add(dictionary["insurantIndex"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    return tempArray
}

//////////////////////////////////////////////////////////////
func getOwnerDat(dictionary: [String:Any]) ->NSMutableArray{
    let tempArray: NSMutableArray = []
    if(!(dictionary["ownerFullName"] is NSNull)){
        tempArray.add(dictionary["ownerFullName"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["ownerBirthPlace"] is NSNull)){
        tempArray.add(dictionary["ownerBirthPlace"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["ownerDate"] is NSNull)){
        tempArray.add(dateFromJSON(dictionary["ownerDate"] as! String))
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["ownerPhone"]  is NSNull)){
        tempArray.add(dictionary["ownerPhone"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["ownerDocumentType"]  is NSNull)){
        tempArray.add(dictionary["ownerDocumentType"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["ownerDocumentSeries"] is NSNull) && !(dictionary["ownerDocumentNumber"] is NSNull)){
        tempArray.add("\( dictionary["ownerDocumentSeries"] as? String ?? "") \(dictionary["ownerDocumentNumber"] as? String ?? "")")
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["ownerDocumentDate"]  is NSNull)){
        tempArray.add(dateFromJSON(dictionary["ownerDocumentDate"] as! String))
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["ownerDocumentRegistrator"]  is NSNull)){
        tempArray.add(dictionary["ownerDocumentRegistrator"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["ownerAddress"]  is NSNull)){
        tempArray.add(dictionary["ownerAddress"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["ownerStreet"]  is NSNull)){
        tempArray.add(dictionary["ownerStreet"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["ownerHouse"]  is NSNull)){
        tempArray.add(dictionary["ownerHouse"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["ownerHousing"]  is NSNull)){
        tempArray.add(dictionary["ownerHousing"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["ownerFlat"]  is NSNull)){
        tempArray.add(dictionary["ownerFlat"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    if(!(dictionary["ownerIndex"]  is NSNull)){
        tempArray.add(dictionary["ownerIndex"] as? String as Any)
    }else{
        tempArray.add("Нет данных")
    }
    return tempArray
}


func insuranceIsHave(dictionary: [String:Any]) -> Bool {
    
    if(!(dictionary["insurantBirthPlace"] is NSNull) || !(dictionary["insurantFullName"] is NSNull) || !(dictionary["insurantDate"] is NSNull) || !(dictionary["insurantPhone"] is NSNull) || !(dictionary["insurantDocumentType"] is NSNull) || !(dictionary["insurantDocumentSeries"] is NSNull) || !(dictionary["insurantDocumentNumber"] is NSNull) || !(dictionary["insurantDocumentDate"] is NSNull) || !(dictionary["insurantDocumentRegistrator"] is NSNull)  || !(dictionary["insurantAddress"] is NSNull) || !(dictionary["insurantStreet"] is NSNull) || !(dictionary["insurantHouse"] is NSNull) || !(dictionary["insurantHousing"] is NSNull) || !(dictionary["insurantFlat"] is NSNull) || !(dictionary["insurantIndex"] is NSNull) ){
        return true
    }
    return false
}

func ownerIsHave(dictionary: [String:Any]) -> Bool {
    if( (dictionary["insurantIsOwner"] as? Bool) == false){
        if( !(dictionary["ownerFullName"] is NSNull) || !(dictionary["ownerDate"] is NSNull) || !(dictionary["ownerPhone"] is NSNull) || !(dictionary["ownerDocumentType"] is NSNull) || !(dictionary["ownerDocumentSeries"] is NSNull) || !(dictionary["ownerDocumentNumber"] is NSNull) || !(dictionary["ownerDocumentDate"] is NSNull) || !(dictionary["ownerDocumentRegistrator"] is NSNull)   || !(dictionary["ownerAddress"] is NSNull) || !(dictionary["ownerStreet"] is NSNull) || !(dictionary["ownerHouse"] is NSNull) || !(dictionary["ownerFlat"] is NSNull) || !(dictionary["ownerIndex"] is NSNull) ){
            return true
        }
    }
    return false
}

func cardIsHave(dictionary: [String:Any]) -> Bool{
    if(state == 7){
        if( !(dictionary["payCardPaymentSystem"] is NSNull) || !(dictionary["payCardFirstName"] is NSNull) || !(dictionary["payCardLastName"] is NSNull) || !(dictionary["payCardMonth"] is NSNull) || !(dictionary["payCardYear"] is NSNull) || !(dictionary["payCardNumber"] is NSNull) || !(dictionary["payCardCVC"] is NSNull)){
            return true
        }
    }
    return false
}

func vehicleIsHave(dictionary: [String:Any]) -> Bool{
    if( !(dictionary["vehicleModel"] is NSNull) || !(dictionary["vehicleCategory"] is NSNull) || !(dictionary["vehicleYear"] is NSNull) || !(dictionary["vehicleNumber"] is NSNull) || !(dictionary["vehicleVIN"] is NSNull) || !(dictionary["vehicleBody"] is NSNull) || !(dictionary["vehicleChassis"] is NSNull) || !(dictionary["vehicleTarget"] is NSNull) || !(dictionary["vehicleHorsePower"] is NSNull) || !(dictionary["vehicleKWPower"] is NSNull) || !(dictionary["vehicleMaxMass"] is NSNull) || !(dictionary["vehicleMass"] is NSNull)  || !(dictionary["cardNumber"] is NSNull) || !(dictionary["cardDate"] is NSNull) || !(dictionary["cardValidity"] is NSNull) || !(dictionary["vehiclePassportSeries"] is NSNull) || !(dictionary["vehiclePassportNumber"] is NSNull) || !(dictionary["vehiclePassportDate"] is NSNull)  || !(dictionary["vehicleCertificateSeries"] is NSNull) || !(dictionary["vehicleCertificateNumber"] is NSNull) || !(dictionary["vehicleCertificateDate"] is NSNull)  || !(dictionary["vehicleSeats"] is NSNull)){
        return true
    }
    return false
}

func dateFromJSON(_ JSONdate: String) -> String {
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    let dateFormatterPrint = DateFormatter()
    dateFormatterPrint.dateFormat = "yyyy-MM-dd"
    dateFormatterPrint.dateStyle = DateFormatter.Style.short
    dateFormatterPrint.locale = NSLocale(localeIdentifier: "ru") as Locale
    
    let date = dateFormatterGet.date(from: JSONdate)
    
    return dateFormatterPrint.string(from: date!)
}

