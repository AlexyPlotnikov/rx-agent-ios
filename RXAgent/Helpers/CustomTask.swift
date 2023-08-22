//
//  CustomTask.swift
//  RXAgent
//
//  Created by RX Group on 14/03/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import Foundation

struct CustomTask {
    
    let index:Int!
    let session:URLSession!
    let itemIndex:Int!
    
}

extension CustomTask: Equatable {
    static func == (lhs: CustomTask, rhs: CustomTask) -> Bool {
        return lhs.index == rhs.index && lhs.session == rhs.session && lhs.itemIndex == rhs.itemIndex
    }
}
