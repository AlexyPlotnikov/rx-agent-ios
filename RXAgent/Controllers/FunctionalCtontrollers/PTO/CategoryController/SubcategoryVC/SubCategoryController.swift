//
//  SubCategoryController.swift
//  TO
//
//  Created by RX Group on 04.03.2021.
//

import UIKit

class SubCategoryController: UIViewController {
    
    @IBOutlet weak var categorylbl: UILabel!
    @IBOutlet weak var table: UITableView!
    var currentCategoryID = 0
    private var subcategory:[CategoryStruct]{
        return Category.sharedInstance().getSubcategoryByID(id: currentCategoryID)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.categorylbl.text = "Категория \(self.subcategory[0].vehicleCategoryTitle)" 
    }
    

    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}


extension SubCategoryController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.subcategory.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.subcategory[indexPath.row].description.height(withConstrainedWidth: self.table.frame.size.width-32, font: UIFont.systemFont(ofSize: 15)) + 90
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SubcategoryCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SubcategoryCell
        let subCategory = self.subcategory[indexPath.row]
        print(subCategory)
        cell.carImage.image = UIImage(named: "category\(subCategory.id)")
        cell.categoryClass.text = subCategory.vehicleType
        cell.subcategoryLbl.text = subCategory.title
        cell.descriptionLbl.text = subCategory.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Category.sharedInstance().currentCategoryID = self.subcategory[indexPath.row].id
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: .nextStep, object: nil, userInfo: nil)
       
    }
    
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}
