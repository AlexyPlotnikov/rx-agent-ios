//
//  StepperView.swift
//  RXAgent
//
//  Created by RX Group on 27/02/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

@objc
public protocol StepperViewDelegate: class {
    func stepClicked(index: Int)
    
}

class StepperView: UIView {
   
    @IBOutlet public weak var delegate: StepperViewDelegate?
    var count = 5{
        didSet{
            setNeedsDisplay()
        }
    }
    var maxIndex = 1
    var isMinused = false
    var isMaxed = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.setNeedsDisplay()
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        for view in self.subviews{
            view.removeFromSuperview()
        }
        self.buildStepper(countItems: count)
    }
    
    func buildStepper(countItems:Int){
        
        let newWidth = self.frame.size.height
        let newSize = self.frame.size.width/CGFloat(countItems)
        let x = 0
        var newActiveItem = activeItem
        if(isOwner && newActiveItem>=3){
            if(!isEdit){
               if !isMaxed{
                maxIndex -= 1
                isMaxed=true
                }
            }
            newActiveItem -= 1
        }
       
        for i in 1...countItems{
            var tempI = i
            if(isOwner && tempI>=2){
                tempI+=1
            }
            var view = UIView()
            view = UIView(frame: CGRect(x: (CGFloat(x) + newSize * CGFloat(i-1)) + (newSize-newWidth)/2, y: 0, width: newWidth, height: newWidth))
            view.layer.cornerRadius = 10
            view.layer.masksToBounds = true
            if(i==newActiveItem){
                //текущий этап
               view.backgroundColor = UIColorFromRGB(rgbValue: 0xA3CD3A, alphaValue: 1)
               
            }else{
                if(i<newActiveItem){
                    //пройден этап
                   colorForView(view: view, index: tempI)
                }else if(i<=maxIndex){
                            colorForView(view: view, index: tempI)
                        }else{
                            view.backgroundColor = UIColorFromRGB(rgbValue: 0x34323B, alphaValue: 0.1)
                        }
            }
            
            self.addSubview(view)
            if(i != countItems){
                var minusWidth:CGFloat!
                    minusWidth = (((CGFloat(x) + newSize * CGFloat(i)) + (newSize-newWidth)/2) - 3) - ((CGFloat(x) + newSize * CGFloat(i-1)) + (newSize-newWidth)/2 + newWidth) - 3
               
                let viewLine = UIView(frame: CGRect(x: (CGFloat(x) + newSize * CGFloat(i-1)) + (newSize-newWidth)/2 + newWidth + 3, y: newWidth/2, width: minusWidth, height: 2))
                viewLine.backgroundColor = UIColorFromRGB(rgbValue: 0x34323B, alphaValue: 0.1)
                self.addSubview(viewLine)
            }
            
            let label = UILabel(frame: view.bounds)
            label.textAlignment = .center
            label.numberOfLines = 1
            label.text = "\(i)"
            label.font = UIFont(name: "Roboto-Bold", size: 14)
            view.addSubview(label)
            if(i==newActiveItem){
                //текущий этап
                label.textColor = .white
                self.createBtn(view: view ,index: i)
            } else{
                if(i<newActiveItem){
                    //пройден этап
                    self.colorForLabel(label: label, index: tempI)
                    self.createBtn(view: view ,index: i)
                }else if(i<=maxIndex){
                        self.createBtn(view: view ,index: i)
                        self.colorForLabel(label: label, index: tempI)
                    }else{
                        label.textColor = UIColorFromRGB(rgbValue: 0xABABB2, alphaValue: 1)
                    }
                }
            }
       
    }
    func colorForLabel(label:UILabel, index:Int)  {
        if(index==1){
            if(checkInsuranceAccess().isEmptIns){
                //зеленый
                label.textColor = UIColorFromRGB(rgbValue: 0xA3CD3A, alphaValue: 1)
            }else{
                //красный
                label.textColor = UIColorFromRGB(rgbValue: 0xED9494, alphaValue: 1)
            }
        }
        if(index==2){
            if(checkOwnerAccess().isEmptIns){
                //зеленый
                label.textColor = UIColorFromRGB(rgbValue: 0xA3CD3A, alphaValue: 1)
            }else{
                //красный
                label.textColor = UIColorFromRGB(rgbValue: 0xED9494, alphaValue: 1)
            }
        }
        if(index==3){
            if(checkVehicleAccess().isEmptIns){
                //зеленый
                label.textColor = UIColorFromRGB(rgbValue: 0xA3CD3A, alphaValue: 1)
            }else{
                //красный
                label.textColor = UIColorFromRGB(rgbValue: 0xED9494, alphaValue: 1)
            }
        }
        if(index==4){
            if(checkDriverAccess().isEmptIns){
                //зеленый
                label.textColor = UIColorFromRGB(rgbValue: 0xA3CD3A, alphaValue: 1)
            }else{
                //красный
                label.textColor = UIColorFromRGB(rgbValue: 0xED9494, alphaValue: 1)
            }
        }
        if(index==5){
            if(cardValidate()){
                //зеленый
                label.textColor = UIColorFromRGB(rgbValue: 0xA3CD3A, alphaValue: 1)
            }else{
                //красный
                label.textColor = UIColorFromRGB(rgbValue: 0xED9494, alphaValue: 1)
            }
        }
        if(index==6){
            if(checkPropertyAccess().isEmptIns){
                //зеленый
                label.textColor = UIColorFromRGB(rgbValue: 0xA3CD3A, alphaValue: 1)
            }else{
                //красный
               label.textColor = UIColorFromRGB(rgbValue: 0xED9494, alphaValue: 1)
            }
        }
    }
    func colorForView(view:UIView, index:Int){
        if(index==1){
            if(checkInsuranceAccess().isEmptIns){
                //зеленый
                view.backgroundColor = UIColorFromRGB(rgbValue: 0xA3CD3A, alphaValue: 0.2)
            }else{
                //красный
                view.backgroundColor = UIColorFromRGB(rgbValue: 0xFFE6E6, alphaValue: 1)
            }
        }
        if(index==2){
            if(checkOwnerAccess().isEmptIns){
                //зеленый
                view.backgroundColor = UIColorFromRGB(rgbValue: 0xA3CD3A, alphaValue: 0.2)
            }else{
                //красный
                view.backgroundColor = UIColorFromRGB(rgbValue: 0xFFE6E6, alphaValue: 1)
            }
        }
        if(index==3){
            if(checkVehicleAccess().isEmptIns){
                //зеленый
                view.backgroundColor = UIColorFromRGB(rgbValue: 0xA3CD3A, alphaValue: 0.2)
            }else{
                //красный
                view.backgroundColor = UIColorFromRGB(rgbValue: 0xFFE6E6, alphaValue: 1)
            }
        }
        if(index==4){
            if(checkDriverAccess().isEmptIns){
                //зеленый
                view.backgroundColor = UIColorFromRGB(rgbValue: 0xA3CD3A, alphaValue: 0.2)
            }else{
                //красный
                view.backgroundColor = UIColorFromRGB(rgbValue: 0xFFE6E6, alphaValue: 1)
            }
        }
        if(index==5){
            if(cardValidate()){
                //зеленый
                view.backgroundColor = UIColorFromRGB(rgbValue: 0xA3CD3A, alphaValue: 0.2)
            }else{
                //красный
                view.backgroundColor = UIColorFromRGB(rgbValue: 0xFFE6E6, alphaValue: 1)
            }
        }
        if(index==6){
            if(checkPropertyAccess().isEmptIns){
                //зеленый
                view.backgroundColor = UIColorFromRGB(rgbValue: 0xA3CD3A, alphaValue: 0.2)
            }else{
                //красный
                view.backgroundColor = UIColorFromRGB(rgbValue: 0xFFE6E6, alphaValue: 1)
            }
        }
    }
    func createBtn(view: UIView, index:Int){
        let button = UIButton(frame: view.bounds)
        button.tag=index
        button.addTarget(self, action: #selector(self.clickAction), for: .touchUpInside)
        view.addSubview(button)
    }
    
    func nextItem(){
        if(isOwner){
            if(activeItem == 1){
                activeItem += 2
            }else{
                activeItem += 1
            }
        }else{
            activeItem += 1
        }
        if(activeItem>maxIndex){
            maxIndex = activeItem
            isMaxed=false
        }
        
        self.setNeedsDisplay()
    }
    
    @objc func clickAction(_ sender:UIButton){
         activeItem = sender.tag
        if(isOwner){
            if(activeItem >= 2){
                activeItem += 1
            }
        }
         self.setNeedsDisplay()
        delegate?.stepClicked(index: sender.tag)
    }
}
