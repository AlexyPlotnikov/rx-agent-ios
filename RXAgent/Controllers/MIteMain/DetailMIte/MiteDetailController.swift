//
//  MiteDetailController.swift
//  RXAgent
//
//  Created by RX Group on 30.03.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit
import PDFKit
import SPIndicator


class MiteDetailController: UIViewController,UIGestureRecognizerDelegate {

    @IBOutlet weak var actionButton: UIButton!
    var police:MiteDetailModel!
    var filePDF: PDFDocument!
    var isBottom: Bool {
        if #available(iOS 11.0, *), let keyWindow = UIApplication.shared.keyWindow, keyWindow.safeAreaInsets.bottom > 0 {
            return true
        }
        return false
    }
    
    @IBOutlet weak var headerHeightConst: NSLayoutConstraint!
    @IBOutlet weak var loadPDFView: UIView!
    
    @IBOutlet weak var gearIcon: UIImageView!
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: isBottom ? 80:90, right: 0)
        self.cofigureActionButton()
        headerHeightConst.constant = isBottom ? 89:72
        NotificationCenter.default.addObserver(self, selector: #selector(self.showLoadView(notification: )), name: NSNotification.Name(rawValue: "showLoadView"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @IBAction func back(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }

    func dateFromJSON(_ JSONdate: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd"
        dateFormatterPrint.dateStyle = DateFormatter.Style.short
        dateFormatterPrint.locale = NSLocale(localeIdentifier: "ru") as Locale

        let date = dateFormatterGet.date(from: JSONdate)

        return dateFormatterPrint.string(from: date!)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
       
        return (navigationController?.viewControllers.count ?? 0) > 1
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func cofigureActionButton(){
        actionButton.layer.cornerRadius = 10
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.setTitle(self.police.paid ? "Посмотреть":"Оплатить", for: .normal)
        actionButton.backgroundColor = self.police.paid ? UIColor.init(displayP3Red: 52/255, green: 50/255, blue: 59/255, alpha: 1):UIColor.init(displayP3Red: 163/255, green: 205/255, blue: 58/255, alpha: 1)
    }
    
    @IBAction func buttonActionSelector(_ sender: Any) {
        if(self.police.paid){
            if(self.police.items.count > 1){
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "policeNC") as! MitePoliceNavigationController
                let presentationController = SheetModalPresentationController(presentedViewController: viewController,
                                                                                      presenting: self,
                                                                                      isDismissable: true)
                
                viewController.transitioningDelegate = presentationController
                viewController.modalPresentationStyle = .custom
                let rootViewController = viewController.viewControllers.first as! MitePoliciesController
                rootViewController.items = self.police.items
                self.present(viewController, animated: true)
            }else{
                self.showLoadView(notification: NSNotification(name: NSNotification.Name(rawValue: ""), object: nil))
            }
        }else{
            postReq(URLString: domain + "v0/MitePolicies/\(self.police.id)/debit", completion: {
                result in
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("close"), object: nil)
                    self.navigationController?.popViewController(animated: true)
                    SPIndicator.present(title: "Оплата прошла успешно", haptic: .error, completion: {
                        
                    })
                }
            })
        }
    }
    
    @objc func showLoadView(notification: NSNotification){
        var newUrl = domain + "v0/reports/mitePolicy/\(self.police.id)"
        if(notification.userInfo?["id"] != nil){
            newUrl = newUrl + "/\(notification.userInfo?["id"] as! Int)"
        }
         loadPDFView.isHidden = false
         gearIcon.rotate()
         getRequest(URLString: newUrl, completion: {
             result in
             if(result["url"] as? String ?? "") != "" {
                 DispatchQueue.main.async {
                     let pdfView = PDFView(frame: self.view.bounds)
                     let button = UIButton(frame: CGRect(x: 16, y: 61, width: 24, height: 24))
                     button.setImage(UIImage(named: "close"), for: .normal)
                     button.addTarget(self, action: #selector(self.closePDF), for: .touchUpInside)
                     pdfView.addSubview(button)

                     let buttonShare = UIButton(frame: CGRect(x: self.view.frame.size.width-60, y: 61, width: 40, height: 24))
                     buttonShare.setImage(UIImage(named: "shareBlack"), for: .normal)
                     buttonShare.addTarget(self, action: #selector(self.sharePDF), for: .touchUpInside)
                     pdfView.addSubview(buttonShare)

                     self.view.addSubview(pdfView)

                     pdfView.autoScales = true
                     self.loadPDFView.isHidden = true

                     let fileURL = URL(string: (result["url"] as! String))
                     pdfView.document = PDFDocument(url: fileURL!)
                     self.filePDF = pdfView.document
                 }
             }else{
                 DispatchQueue.main.async {
                     SPIndicator.present(title: "Полис недоступен для скачивания", haptic: .error, completion: {
                         
                     })
                     self.loadPDFView.isHidden = true
                 }
                 
             }
         })
    }
    
    @objc func sharePDF() {
        if let pdfData = filePDF.dataRepresentation() {
            let objectsToShare = [pdfData]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
//            activityVC.popoverPresentationController?.sourceView = self.button

            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
   @objc func closePDF(){
       for view in self.view.subviews{
           if(view is PDFView){
               view.removeFromSuperview()
           }
       }
    }
    
   
    
    func counLocalization(count:Int) -> String{
        if(count == 12 || count == 13 || count == 14){
            return "\(count) человек"
        }else{
            let tempCount = count%10
            if(tempCount>=2 && tempCount<=4){
                return "\(count) человека"
            }else{
                return "\(count) человек"
            }
        }
       
    }
}

extension MiteDetailController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0){
           return 88
        }else if(indexPath.row == 1){
            return 324
        }else if(indexPath.row == 2){
            return 94
        }else{
            return 88
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cellReuseIdentifier = "cellCost"
            let cell:MiteDetailCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MiteDetailCell
            cell.costLbl.text = String(format: "%.0f", self.police.costClient) + " ₽"
            cell.bonusLbl.text = String(format: "+ КВ %.0f", self.police.costClient/100*self.police.bonus) + " ₽"
            
            return cell
        }else if(indexPath.row == 1){
            let cellReuseIdentifier = "cellStatus"
            let cell:MiteDetailCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MiteDetailCell
            cell.statusField.text = self.police.paid ? "Оплачено":"Ожидает оплаты"
            cell.statusField.textColor = self.police.paid ? UIColor.init(displayP3Red: 128/255, green: 161/255, blue: 43/255, alpha: 1):UIColor.init(displayP3Red: 243/255, green: 162/255, blue: 60/255, alpha: 1)
            cell.dateInsField.text = self.dateFromJSON(self.police.dateFrom) + " - " + self.dateFromJSON(self.police
                .dateTo)
            
            return cell
        }else if(indexPath.row == 2){
            let cellReuseIdentifier = "cellInsurant"
            let cell:MiteDetailCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MiteDetailCell
            cell.insuranceField.text = self.police.fullName + " (\(self.dateFromJSON(self.police.dob)))"
            
            return cell
        }else{
            
            let cellReuseIdentifier = "cellInsurantPeople"
            let cell:MiteDetailCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MiteDetailCell
            
            cell.insPeopleField.text = self.counLocalization(count:self.police.items.count)
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
     
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "peopleVC") as! InsurancePeopleController
            viewController.peoples = self.police.items
            viewController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(viewController, animated: true)
        
       
    }
    
}


extension UIView {
    private static let kRotationAnimationKey = "rotationanimationkey"

    func rotate(duration: Double = 1) {
        if layer.animation(forKey: UIView.kRotationAnimationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")

            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float.pi * 2.0
            rotationAnimation.duration = duration
            rotationAnimation.repeatCount = Float.infinity

            layer.add(rotationAnimation, forKey: UIView.kRotationAnimationKey)
        }
    }

    func stopRotating() {
        if layer.animation(forKey: UIView.kRotationAnimationKey) != nil {
            layer.removeAnimation(forKey: UIView.kRotationAnimationKey)
        }
    }
}

