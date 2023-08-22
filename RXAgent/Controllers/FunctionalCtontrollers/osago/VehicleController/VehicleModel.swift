//
//  VehicleModel.swift
//  RXAgent
//
//  Created by RX Group on 12/08/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import Foundation
import UIKit

var countRowVehicle = 7

var targetVehicleID = 1
var targetVehicleTitle = "Личная"

var categoryVehicleID = 2
var categoryVehicleTitle = "B - Легковая"

var titlesVehicle = ["","","Госномер отсутствует","Используется с прицепом","Прикрепить СРТС"]
var gosNumberEmpty = false
var trailerEmpty = false

var needPTS = true

var PTSidFront = ""
var PTSidBack = ""

var SRTSidFront = ""
var SRTSidBack = ""


var PTStitle:NSMutableArray = ["ПТС","ПТС"]
var SRTStitle:NSMutableArray = ["СРТС","СРТС"]

var SubtitleArray:NSMutableArray = ["1-я сторона","2-я сторона"]

var imagesPTS:NSMutableArray = [UIImage(named: "PTS 1") as Any,UIImage(named: "PTS 2") as Any]

var imagesSRTS:NSMutableArray = [UIImage(named: "SRTS 1") as Any,UIImage(named: "SRTS 2") as Any]
var loadPTS:NSMutableArray = [false,false]
var loadSRTS:NSMutableArray = [false,false]

func checkVehicleAccess()->(emptysIndex: NSMutableArray,isEmptIns: Bool){
    var isEmptyIns = true
    let tempIns : NSMutableArray = []
    if(needPTS){
        if(PTSidFront.isEmpty){
            isEmptyIns = false
            tempIns.add(0)
        }
        if(PTSidBack.isEmpty){
            isEmptyIns = false
            tempIns.add(1)
        }
    }else{
        
        if(SRTSidFront.isEmpty){
            isEmptyIns = false
            tempIns.add(0)
        }
        if(SRTSidBack.isEmpty){
            isEmptyIns = false
            tempIns.add(1)
        }
    }
  

    
    
    return (tempIns, isEmptyIns)
}

func vehicleImagesLoad()->Bool{
    var isLoaded = false
    if(needPTS){
        if((imagesPTS[0] as! UIImage).size.width != 95 && (imagesPTS[1] as! UIImage).size.width != 95){
            isLoaded=true
        }else{
            isLoaded=false
        }
    }else{
        if((imagesSRTS[0] as! UIImage).size.width != 95 && (imagesSRTS[1] as! UIImage).size.width != 95){
            isLoaded=true
        }else{
            isLoaded=false
        }
    }
    return isLoaded
}
