//
//  CardModel.swift
//  RXAgent
//
//  Created by RX Group on 19/08/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import Foundation

var cardNumber = ""
var cardYear = ""
var cardMonth = ""
var cardCvc = ""
var creditLastName = ""
var creditFirstName = ""

var creatorWeekdaysTimeStart:String = ""
var creatorWeekdaysTimeEnd:String = ""
var creatorSaturdayTimeStart:String = ""
var creatorSaturdayTimeEnd:String = ""
var creatorSundayTimeStart:String = ""
var creatorSundayTimeEnd:String = ""
var weeklyChecked = true
var saturdayChecked = true
var sundayChecked = true


var cardIndex = 0

var cardArray = [[String:String]]()


var cardSubtitle = ["Номер", "Имя держателя", "Срок действия"]


func cardValidate()->Bool{
    var weekValid = false
    var saturdayValid = false
    var sundayValid = false
    
        weekValid = weeklyChecked
        saturdayValid = saturdayChecked
        sundayValid = sundayChecked
 
    if(hidePayCard ?? false){
        return (weekValid || saturdayValid || sundayValid)
    }else{
        if(!cardNumber.isEmpty && !cardYear.isEmpty && !cardMonth.isEmpty && !cardCvc.isEmpty && (weekValid || saturdayValid || sundayValid)){
            return true
        }else{
            return false
        }
    }
    
}
