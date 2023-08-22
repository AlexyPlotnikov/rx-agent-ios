//
//  MainTabBarController.swift
//  RXAgent
//
//  Created by RX Group on 06.07.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUPTabBar()
    }
    
    func setUPTabBar() {
        self.tabBar.barTintColor = .white
        self.tabBar.isTranslucent = true
        self.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate
        self.tabBar.tintColor = UIColorFromRGB(rgbValue: 0x362240, alphaValue: 1)
        if let imageOsago = UIImage(named: "osago_select")?.withRenderingMode(.alwaysOriginal){
            self.tabBar.items![0].selectedImage = imageOsago
        }
        if let imageTo = UIImage(named: "miteSelected")?.withRenderingMode(.alwaysOriginal){
            self.tabBar.items![2].selectedImage = imageTo
        }
        
        if let newButtonImage = UIImage(named: "add_round_button") {
            self.addCenterButton(withImage: newButtonImage, highlightImage: newButtonImage)
        }
    }
    

    func addCenterButton(withImage buttonImage : UIImage, highlightImage: UIImage) {

            let paddingBottom : CGFloat = 10.0

            let button = UIButton(type: .custom)
            button.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin]
            button.frame = CGRect(x: 0.0, y: -26, width: buttonImage.size.width , height: buttonImage.size.height )
            button.setBackgroundImage(buttonImage, for: .normal)
            button.setBackgroundImage(highlightImage, for: .highlighted)

            let rectBoundTabbar = self.tabBar.bounds
            let xx = rectBoundTabbar.midX
            let yy = rectBoundTabbar.midY - paddingBottom
            button.center = CGPoint(x: xx, y: yy)

            self.tabBar.addSubview(button)
            self.tabBar.bringSubviewToFront(button)

            button.addTarget(self, action: #selector(handleTouchTabbarCenter), for: .touchUpInside)

            if let count = self.tabBar.items?.count
            {
                let i = floor(Double(count / 2))
                let item = self.tabBar.items![Int(i)]
                item.title = ""
            }
        }
    
    @objc func handleTouchTabbarCenter(sender : UIButton) {
       
            _ = self.delegate?.tabBarController?(self, shouldSelect: (self.viewControllers?[1])!)
        
     }


}


