//
//  InsuranceModel.swift
//  RXAgent
//
//  Created by Алексей on 05.08.2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

    var isOwner = true
    var hasDKPInsurance = false
    var hasRegInsurance = false
    var passport1Ins = ""
    var passport2Ins = ""
    var DKPIns = ""
    var regIns = ""
    var imagesInsurance:NSMutableArray = [UIImage(named: "passport 1") as Any,UIImage(named: "passport 2") as Any,UIImage(named: "DKP") as Any,UIImage(named: "registration") as Any]
    var countRows = 2
    var countOptions = 3
    var loadInsurance:NSMutableArray = [false,false,false,false]

func checkInsuranceAccess()->(emptysIndex: NSMutableArray,isEmptIns: Bool){
    var isEmptyIns = true
    let tempIns : NSMutableArray = []
   
    if(passport1Ins.isEmpty){
        isEmptyIns = false
        tempIns.add(0)
    }
    if(passport2Ins.isEmpty){
        isEmptyIns = false
        tempIns.add(1)
    }
    if(isOwner){
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
    }
    return (tempIns, isEmptyIns)
}


func insuranceImagesLoad()->Bool{
    var isLoaded = false

        if((imagesInsurance[0] as! UIImage).size.width != 95 && (imagesInsurance[1] as! UIImage).size.width != 95){
            isLoaded=true
            if(isOwner){
                if(hasDKPInsurance){
                    if((imagesInsurance[2] as! UIImage).size.width != 95){
                        isLoaded=true
                    }else{
                        isLoaded=false
                    }
                }else{
                     isLoaded=true
                }
                if(hasRegInsurance){
                    if((imagesInsurance[3] as! UIImage).size.width != 95){
                        isLoaded=true
                    }else{
                        isLoaded=false
                    }
                }else{
                    if(isLoaded){
                        isLoaded=true
                    }
                }
            }
        }else{
            isLoaded=false
        }
    return isLoaded
}
