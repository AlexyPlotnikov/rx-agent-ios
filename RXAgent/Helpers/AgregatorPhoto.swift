//
//  AgregatorPhoto.swift
//  RXAgent
//
//  Created by RX Group on 21/02/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import Foundation
import UIKit

var summArray: NSMutableArray = []
var indexInsuranceArray:NSMutableArray=[]
var images: NSMutableArray = []
var bonusArray: NSMutableArray = []
var insuranceIdArray:NSMutableArray = []
var commentArray:NSMutableArray = []
var isInsurance = false

var summAPI: NSMutableArray = []
var indexInsuranceAPI:NSMutableArray=[]
var imagesAPI: NSMutableArray = []
var bonusAPI: NSMutableArray = []
var insuranceIdAPI:NSMutableArray = []
var commentAPI:NSMutableArray = []
var newDateAPI:NSMutableArray = []
var statusesAPI:NSMutableArray = []

var firstLabels:NSMutableArray  = ["ПАСПОРТ","ПАСПОРТ","ДКП","ВРЕМЕННАЯ РЕГИСТРАЦИЯ" ,"ПАСПОРТ","ПАСПОРТ","ДКП","ВРЕМЕННАЯ РЕГИСТРАЦИЯ" ,"ПТС","ПТС","СРТС","СРТС","ВУ 1-я сторона","ВУ 2-я сторона","ВУ 1-я сторона","ВУ 2-я сторона","ВУ 1-я сторона","ВУ 2-я сторона","ВУ 1-я сторона","ВУ 2-я сторона",]

var secondLabels:NSMutableArray  = ["1-я сторона","Регистрация"," "," " ,"1-я сторона","Регистрация"," "," ", "1-я сторона","2-я сторона","1-я сторона","2-я сторона" ,"Водитель №1","Водитель №1","Водитель №2","Водитель №2","Водитель №3","Водитель №3","Водитель №4","Водитель №4"]
var titles1:NSMutableArray = ["СТРАХОВАТЕЛЬ", "СОБСТВЕННИК", "ТС","ВОДИТЕЛИ","КАРТА","УСЛОВИЯ"]

var miniPhoto: NSMutableArray = []
var miniatureArray: NSMutableArray = ["","","","" ,"","","","" ,"","","","" ,"","" ,"","" ,"","" ,"",""]

var policyDriverArray:NSMutableArray = ["","","",""]
var idDriverArray:NSMutableArray = ["","","",""]
var activeItem = 1
var countItems = 4
var plusCoef = 0
var category = "B - Легковая"
var targetVehicle = "Личная"
var categoryID = "1"
var targetID = "2"
var namePolice = ""
var insuranceID = ""




var mainID = ""
var profileID = ""

var hidePayCard:Bool?


//переменные для отправки
var isEdit = true

var currentIndex = 0

var loadingArray:NSMutableArray = [false, false, false,false ,false, false, false,false, false,false,false,false ,false,false,false,false,false,false,false,false]

func clearAgregator(){
    DiscountObject.sharedInstance().discount = nil
    DiscountObject.sharedInstance().promoText = ""
    isOwner = true
    hasDKPInsurance = false
    hasRegInsurance = false
    passport1Ins = ""
    passport2Ins = ""
    DKPIns = ""
    regIns = ""
    imagesInsurance = [UIImage(named: "passport 1") as Any,UIImage(named: "passport 2") as Any,UIImage(named: "DKP") as Any,UIImage(named: "registration") as Any]
    countRows = 2
    countOptions = 3
    countRowVehicle = 7
    passport1Owner = ""
    passport2Owner = ""
    imagesOwner = [UIImage(named: "passport 1") as Any,UIImage(named: "passport 2") as Any,UIImage(named: "DKP") as Any,UIImage(named: "registration") as Any]
    countRowsOwner = 2
    countOptionsOwner = 2
    targetVehicleID = 1
    targetVehicleTitle = "Личная"
    categoryVehicleID = 2
    categoryVehicleTitle = "B - Легковая"
    gosNumberEmpty = false
    trailerEmpty = false
    needPTS = true
    PTSidFront = ""
    PTSidBack = ""
    SRTSidFront = ""
    SRTSidBack = ""
    imagesPTS = [UIImage(named: "PTS 1") as Any,UIImage(named: "PTS 2") as Any]
    imagesSRTS = [UIImage(named: "SRTS 1") as Any,UIImage(named: "SRTS 2") as Any]
    isMultiDrive = false
    countDriver = 1
    imagesDriver = [UIImage(named: "VU 1") as Any, UIImage(named: "VU 2") as Any, UIImage(named: "VU 1") as Any, UIImage(named: "VU 2") as Any, UIImage(named: "VU 1") as Any, UIImage(named: "VU 2") as Any, UIImage(named: "VU 1") as Any, UIImage(named: "VU 2") as Any]
    vu1Driver1 = ""
    vu2Driver1 = ""
    vu1Driver2 = ""
    vu2Driver2 = ""
    vu1Driver3 = ""
    vu2Driver3 = ""
    vu1Driver4 = ""
    vu2Driver4 = ""
    cardNumber = ""
    cardYear = ""
    cardMonth = ""
    cardCvc = ""
    creditLastName = ""
    creditFirstName = ""
    cardArray = [[String:String]]()
    creatorWeekdaysTimeStart = ""
    creatorWeekdaysTimeEnd = ""
    creatorSaturdayTimeStart = ""
    creatorSaturdayTimeEnd = ""
    creatorSundayTimeStart = ""
    creatorSundayTimeEnd = ""
    weeklyChecked = true
    saturdayChecked = true
    sundayChecked = true
    periodArray = []
    periodTitle = "1 год"
    periodID = 12
    tempIndexPeriod = 2
    propertyDateStart = ""
    dateStartForTable = ""
    fullNameInsurance = ""
    creatorInsurance = ""
    phoneInsurance = ""
    creatorPhone = ""
    commentInsurance = ""
    commentAgent = ""
    loadInsurance = [false,false,false,false]
    loadOwner = [false,false,false,false]
    loadPTS = [false,false]
    loadSRTS = [false,false]
    loadDriver = [false,false,false,false,false,false,false,false]
    
    //калькулятор
    
     needCity = false
     isRegion = true

     regionCalc = "Не выбрано"
     
     regionID = ""
     cityCalc = "Не выбрано"
     cityID = ""
     type = "Физическое лицо"
     tempindexType = 0
     transportation = false
     power = ""
     moreTon = false
     morePlaces = false
     driversArray = []
 
}
