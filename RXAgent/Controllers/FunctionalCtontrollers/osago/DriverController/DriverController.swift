//
//  DriverController.swift
//  RXAgent
//
//  Created by RX Group on 15/08/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

class DriverController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var tableDrivers: UITableView!
    var imagePicker = UIImagePickerController()
    var containerViewController: MainOsagoController?
    var emptyArray:NSMutableArray = []
    var isChecked = true
    @IBOutlet weak var tableConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.tableFooterView = UIView()
        self.tableDrivers.tableFooterView = UIView()
        self.tableDrivers.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        if(isEdit){
            tableConstraint.constant = 0
        }else{
            tableConstraint.constant = 141
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    
        if(!isChecked){
            isChecked = true
            
            let tempArr:NSArray = emptyArray.mutableCopy() as! NSArray
            for i in 0..<tempArr.count {
                let index = tempArr[i] as! Int
                if((imagesDriver[index] as! UIImage).size.width != 95){
                    emptyArray.remove(index)
                }
                
            }
            if(emptyArray.count<1){
                containerViewController?.emptylbl.isHidden = true
            }
        }
        tableDrivers.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == table){
            if indexPath.row == 0 {
                return 51
            } else {
                return 90
            }
        }else{
            return 109
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == table){
            if(isMultiDrive){
                return 1
            }else{
                return 2
            }
        }else{
            if(isMultiDrive){
                return 0
            }else{
                return countDriver * 2
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView==table){
            if indexPath.row == 0  {
                let cellReuseIdentifier = "multiCell"
                let cell:DriverCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! DriverCell
                    cell.switchMultidrive.setOn(isMultiDrive, animated: false)
                return cell
            }else{
                let cellReuseIdentifier = "driverCell"
                let cell:DriverCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! DriverCell
                
                return cell
            }
        }else{
            let cellReuseIdentifier = "driverPhoto"
            let cell:DriverCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! DriverCell
            cell.titleDriverLbl.text = (titleDriver[indexPath.row] as! String)
            cell.subtitleDriverLbl.text = (subtitleDriver[indexPath.row] as! String)
            cell.photoImageDriver.image = (imagesDriver[indexPath.row] as! UIImage)
            cell.photoButtonDriver.tag = indexPath.row
            cell.addBtnDriver.tag = indexPath.row
            
            cell.addBtnDriver.addTarget(self, action: #selector(self.chooseEditPhoto), for: .touchUpInside)
            cell.photoButtonDriver.addTarget(self, action: #selector(self.showPhoto), for: .touchUpInside)
            if((imagesDriver[indexPath.row] as! UIImage).size.width != 95){
                cell.addBtnDriver.setImage(UIImage(named: "edit photo"), for: .normal)
            }else{
                cell.addBtnDriver.setImage(UIImage(named: "addPhoto-1"), for: .normal)
            }
            if(emptyArray.contains(indexPath.row)){
                DispatchQueue.main.async{
                    cell.photoViewDriver.backgroundColor = UIColorFromRGB(rgbValue: 0xFFF6F6, alphaValue: 1)
                    cell.photoViewDriver.layer.borderColor = UIColorFromRGB(rgbValue: 0xE12222, alphaValue: 1).cgColor
                    cell.photoViewDriver.layer.borderWidth = 1
                    cell.titleDriverLbl.textColor = UIColorFromRGB(rgbValue: 0xE12222, alphaValue: 1)
                    cell.subtitleDriverLbl.textColor = UIColorFromRGB(rgbValue: 0xE12222, alphaValue: 1)
                }
            }else{
                DispatchQueue.main.async{
                    cell.photoViewDriver.backgroundColor = .clear
                    cell.photoViewDriver.layer.borderColor = UIColor.clear.cgColor
                    cell.photoViewDriver.layer.borderWidth = 0
                    cell.titleDriverLbl.textColor = .black
                    cell.subtitleDriverLbl.textColor = UIColorFromRGB(rgbValue: 0xADADAD, alphaValue: 1)
                }
            }
            
            return cell
        }
    }
    func drawEmptyPhotos()->Bool{
        isChecked = false
        emptyArray = checkDriverAccess().emptysIndex
        tableDrivers.reloadData()
        
        return driverImagesLoad()
    }
    @objc func chooseEditPhoto(sender: UIButton){
        currentIndex = sender.tag
        self.showCamera()
        
    }
    @objc func showPhoto(sender: UIButton){
        currentIndex = sender.tag
        if(sender.tag == 0 ){
            if(vu1Driver1.isEmpty || vu1Driver1 == "0"){
                self.showCamera()
            }else{
                self.showImage(image: imagesDriver[sender.tag] as! UIImage,view:  sender,name:vu1Driver1 )
            }
        }
        if(sender.tag == 1){
            if(vu2Driver1.isEmpty || vu2Driver1 == "0"){
                self.showCamera()
            }else{
                self.showImage(image: imagesDriver[sender.tag] as! UIImage,view:  sender,name:vu2Driver1)
            }
        }
        if(sender.tag == 2){
            if(vu1Driver2.isEmpty || vu1Driver2 == "0"){
                self.showCamera()
            }else{
                self.showImage(image: imagesDriver[sender.tag] as! UIImage,view:  sender,name:vu1Driver2)
            }
        }
        if(sender.tag == 3){
            if(vu2Driver2.isEmpty || vu2Driver2 == "0"){
                self.showCamera()
            }else{
                self.showImage(image: imagesDriver[sender.tag] as! UIImage,view:  sender,name:vu2Driver2)
            }
        }
        if(sender.tag == 4){
            if(vu1Driver3.isEmpty || vu1Driver3 == "0"){
                self.showCamera()
            }else{
                self.showImage(image: imagesDriver[sender.tag] as! UIImage,view:  sender,name:vu1Driver3)
            }
        }
        if(sender.tag == 5){
            if(vu2Driver3.isEmpty || vu2Driver3 == "0"){
                self.showCamera()
            }else{
                self.showImage(image: imagesDriver[sender.tag] as! UIImage,view:  sender,name:vu2Driver3)
            }
        }
        if(sender.tag == 6){
            if(vu1Driver4.isEmpty || vu1Driver4 == "0"){
                self.showCamera()
            }else{
                self.showImage(image: imagesDriver[sender.tag] as! UIImage,view:  sender,name:vu1Driver4)
            }
        }
        if(sender.tag == 7){
            if(vu2Driver4.isEmpty || vu2Driver4 == "0"){
                self.showCamera()
            }else{
                self.showImage(image: imagesDriver[sender.tag] as! UIImage,view:  sender,name:vu2Driver4)
            }
        }
    }
    
    func showImage(image: UIImage, view:UIView, name: String){
        if(isEdit){
            if(loadDriver[currentIndex] as! Bool){
                let appImage = ViewerImage.appImage(forImage: image)
                let viewer = AppImageViewer(originImage: image, photos: [appImage], animatedFromView: view)
                
                present(viewer, animated: true, completion: nil)
            }else{
                DispatchQueue.main.async {
                    imagesDriver.replaceObject(at: currentIndex, with: self.load(url: "\(domain)v0/Attachments/data/\(name)") ?? "")
                    
                    loadDriver[currentIndex] = true
                    let appImage = ViewerImage.appImage(forImage: imagesDriver[currentIndex] as! UIImage )
                    let viewer = AppImageViewer(originImage: imagesDriver[currentIndex] as! UIImage, photos: [appImage], animatedFromView: view)
                    
                    self.present(viewer, animated: true, completion: nil)
                }
            }
        }else{
            let appImage = ViewerImage.appImage(forImage: image)
            let viewer = AppImageViewer(originImage: image, photos: [appImage], animatedFromView: view)
            
            present(viewer, animated: true, completion: nil)
        }
        
    }
    func load(url: String) -> UIImage?{
        if(isReach){
            let data = try? Data(contentsOf: NSURL(string: url)! as URL)
            if(data != nil){
                var image = UIImage(data: data!)
                if(image==nil){
                    image = drawPDFfromURL(url: NSURL(string: url)! as URL)
                }
                return image!
            }else{
                return nil
            }
            
        }else{
            return nil
        }
        
        
    }
    func drawPDFfromURL(url: URL) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        guard let page = document.page(at: 1) else { return nil }
        
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            
            ctx.cgContext.drawPDFPage(page)
        }
        
        return img
    }
    //кнопка слева
    func chooseCamera(){
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(cmartCamera) {
           let defaults = UserDefaults.standard
           defaults.set(encoded, forKey: "smart")
        }
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "cameraVC") as! CameraController
           viewController.modalPresentationStyle = .fullScreen
          
           countItems = countDriver * 2
           firstLabels = titleDriver
           secondLabels = subtitleDriver
           self.isChecked = false
           self.present(viewController, animated: true, completion: nil)
    }
    
    func chooseGalery(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            cmartCamera.needCamera = false

            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(cmartCamera) {
               let defaults = UserDefaults.standard
               defaults.set(encoded, forKey: "smart")
            }
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .savedPhotosAlbum;
            self.imagePicker.allowsEditing = false
            self.isChecked = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func showCamera(){
        if(!cmartCamera.needSmart){
            let alertController = UIAlertController()
            let action = UIAlertAction(title: "Камера", style: .default) { (action: UIAlertAction!) in
                cmartCamera.needCamera = true
                if(cmartCamera.isChecked){
                    cmartCamera.needSmart = true
                }
                self.chooseCamera()
            }
            
            action.setValue(UIImage(named: "camera"), forKey: "image")
            
            let galery = UIAlertAction(title: "Галерея", style: .default) { (action: UIAlertAction!) in
                cmartCamera.needCamera = false
                if(cmartCamera.isChecked){
                    cmartCamera.needSmart = true
                }
                self.chooseGalery()
            }
            
            galery.setValue(UIImage(named: "galery"), forKey: "image")
            let cancel = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            
            alertController.addAction(action)
            alertController.addAction(galery)
            alertController.addAction(cancel)
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.view //to set the source of your alert
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // you can set this as per your requirement.
                popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
            }
            self.present(alertController, animated: true, completion: nil)
        }else{
            if(cmartCamera.needCamera){
                self.chooseCamera()
            }else{
                self.chooseGalery()
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        cmartCamera.needSmart = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if(isReach){
            var pickedImage:UIImage!
            if #available(iOS 11.0, *) {
                let data = try? Data(contentsOf: info[UIImagePickerController.InfoKey.imageURL] as! URL)
                pickedImage = UIImage(data: data!)
            }else{
                pickedImage=info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            }
                
                let dateFormatterPrint = DateFormatter()
                dateFormatterPrint.dateFormat = "dd-MMMM-yyyy-HH-mm-ss"
                
                let date = Date()
                RXServerConnector.sharedInstance.uploadImage(URLString:"\(domain)v0/Attachments", image: pickedImage, index: currentIndex,itemIndex: activeItem, name:  dateFormatterPrint.string(from: date) as NSString, completion:{  (result ,index,itemIndex) in
                    
                    let idPhoto = result["attachment"] as! [String: Any]
                    if(itemIndex==4){
                        if(index==0){
                            vu1Driver1 =  String(idPhoto["id"] as! Int)
                        }
                        if(index==1){
                            vu2Driver1 =  String(idPhoto["id"] as! Int)
                        }
                        if(index==2){
                            vu1Driver2 =  String(idPhoto["id"] as! Int)
                        }
                        if(index==3){
                            vu2Driver2 =  String(idPhoto["id"] as! Int)
                        }
                        if(index==4){
                            vu1Driver3 =  String(idPhoto["id"] as! Int)
                        }
                        if(index==5){
                            vu2Driver3 =  String(idPhoto["id"] as! Int)
                        }
                        if(index==6){
                            vu1Driver4 =  String(idPhoto["id"] as! Int)
                        }
                        if(index==7){
                            vu2Driver4 =  String(idPhoto["id"] as! Int)
                        }
                    }
                })
                imagesDriver.replaceObject(at: currentIndex, with: pickedImage as Any)
                if(!isChecked){
                    isChecked = true
                    
                    let tempArr:NSArray = emptyArray.mutableCopy() as! NSArray
                    for i in 0..<tempArr.count {
                        let index = tempArr[i] as! Int
                        if((imagesDriver[index] as! UIImage).size.width != 95){
                            emptyArray.remove(index)
                        }
                        
                    }
                    if(emptyArray.count<1){
                        containerViewController?.emptylbl.isHidden = true
                    }
                }
                tableDrivers.reloadData()
            
            
        }else{
            //                    setMessage("Отсутствует интернет соединение. Пожалуйста, проверьте доступ к сети и повторите загрузку документ")
        }
        
    }
    @IBAction func multiDriveChanged(_ sender: UISwitch) {
        isMultiDrive = sender.isOn
        table.reloadData()
        tableDrivers.reloadData()
    }
    
    @IBAction func segmentControllerChanged(_ sender: UISegmentedControl) {
        countDriver = sender.selectedSegmentIndex+1
        tableDrivers.reloadData()
    }
    
}
