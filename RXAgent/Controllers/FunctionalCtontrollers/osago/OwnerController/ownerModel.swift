//
//  ownerModel.swift
//  RXAgent
//
//  Created by RX Group on 09/08/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import Foundation
import UIKit

var passport1Owner = ""
var passport2Owner = ""

var imagesOwner:NSMutableArray = [UIImage(named: "passport 1") as Any,UIImage(named: "passport 2") as Any,UIImage(named: "DKP") as Any,UIImage(named: "registration") as Any]
var countRowsOwner = 2
var countOptionsOwner = 2
var loadOwner:NSMutableArray = [false,false,false,false]


func checkOwnerAccess()->(emptysIndex: NSMutableArray,isEmptIns: Bool){
    var isEmptyIns = true
    let tempIns : NSMutableArray = []
    
    if(passport1Owner.isEmpty){
        isEmptyIns = false
        tempIns.add(0)
    }
    if(passport2Owner.isEmpty){
        isEmptyIns = false
        tempIns.add(1)
    }
    if(hasDKPInsurance){
        if(DKPIns.isEmpty){
            isEmptyIns = false
            tempIns.add(2)
        }
    }
    if(hasRegInsurance){
        if(regIns.isEmpty){
            isEmptyIns = false
            tempIns.add(3)
        }
    }
    return (tempIns, isEmptyIns)
}


func ownerImagesLoad()->Bool{
    var isLoaded = false
 
    if((imagesOwner[0] as! UIImage).size.width != 95 && (imagesOwner[1] as! UIImage).size.width != 95){
        isLoaded=true
       
            if(hasDKPInsurance){
                if((imagesOwner[2] as! UIImage).size.width != 95){
                    isLoaded=true
                }else{
                    isLoaded=false
                }
            }else{
                isLoaded=true
            }
            if(hasRegInsurance){
                if((imagesOwner[3] as! UIImage).size.width != 95){
                    isLoaded=true
                }else{
                    isLoaded=false
                }
            }else{
                if(isLoaded){
                    isLoaded=true
                }
            }
        
    }else{
        isLoaded=false
    }
    return isLoaded
}
