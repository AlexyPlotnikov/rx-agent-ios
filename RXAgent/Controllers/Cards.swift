//
//  CardModel.swift
//  RXAgent
//
//  Created by RX Group on 31.08.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import Foundation

struct Card:Codable{
   var payCardLastName: String?
   var payCardYear: String?
   var payCardFirstName: String?
   var payCardNumber: String?
   var payCardCVC: String?
   var payCardMonth: String?
}

class Cards{
    
    private static var shared : Cards?

    class func sharedInstance() -> Cards {
        guard let uwShared = shared else {
            shared = Cards()
            return shared!
        }
        return uwShared
    }
    
    var cardsArray:[Card]?
    var scanedCard:Card!
    var editCardIndex = 0
    
    func loadCards(cardLoaded:@escaping ((Bool, [Card]?))->Void){
        if(isKeyPresentInUserDefaults(key: "cardData\(profileID)")){
            let defaults = UserDefaults.standard
            let array = defaults.array(forKey: "cardData\(profileID)") as! [[String : String]]
            let payCardLastName = array.compactMap{$0["payCardLastName"]}
            let payCardYear = array.compactMap{$0["payCardYear"]}
            let payCardFirstName = array.compactMap{$0["payCardFirstName"]}
            let payCardNumber = array.compactMap{$0["payCardNumber"]}
            let payCardCVC = array.compactMap{$0["payCardCVC"]}
            let payCardMonth = array.compactMap{$0["payCardMonth"]}
            var cardArray:[Card] = []
            for i in 0..<array.count{
                cardArray.append(Card(payCardLastName: payCardLastName[i], payCardYear: payCardYear[i], payCardFirstName: payCardFirstName[i], payCardNumber: payCardNumber[i], payCardCVC: payCardCVC[i], payCardMonth: payCardMonth[i]))
            }
            defaults.set(try? PropertyListEncoder().encode(cardArray), forKey:"newCardData\(profileID)")
            defaults.removeObject(forKey: "cardData\(profileID)")
        }
        if let cardData = UserDefaults.standard.object(forKey: "newCardData\(profileID)") as? Data {
           if let cards = try? PropertyListDecoder().decode([Card].self, from: cardData){
            cardsArray = cards
            cardLoaded((true, cardsArray))
           }
        }else{
            cardLoaded((false, nil))
        }
    }
    
    func saveEditingCard(cardToSave:Card, saved:@escaping (Bool)->Void){
        cardsArray![editCardIndex] = cardToSave
        let defaults = UserDefaults.standard
        defaults.set(try? PropertyListEncoder().encode(cardsArray), forKey:"newCardData\(profileID)")
        saved(true)
    }
    
    var editingCard:Card {
        return cardsArray![editCardIndex]
    }
    
    func saveCard(){
        if(cardsArray == nil){
            cardsArray = []
        }
        cardsArray?.append(scanedCard)
        let defaults = UserDefaults.standard
        defaults.set(try? PropertyListEncoder().encode(cardsArray), forKey:"newCardData\(profileID)")
    }
    
    func removeCardByIndex(index:Int,deleted:@escaping (Bool)->Void){
        cardsArray?.remove(at: index)
        let defaults = UserDefaults.standard
        defaults.set(try? PropertyListEncoder().encode(cardsArray), forKey:"newCardData\(profileID)")
        self.loadCards { (loaded, _) in
            deleted(true)
        }
        
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func checkDuplicate(number:String)->Bool{
        return (cardsArray ?? []).contains(where: {$0.payCardNumber == number})
    }
    
}
