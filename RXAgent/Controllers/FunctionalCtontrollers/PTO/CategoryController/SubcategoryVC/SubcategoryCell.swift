//
//  SubcategoryCell.swift
//  TO
//
//  Created by RX Group on 04.03.2021.
//

import UIKit

class SubcategoryCell: UITableViewCell {

    @IBOutlet weak var contentViewSubCategory: UIView!
    @IBOutlet weak var categoryYellowView: HeaderView!
    @IBOutlet weak var subcategoryLbl: UILabel!
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var categoryClass: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentViewSubCategory.backgroundColor = .white
        contentViewSubCategory.layer.cornerRadius = 12
        contentViewSubCategory.layer.borderWidth = 1
        contentViewSubCategory.layer.borderColor = UIColor.init(displayP3Red: 225/255, green: 225/255, blue: 225/255, alpha: 1).cgColor
        categoryYellowView.layer.cornerRadius = 5
        categoryYellowView.layer.masksToBounds = true
    }

}
