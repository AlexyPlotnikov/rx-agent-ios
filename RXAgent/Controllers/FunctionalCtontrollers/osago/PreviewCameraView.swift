//
//  PreviewCameraView.swift
//  RXAgent
//
//  Created by RX Group on 19/02/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit


@objc
public protocol PreviewDelegate: class {
    
    func previewDidClick(button: UIButton, index: Int)
    func switcherChoseState(sender: UISwitch, index: Int)
}

class PreviewCameraView: UIView {
    var label: UILabel!
    var switchPhoto: UISwitch!
    var enableView: UIView!
    var view: UIView!
    var imageView: UIImageView!
    @IBOutlet public weak var delegate: PreviewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
  
        self.backgroundColor = .clear
        
        label = UILabel(frame: CGRect(x: 6, y: 0, width: self.frame.size.width-4
            , height: 35))
        label.layer.cornerRadius=6
        label.layer.masksToBounds=true
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth=true
        label.textAlignment = .left
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 10.0)
        label.textColor = UIColor.white
        self.addSubview(label)
        
        view = UIView(frame: CGRect(x: 2, y: 37, width:self.frame.size.width-4 , height: self.frame.size.height-32))
        
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        self.addSubview(view)
        
        imageView = UIImageView(frame: CGRect(x: view.frame.origin.x+6, y: view.frame.origin.y+6, width: view.frame.size.width-12, height: view.frame.size.height-12))
        imageView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.16)
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds=true
        view.addSubview(imageView)
        
        let button = UIButton(frame: view.bounds)
        button.addTarget(self, action: #selector(self.clickAction), for: .touchUpInside)
        view.addSubview(button)
        
        enableView = UIView(frame: imageView.bounds)
        enableView.backgroundColor = .lightGray
        enableView.alpha = 0.4
        enableView.layer.cornerRadius = 10
        view.addSubview(enableView)
        
        switchPhoto = UISwitch(frame:CGRect(x: view.frame.size.width/2-25, y: view.frame.size.height*0.64, width: 51, height: 31))
        switchPhoto.layer.borderColor = UIColor.white.cgColor
        switchPhoto.layer.borderWidth = 1
        switchPhoto.layer.cornerRadius = 16.0;
        switchPhoto.onTintColor = UIColorFromRGB(rgbValue: 0x34323B, alphaValue: 1)
        switchPhoto.setOn(false, animated: false)
        switchPhoto.addTarget(self, action: #selector(self.switchValueDidChange), for: .valueChanged)
        view.addSubview(switchPhoto)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        imageView.frame = CGRect(x: view.bounds.origin.x+6, y: view.bounds.origin.y+6, width: view.bounds.size.width-12, height: view.bounds.size.height-12)
        enableView.frame = imageView.frame
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    @objc func clickAction(sender:UIButton){
        delegate?.previewDidClick(button: sender, index: self.tag)
    }
    
   @objc func switchValueDidChange(sender:UISwitch!){
    
    enableView.isHidden = sender.isOn
    delegate?.switcherChoseState(sender: sender, index: self.tag)
    }
    
    func imageForPreview(image: UIImage){
        imageView.image = image
    }
    
    func setSelected(){
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.white.cgColor
    }
    func setUnSelected(){
        view.layer.borderWidth = 0.0
        view.layer.borderColor = UIColor.clear.cgColor
    }
    func setAccessSwitch(access: Bool){
        switchPhoto.isOn = access
        enableView.isHidden = access
        
    }
    func setSwitchHiden(hide: Bool){
        switchPhoto.isHidden = hide
        enableView.isHidden = hide
    }
    
    func setTextLabel(text: String){
        label.text = text
        
    }
}
