//
//  DriverModel.swift
//  RXAgent
//
//  Created by RX Group on 15/08/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import Foundation
import UIKit

var isMultiDrive = false
var countDriver = 1

var titleDriver:NSMutableArray = ["ВУ 1-я сторона","ВУ 2-я сторона","ВУ 1-я сторона","ВУ 2-я сторона","ВУ 1-я сторона","ВУ 2-я сторона","ВУ 1-я сторона","ВУ 2-я сторона"]
var subtitleDriver:NSMutableArray = ["Водитель №1","Водитель №1","Водитель №2","Водитель №2","Водитель №3","Водитель №3","Водитель №4","Водитель №4"]

var imagesDriver:NSMutableArray = [UIImage(named: "VU 1") as Any, UIImage(named: "VU 2") as Any, UIImage(named: "VU 1") as Any, UIImage(named: "VU 2") as Any, UIImage(named: "VU 1") as Any, UIImage(named: "VU 2") as Any, UIImage(named: "VU 1") as Any, UIImage(named: "VU 2") as Any]

var datesArray:NSMutableArray = ["","","",""]

var vu1Driver1 = ""
var vu2Driver1 = ""

var vu1Driver2 = ""
var vu2Driver2 = ""

var vu1Driver3 = ""
var vu2Driver3 = ""

var vu1Driver4 = ""
var vu2Driver4 = ""
var loadDriver:NSMutableArray = [false,false,false,false,false,false,false,false]

func driverImagesLoad()->Bool{
    
    if(isMultiDrive){
        return true
    }
    var isLoaded = false
    for i in 0..<countDriver*2{
        if((imagesDriver[i] as! UIImage).size.width != 95){
            isLoaded=true
        }else{
            return false
        }
    }
    
    
    return isLoaded
}

func checkDriverAccess()->(emptysIndex: NSMutableArray,isEmptIns: Bool){
    var isEmptyIns = true
    let tempIns : NSMutableArray = []
    
    if(isMultiDrive){
        return (tempIns, true)
    }
    
    for i in 0..<countDriver*2{
        if(i==0||i==1){
            if(!vu1Driver1.isEmpty && !vu2Driver1.isEmpty){
                isEmptyIns=true
            }else{
                isEmptyIns = false
                tempIns.add(0)
                tempIns.add(1)
            }
        }
        if(i==2||i==3){
            if(!vu1Driver2.isEmpty && !vu2Driver2.isEmpty){
                isEmptyIns=true
            }else{
                isEmptyIns = false
                tempIns.add(2)
                tempIns.add(3)
            }
        }
        if(i==4||i==5){
            if(!vu1Driver3.isEmpty && !vu2Driver3.isEmpty){
                isEmptyIns=true
            }else{
                isEmptyIns = false
                tempIns.add(4)
                tempIns.add(5)
            }
        }
        if(i==6||i==7){
            if(!vu1Driver4.isEmpty && !vu2Driver4.isEmpty){
                isEmptyIns=true
            }else{
                isEmptyIns = false
                tempIns.add(6)
                tempIns.add(7)
            }
        }
    }
    
    
    return (tempIns, isEmptyIns)
}
