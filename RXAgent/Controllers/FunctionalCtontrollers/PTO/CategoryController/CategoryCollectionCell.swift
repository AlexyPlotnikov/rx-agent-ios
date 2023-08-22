//
//  CategoryCollectionCell.swift
//  TO
//
//  Created by RX Group on 18.02.2021.
//

import UIKit

class CategoryCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    var shadowLayer: CAShapeLayer!
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = 10
       
    }
    
    
}
