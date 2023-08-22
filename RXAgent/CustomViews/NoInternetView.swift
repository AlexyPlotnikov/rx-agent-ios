//
//  NoInternetView.swift
//  RXAgent
//
//  Created by RX Group on 11.08.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import UIKit

class NoInternetView: UIView {
    var image:UIImageView!

        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = .white
            image = UIImageView(frame: CGRect(x: self.frame.size.width/2-238/2, y: self.frame.size.height/2-238/2, width: 238, height: 238))
            image.contentMode = .scaleAspectFit
            image.image = UIImage(named: "noInternet")
            self.addSubview(image)
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            
        }
        
    func setImage(isTechnicalError:Bool){
        image.image = isTechnicalError ? UIImage(named: "technicalError"):UIImage(named: "noInternet")
    }


}

