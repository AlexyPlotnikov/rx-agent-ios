//
//  CategoryController.swift
//  RXAgent
//
//  Created by RX Group on 22.06.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import UIKit


class CategoryController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var uniqueCategory:[CategoryStruct]{
        return Category.sharedInstance().getUniqueCategoryTitle
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        Category.sharedInstance().loadCategories { (ready, categories) in
            if(ready){
                self.collectionView.reloadData()
            }
        }
        
    }
    

    
}

extension CategoryController:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return uniqueCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:CategoryCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "category", for: indexPath) as! CategoryCollectionCell
        let category = uniqueCategory[indexPath.row]
            cell.categoryImage.image = UIImage(named:"mainCategory"+"\(indexPath.row+1)")
            cell.categoryName.text = "Категория \(category.vehicleCategoryTitle)"
    
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width : CGFloat = self.collectionView.frame.size.width/2 - 16
        let height : CGFloat = 96
      
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SubCategoryNavVC") as! SubCategoryNavigationController
        let presentationController = SheetModalPresentationController(presentedViewController: viewController,
                                                                              presenting: self,
                                                                              isDismissable: true)

        viewController.transitioningDelegate = presentationController
        viewController.modalPresentationStyle = .custom
        let rootViewController = viewController.viewControllers.first as! SubCategoryController
        rootViewController.currentCategoryID = indexPath.row+1
    
        self.present(viewController, animated: true)
    }
}



