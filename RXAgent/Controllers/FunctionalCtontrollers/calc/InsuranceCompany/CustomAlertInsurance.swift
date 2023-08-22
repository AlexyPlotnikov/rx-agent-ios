//
//  CustomAlertInsurance.swift
//  RXAgent
//
//  Created by RX Group on 01.10.2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

public protocol CustomAlertDelegate: class {
    func alertDidClicked(insurance: String)
}

class CustomAlertInsurance: UIView {
    var alertView:UIView!
    var header:UIView!
    var imageView:UIImageView!
    var titleLbl:UILabel!
    var bonuslbl:UILabel!
    var costLbl:UILabel!
    var titleBonus:UILabel!
    var titleCost:UILabel!
    var currentInsurance:String = ""
    public weak var delegate: CustomAlertDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialization()
        self.setNeedsDisplay()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialization()
        self.setNeedsDisplay()
    }

    func initialization(){
        let backgroundView = UIButton(frame: self.frame)
        backgroundView.backgroundColor = UIColorFromRGB(rgbValue: 0x000000, alphaValue: 0.5)
        backgroundView.addTarget(self, action: #selector(self.closeWindow), for: .touchUpInside)
        self.addSubview(backgroundView)
        
        alertView = UIView(frame: CGRect(x: self.frame.size.width/2-self.frame.size.width*0.7/2, y:self.frame.size.height/2-self.frame.size.height*0.282/2, width: self.frame.size.width*0.75, height: 229))
        alertView.backgroundColor = .white
        backgroundView.addSubview(alertView)
        
        header = UIView(frame: CGRect(x: alertView.bounds.origin.x, y: alertView.bounds.origin.y-2, width: alertView.bounds.size.width, height: alertView.bounds.size.height*0.32))
        header.backgroundColor = .red
        header.roundCorners(corners: [.topLeft, .topRight], radius: 13)
        alertView.addSubview(header)
        
        imageView=UIImageView(frame: CGRect(x: header.bounds.size.width/2-header.bounds.size.width*0.75/2, y: header.bounds.size.height/2-header.bounds.size.height*0.75/2, width: header.bounds.size.width*0.75, height: header.bounds.size.height*0.75))
        imageView.contentMode = .scaleAspectFit
        header.addSubview(imageView)
        
        
        let newY = (alertView.bounds.origin.y+alertView.bounds.size.height)-70/3*2
        let checkButton = UIButton(frame: CGRect(x: alertView.frame.size.width/2-35, y:newY, width: 70, height: 70))
        checkButton.setImage(UIImage(named: "checkBtn"), for: .normal)
        checkButton.layer.cornerRadius = 35
        checkButton.bezierPathBorder(.white, width: 5)
        checkButton.addTarget(self, action: #selector(self.checkClicked), for: .touchUpInside)
        alertView.addSubview(checkButton)
        
        let newX = alertView.bounds.size.width-(alertView.bounds.size.width-(alertView.bounds.midX + 35))/2
        let cancelButton = UIButton(frame: CGRect(x: newX-35, y:newY+15, width: 66, height: 22))
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.titleLabel?.font =  UIFont(name: "Roboto-Regular", size: 14)
        cancelButton.addTarget(self, action: #selector(self.closeWindow), for: .touchUpInside)
        alertView.addSubview(cancelButton)
        
        titleLbl = UILabel(frame:CGRect(x: alertView.bounds.origin.x+10, y:( header.bounds.origin.y+header.bounds.size.height)+14, width: alertView.bounds.size.width-20 , height: 36))
        titleLbl.text = "Подтвердите оформление:"
        titleLbl.textColor = UIColorFromRGB(rgbValue: 0x282828, alphaValue: 1)
        titleLbl.font = UIFont(name: "Roboto-Regular", size: 17)
        titleLbl.textAlignment = .center
        titleLbl.numberOfLines = 2
        alertView.addSubview(titleLbl)
        
        titleBonus = UILabel(frame:CGRect(x: alertView.bounds.origin.x+34, y:(titleLbl.frame.origin.y+titleLbl.frame.size.height)+15, width: 94 , height: 14))
        titleBonus.text = "Стоимость"
        titleBonus.textColor = UIColorFromRGB(rgbValue: 0x9F9F9F, alphaValue: 1)
        titleBonus.font = UIFont(name: "Roboto-Regular", size: 14)
        titleBonus.textAlignment = .left
        alertView.addSubview(titleBonus)
        
        titleCost = UILabel(frame:CGRect(x: alertView.bounds.origin.x+34, y:( titleBonus.frame.origin.y+titleBonus.frame.size.height)+7, width: 47 , height: 14))
        titleCost.text = "Бонус"
        titleCost.textColor = UIColorFromRGB(rgbValue: 0x9F9F9F, alphaValue: 1)
        titleCost.font = UIFont(name: "Roboto-Regular", size: 14)
        titleCost.textAlignment = .left
        alertView.addSubview(titleCost)
        
        bonuslbl = UILabel(frame:CGRect(x: alertView.bounds.origin.x+24, y: titleBonus.frame.origin.y, width: 94 , height: 18))
        bonuslbl.text = "2 200 ₽"
        bonuslbl.textColor = UIColorFromRGB(rgbValue: 0x282828, alphaValue: 1)
        bonuslbl.font = UIFont(name: "Roboto-Bold", size: 15)
        bonuslbl.textAlignment = .right
        alertView.addSubview(bonuslbl)
        
        costLbl = UILabel(frame:CGRect(x: alertView.bounds.origin.x+24, y: titleCost.frame.origin.y, width: 94 , height: 18))
        costLbl.text = "14 000 ₽"
        costLbl.textColor = UIColorFromRGB(rgbValue: 0x282828, alphaValue: 1)
        costLbl.font = UIFont(name: "Roboto-Bold", size: 15)
        costLbl.textAlignment = .right
        alertView.addSubview(costLbl)
        
        
    }
    
    @objc func checkClicked(){
        self.removeFromSuperview()
        delegate?.alertDidClicked(insurance: self.currentInsurance)
    }
    
    func setColorHeader(ins:String){
        switch ins {
        case "alphaSuper":
            header.backgroundColor = #colorLiteral(red: 0.9498009086, green: 0.09344961494, blue: 0.1578891277, alpha: 1)
            imageView.image = UIImage(named: "alfaIns")
        case "ingos":
            header.backgroundColor = #colorLiteral(red: 0, green: 0.3133562207, blue: 0.6586090326, alpha: 1)
            imageView.image = UIImage(named: "ingosIns")
        case "vsk":
            header.backgroundColor = #colorLiteral(red: 0.1446729302, green: 0.4005192518, blue: 0.6891764402, alpha: 1)
            imageView.image = UIImage(named: "vskIns")
        case "vskSuper":
            header.backgroundColor = #colorLiteral(red: 0.1446729302, green: 0.4005192518, blue: 0.6891764402, alpha: 1)
            imageView.image = UIImage(named: "vskIns")
        case "resoSuper":
            header.backgroundColor = #colorLiteral(red: 0, green: 0.597632885, blue: 0.2888221443, alpha: 1)
            imageView.image = UIImage(named: "resoIns")
        case "renessansSuper":
            header.backgroundColor = #colorLiteral(red: 0.4045217633, green: 0.1203874424, blue: 0.5110306144, alpha: 1)
            imageView.image = UIImage(named: "renesIns")
        case "rx":
            let gradient = CAGradientLayer()
            gradient.frame = self.header.bounds
            gradient.colors = [UIColorFromRGB(rgbValue: 0x32294C, alphaValue: 1).cgColor, UIColorFromRGB(rgbValue: 0x3B1D37, alphaValue: 1).cgColor]
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
            self.header.layer.insertSublayer(gradient, at: 0)
            self.imageView.image = UIImage(named: "RXIns")
        case "zettaSuper":
             header.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
             imageView.image = UIImage(named: "ins-zetta")
        case "soglasieSuper":
            header.backgroundColor = #colorLiteral(red: 1, green: 0.4039215686, blue: 0.003921568627, alpha: 1)
            imageView.image = UIImage(named: "soglas")
        case "rgs":
             header.backgroundColor = #colorLiteral(red: 0.7267429233, green: 0.0254318174, blue: 0.07063313574, alpha: 1)
             imageView.image = UIImage(named: "rosgosIns")
        default:
            break
        }
    }
    
    func setValuesAlert(insurance:String, bonus:String, cost:String){
        self.setColorHeader(ins: insurance)
        self.currentInsurance = insurance
        if(insurance != "rx"){
            let bonusWidth = bonus.widthSize + CGFloat(20)
            let costWidth = cost.widthSize + CGFloat(20)
            
            titleBonus.text = "Стоимость"
            titleCost.text = "Бонус"
            
            bonuslbl.frame.origin.x = alertView.bounds.origin.x + alertView.bounds.size.width - costWidth - 34
            bonuslbl.frame.size.width = costWidth
            bonuslbl.text = cost
            
            costLbl.frame.origin.x = alertView.bounds.origin.x + alertView.bounds.size.width - bonusWidth - 34
            costLbl.frame.size.width = bonusWidth
            costLbl.text = "+\(bonus)"
            costLbl.textColor = UIColorFromRGB(rgbValue: 0xA3CD3A, alphaValue: 1)
        }else{
            let bonusWidth = ("-285 ₽").widthSize + CGFloat(15)
            let costWidth = ("20 мин.").widthSize + CGFloat(20)
            
            titleBonus.text = "Доплата"
            titleCost.text = "Время"
            
            bonuslbl.frame.origin.x = alertView.bounds.origin.x + alertView.bounds.size.width - bonusWidth - 34
            bonuslbl.frame.size.width = bonusWidth
            bonuslbl.text = "-285 ₽"
            bonuslbl.textColor = UIColorFromRGB(rgbValue: 0xE47171, alphaValue: 1)
            
            costLbl.frame.origin.x = alertView.bounds.origin.x + alertView.bounds.size.width - costWidth - 34
            costLbl.frame.size.width = costWidth
            costLbl.text = "20 мин."
        }
        
    }
    
    @objc func closeWindow(){
        self.removeFromSuperview()
    }
        
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        alertView.layer.cornerRadius = 13
    }
}
extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    fileprivate var bezierPathIdentifier:String { return "bezierPathBorderLayer" }

    fileprivate var bezierPathBorder:CAShapeLayer? {
        return (self.layer.sublayers?.filter({ (layer) -> Bool in
            return layer.name == self.bezierPathIdentifier && (layer as? CAShapeLayer) != nil
        }) as? [CAShapeLayer])?.first
    }

    func bezierPathBorder(_ color:UIColor = .white, width:CGFloat = 1) {

        var border = self.bezierPathBorder
        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius:self.layer.cornerRadius)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask

        if (border == nil) {
            border = CAShapeLayer()
            border!.name = self.bezierPathIdentifier
            self.layer.addSublayer(border!)
        }

        border!.frame = self.bounds
        let pathUsingCorrectInsetIfAny =
            UIBezierPath(roundedRect: border!.bounds, cornerRadius:self.layer.cornerRadius)

        border!.path = pathUsingCorrectInsetIfAny.cgPath
        border!.fillColor = UIColor.clear.cgColor
        border!.strokeColor = color.cgColor
        border!.lineWidth = width * 2
    }

    func removeBezierPathBorder() {
        self.layer.mask = nil
        self.bezierPathBorder?.removeFromSuperlayer()
    }
}
