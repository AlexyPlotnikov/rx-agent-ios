//
//  TOCell.swift
//  RXAgent
//
//  Created by RX Group on 12.07.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import UIKit

class TOCell: UITableViewCell {
    
    @IBOutlet weak var numberLbl: UILabel!
    @IBOutlet weak var icon: UIView!
    @IBOutlet weak var carNameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var gosnumberCell: UILabel!
    
    func setStatusForCell(status:Int?, categoryID:Int, state:Int?){
        
        self.setupIconCategory(categoryID: categoryID)
        if state == 255 {
            self.icon.backgroundColor = UIColor.StatesColor.redColor
            self.state.text = "ЗАПИСЬ УДАЛЕНА"
            self.state.textColor = UIColor.StatesColor.redColor
            return
        }
        
        switch status {
        case 0:
            self.icon.backgroundColor = UIColor.StatesColor.noneColor
            self.state.text = "КЛИЕНТ ЗАПИСАН НА ТЕХОСМОТР"
            self.state.textColor = UIColor.StatesColor.noneColor
        case 100:
            self.icon.backgroundColor = UIColor.StatesColor.noneColor
            self.state.text = "НЕ ДОЗВОНИЛИСЬ"
            self.state.textColor = UIColor.StatesColor.noneColor
        case 101:
            self.icon.backgroundColor = UIColor.StatesColor.orangeColor
            self.state.text = "АВТОМОБИЛЬ ПРИЕДЕТ"
            self.state.textColor = UIColor.StatesColor.orangeColor
        case 201:
            self.icon.backgroundColor = UIColor.StatesColor.orangeColor
            self.state.text = "АВТОМОБИЛЬ ПРИЕХАЛ"
            self.state.textColor = UIColor.StatesColor.orangeColor
        case 200:
            self.icon.backgroundColor = UIColor.StatesColor.redColor
            self.state.text = "АВТОМОБИЛЬ НЕ ПРИЕХАЛ"
            self.state.textColor = UIColor.StatesColor.redColor
        case 300:
            self.icon.backgroundColor = UIColor.StatesColor.redColor
            self.state.text = "ТЕХОСМОТР НЕ ПРОЙДЕН"
            self.state.textColor = UIColor.StatesColor.redColor
        case 301:
            self.icon.backgroundColor = UIColor.StatesColor.greenColor
            self.state.text = "ТЕХОСМОТР ПРОЙДЕН"
            self.state.textColor = UIColor.StatesColor.greenColor
        default:
            self.icon.backgroundColor = UIColor.StatesColor.noneColor
            self.state.text = "КЛИЕНТ ЗАПИСАН НА ТЕХОСМОТР"
            self.state.textColor = UIColor.StatesColor.noneColor
        }
    }
    
    func setupIconCategory(categoryID:Int){
        for view in self.icon.subviews{
            view.removeFromSuperview()
        }
        
        self.icon.layer.cornerRadius = 10
        
        let categoryChar = UILabel(frame: CGRect(x: 0, y: 6, width: self.icon.frame.size.width, height: 12))
        categoryChar.text = Category.sharedInstance().getLiteralCategoryByIndex(index: categoryID)
        categoryChar.font = UIFont.boldSystemFont(ofSize: 14)
        categoryChar.textColor = .white
        categoryChar.textAlignment = .center
        self.icon.addSubview(categoryChar)
        
        let subcategoryChar = UILabel(frame: CGRect(x: 0, y: categoryChar.frame.maxY, width: self.icon.frame.size.width, height: 16))
        subcategoryChar.text = Category.sharedInstance().getLiteralSubactegoryByIndex(index: categoryID)
        subcategoryChar.font = UIFont.boldSystemFont(ofSize: 8)
        subcategoryChar.textColor = .white
        subcategoryChar.textAlignment = .center
        self.icon.addSubview(subcategoryChar)
    }

}


