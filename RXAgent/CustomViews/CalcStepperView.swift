//
//  CalcStepperView.swift
//  RXAgent
//
//  Created by RX Group on 26.05.2020.
//  Copyright © 2020 RX Group. All rights reserved.
//

import UIKit

@objc public protocol CalcStepperViewDelegate: class {
    func stepClicked(index: Int)
}

class CalcStepperView: UIView {
    
    public weak var delegate: CalcStepperViewDelegate?
    
    var activeItem:Int = 1{
        didSet{
            setNeedsDisplay()
        }
    }
    var countItems:Int = 3{
        didSet{
            setNeedsDisplay()
        }
    }

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
        self.buildStepper(countItems: countItems)
    }
    
    func buildStepper(countItems:Int){
    
        let newWidth = self.frame.size.height
        let newSize = self.frame.size.width/CGFloat(countItems)
        let x = 0
        //отрисовка квадратов
        for i in 1...countItems{
            let view = UIView(frame: CGRect(x: (CGFloat(x) + newSize * CGFloat(i-1)) + (newSize-newWidth)/2, y: 0, width: newWidth, height: newWidth))
            view.layer.cornerRadius = 10
            view.layer.masksToBounds = true
            
            
            if(i==activeItem){
                //текущий этап
                view.backgroundColor = UIColor.init(displayP3Red: 163/255, green: 205/255, blue: 58/255, alpha: 1)
            }else{
                if(i<activeItem){
                    //прошедший этап
                    view.backgroundColor = UIColor.init(displayP3Red: 163/255, green: 205/255, blue: 58/255, alpha: 0.1)
                }else{
                    //не тронутый этап
                    view.backgroundColor = UIColor.init(displayP3Red: 163/255, green: 205/255, blue: 58/255, alpha: 0.1)
                }
            }
            self.addSubview(view)
            let button = UIButton(frame: view.bounds)
            button.addTarget(self, action: #selector(tapButton(button:)), for: .touchUpInside)
            button.setTitle("", for: .normal)
            button.tag = i
            view.addSubview(button)
            //отрисовка лейбла
            let label = UILabel(frame: view.bounds)
            label.textAlignment = .center
            label.numberOfLines = 1
            label.text = "\(i)"
            label.font = UIFont(name: "Roboto-Bold", size: 16)
            if(i==activeItem){
                //текущий этап
                label.textColor = .white
            }else{
                if(i<activeItem){
                    //прошедший этап
                    label.textColor = UIColor.init(displayP3Red: 163/255, green: 205/255, blue: 58/255, alpha: 1)
                }else{
                    //нетронутый этап
                    label.textColor = UIColor.init(displayP3Red: 163/255, green: 205/255, blue: 58/255, alpha: 1)
                }
            }
            view.addSubview(label)
            
            
            //отрисовка линий между квадратами
            if(i != countItems){
                var minusWidth:CGFloat!
                    minusWidth = (((CGFloat(x) + newSize * CGFloat(i)) + (newSize-newWidth)/2) - 3) - ((CGFloat(x) + newSize * CGFloat(i-1)) + (newSize-newWidth)/2 + newWidth) - 3
               
                let viewLine = UIView(frame: CGRect(x: (CGFloat(x) + newSize * CGFloat(i-1)) + (newSize-newWidth)/2 + newWidth + 3, y: newWidth/2, width: minusWidth, height: 2))
                viewLine.backgroundColor = UIColorFromRGB(rgbValue: 0x34323B, alphaValue: 0.1)
                self.addSubview(viewLine)
            }
        }
    }
    
    @objc func tapButton(button:UIButton){
        if(button.tag <= activeItem){
            self.delegate?.stepClicked(index: button.tag)
        }
    }
    
    func nextStep(){
        activeItem += 1
    }
}
