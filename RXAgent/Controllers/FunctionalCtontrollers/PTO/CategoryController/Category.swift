//
//  Category.swift
//  RXAgent
//
//  Created by Иван Зубарев on 25.06.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import Foundation


struct CategoryStruct: Codable{
    var id: Int
    var vehicleCategoryID: Int
    var vehicleCategoryTitle: String
    var title: String
    var vehicleType: String
    var description: String
}


class Category{
    
    
    private static var shared : Category?

    class func sharedInstance() -> Category {
        guard let uwShared = shared else {
            shared = Category()
            return shared!
        }
        return uwShared
    }
    
    class func reload() {
            shared = nil
        }
    
    var categories: [CategoryStruct]?
    
    var currentCategoryID:Int!
    
    func loadCategories(categoriesReady:@escaping ((Bool, [CategoryStruct]?))->Void){
        getArrayRequest(URLString: newDomain + "/api/v1/Vehicles/categories", needSecretKey: true, completion: {
            result in
            DispatchQueue.main.async {
                do {
                //    print(result)
                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                    self.categories = try! JSONDecoder().decode([CategoryStruct].self, from: jsonData)
                    categoriesReady((true, self.categories))
                }catch{
                    categoriesReady((false, nil))
                }
            }
            
        })
    }
    
    
    
    var getUniqueCategoryTitle:[CategoryStruct]{
        return (self.categories?.unique(map: {$0.vehicleCategoryTitle})) ?? []
    }
    
    func getSubcategoryByID(id:Int) -> [CategoryStruct]{
        return self.categories?.filter{$0.vehicleCategoryID == id} ?? []
    }
    
    func getLiteralCategoryByIndex(index:Int)->String{
        switch index {
        case 1:
            return "A"
        case 2...3:
            return "B"
        case 4...5:
            return "C"
        case 6...7:
            return "D"
        case 8...11:
            return "E"
        default:
            return ""
        }
    }
    
    func getLiteralSubactegoryByIndex(index:Int)->String{
        switch index {
        case 1:
            return "L"
        case 2:
            return "M1"
        case 3:
            return "N1"
        case 4:
            return "N2"
        case 5:
            return "N3"
        case 6:
            return "M2"
        case 7:
            return "M3"
        case 8:
            return "O1"
        case 9:
            return "O2"
        case 10:
            return "O3"
        case 11:
            return "O4"
        
        default:
            return ""
        }
    }
    
}

extension Array {
    func unique<T:Hashable>(map: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>()
        var arrayOrdered = [Element]()
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }

        return arrayOrdered
    }
}
