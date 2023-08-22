//
//  DatePTOModel.swift
//  RXAgent
//
//  Created by RX Group on 08.07.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import Foundation

struct PTODate:Codable{
    let aviableTimes:[String]?
}

class DatePTOModel{
    
    private static var shared : DatePTOModel?

    class func sharedInstance() -> DatePTOModel {
        guard let uwShared = shared else {
            shared = DatePTOModel()
            return shared!
        }
        return uwShared
    }
    
    class func reload() {
            shared = nil
        }
    
    var timeArray:[String]?
    
    var choosenDate:Date = Date()
    var choosenTime:String = ""
    
    var choosenDateFormated:String{
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        dateformatter.timeZone = TimeZone.current
        return dateformatter.string(from: choosenDate)
    }
    
    var timeChoosen:Bool{
        return choosenTime != ""
    }
    
    func loadTimeByDate(date:String, category:Int, categoriesReady:@escaping ((Bool, [String]?))->Void){
        
        let profileID = String(format: "%04d", Profile.shared.profile?.contractor?.id ?? 0)
        getRequest(URLString: newDomain + "/api/v1/AgentsRecords/agents/\(profileID)/aviable/cells/times?" + "date=\(date)" + "&" + "category=\(category)", needSecretKey: true, completion: {
            result in
            DispatchQueue.main.async {
               
                do {
                    
                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                    self.timeArray = try! JSONDecoder().decode(PTODate.self, from: jsonData).aviableTimes
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyy-MM-dd"
                    dateformatter.timeZone = TimeZone.current
                    if(dateformatter.date(from: date)!.onlyDate == Date().onlyDate){
                        let dateformatterTime = DateFormatter()
                        dateformatterTime.dateFormat = "HH:mm"
                        dateformatterTime.timeZone = TimeZone.current
                        self.timeArray = self.timeArray?.filter{$0 >= dateformatterTime.string(from: Date())}
                    }
                    categoriesReady((true, self.timeArray))
                }catch{
                    categoriesReady((false, nil))
                }
            }
            
        })
    }
    
    
    func reloadModel(){
         timeArray = nil
         choosenDate = Date()
         choosenTime = ""
    }
    
}


