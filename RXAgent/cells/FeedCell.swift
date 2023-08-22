//
//  FeedCell.swift
//  RXAgent
//
//  Created by RX Group on 25/01/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var numberPolice: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var autoLbl: UILabel!
    @IBOutlet weak var state: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setPrice(isRX:Bool, finalBonus:Int?, baseCost:Int?, state:Int, `super`:String?){
        if(isRX){
            
            guard `super` != nil else {
                if(state == 0){
                    self.priceLbl.isHidden = true
                }else{
                    self.priceLbl.text = "-\((baseCost ?? 0).formattedWithSeparator) ₽"//String(format: "-%.0d ₽",)
                    self.priceLbl.isHidden = false
                    self.priceLbl.textColor = UIColorFromRGB(rgbValue: 0xE47171, alphaValue: 1)
                }
                return
            }
            
                self.priceLbl.isHidden = false
                self.priceLbl.textColor = UIColorFromRGB(rgbValue: 0xA3CD3A, alphaValue: 1)
                self.priceLbl.text = "+\((finalBonus ?? 0).formattedWithSeparator) ₽"
            
        }else{
            if(`super` == nil || finalBonus == nil){
                self.priceLbl.isHidden = true
            }else{
                self.priceLbl.isHidden = false
                self.priceLbl.textColor = UIColorFromRGB(rgbValue: 0xA3CD3A, alphaValue: 1)
                self.priceLbl.text = "+\((finalBonus ?? 0).formattedWithSeparator) ₽"
            }
            
        }
    }
    
    func setStatus(state: Int, isShort: Bool, isPaid: Bool, isInsurance:Bool){
       
        self.state.text = "В ОБРАБОТКЕ";
        self.state.textColor = UIColorFromRGB(rgbValue: 0x3289EA, alphaValue: 1)
        
        if(state == 0){//small
            if(isInsurance){
                self.state.text = "ОТПРАВЬТЕ В ОБРАБОТКУ"
                 self.state.textColor = UIColorFromRGB(rgbValue: 0x00DF6E, alphaValue: 1)
                
            }else{
                 self.state.textColor = UIColorFromRGB(rgbValue: 0xF7C060, alphaValue: 1)
                 self.state.text = "НОВАЯ ЗАЯВКА"
            }
        }
        
        if(state == 7){
            self.state.textColor = UIColorFromRGB(rgbValue: 0x9984FC, alphaValue: 1)
            self.state.text = "УКАЖИТЕ СМС-КОД"
        }
        
        if(state == 1){//small
            self.state.textColor = UIColorFromRGB(rgbValue: 0x4ACAE8, alphaValue: 1)
            self.state.text = "ЗАЯВКА ОТПРАВЛЕНА"
        }
        
        if(state == 3){
            self.state.textColor = UIColorFromRGB(rgbValue: 0xCDCE20, alphaValue: 1)
            self.state.text = "ПРИМИТЕ УСЛОВИЯ"
        }
        
        if(state == 4){//small
            self.state.textColor = UIColorFromRGB(rgbValue: 0xE47171, alphaValue: 1)
            self.state.text = "ЗАЯВКА ОТМЕНЕНА"
        }
        
        if(state == 254){
            if(!isPaid){
                self.state.textColor = UIColorFromRGB(rgbValue: 0xFACE54, alphaValue: 1)
               self.state.text = "ОЖИДАЕТ ОПЛАТЫ"
            }else{
                self.state.textColor = UIColorFromRGB(rgbValue: 0xB0C977, alphaValue: 1)
                 self.state.text = "УСПЕШНО ОФОРМЛЕНА"
                
            }
        }
       
    }
    
    func UIColorFromRGB(rgbValue: UInt, alphaValue: CGFloat) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alphaValue)
        )
    }
}
