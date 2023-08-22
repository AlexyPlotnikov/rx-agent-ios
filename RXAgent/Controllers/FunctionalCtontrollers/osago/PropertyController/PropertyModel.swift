//
//  PropertyModel.swift
//  RXAgent
//
//  Created by RX Group on 20/08/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import Foundation

var propertySubtitle = [["Дата начала", "Период страхования"],[ "Фамилия страхователя","Телефон страхователя"],["Ваше имя","Ваш номер телефона"]]

var periodArray:NSMutableArray = []

var periodTitle = "1 год"
var periodID = 12
var tempIndexPeriod = 2

var propertyDateStart = ""
var dateStartForTable = ""

var fullNameInsurance = ""
var phoneInsurance = ""

var creatorInsurance = ""
var creatorPhone = ""

var commentInsurance = ""
var commentAgent = ""

func checkPropertyAccess()->(emptysIndex: NSMutableArray,isEmptIns: Bool){
    var isEmptyIns = true
    let tempIns : NSMutableArray = []

    if(!fullNameInsurance.isEmpty){
        isEmptyIns=true
    }else{
        isEmptyIns = false
        tempIns.add(2)
    }
    if(!creatorPhone.isEmpty){
        isEmptyIns=true
    }else{
        isEmptyIns = false
        tempIns.add(3)
    }
    if(!creatorInsurance.isEmpty){
        isEmptyIns=true
    }else{
        isEmptyIns = false
        tempIns.add(4)
    }
    
    if(!phoneInsurance.isEmpty){
        isEmptyIns=true
    }else{
        isEmptyIns = false
        tempIns.add(5)
    }
       return (tempIns, isEmptyIns)
    }
    
    


func propertyIsFull()->Bool{
    if(creatorPhone.hasPrefix("7")){
        creatorPhone.removeFirst()
    }
    if(phoneInsurance.hasPrefix("7")){
        phoneInsurance.removeFirst()
    }
   
    
    if(!propertyDateStart.isEmpty && !fullNameInsurance.isEmpty && !creatorInsurance.isEmpty && phoneInsurance.count == 10 && creatorPhone.count == 10){
         return true
    }else{
         return false
    }
}
