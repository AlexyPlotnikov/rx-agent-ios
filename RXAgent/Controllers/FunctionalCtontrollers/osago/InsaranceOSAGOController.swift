//
//  InsaranceController.swift
//  RXAgent
//
//  Created by RX Group on 05/08/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

class InsaranceOSAGOController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var table1: UITableView!
    @IBOutlet weak var table2: UITableView!
    
    var titlesArray = ["Является собственником","ДКП","Временная регистрация"]
    var titles1:NSMutableArray = ["Паспорт","Паспорт","ДКП","Временная регистрация"]
    var titles2:NSMutableArray = ["1-я страница","Регистрация","",""]
    
    var imagePicker = UIImagePickerController()
    var emptyArray:NSMutableArray = []
    
    var containerViewController: MainOsagoController?
    var isChecked = true
    
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    
         self.table1.tableFooterView = UIView()
         self.table2.tableFooterView = UIView()
         self.table2.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        tableHeight.constant = CGFloat(51) * CGFloat(countOptions)
       
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(!isChecked){
            isChecked = true
           
            let tempArr:NSArray = emptyArray.mutableCopy() as! NSArray
            for i in 0..<tempArr.count {
                let index = tempArr[i] as! Int
                if((imagesInsurance[index] as! UIImage).size.width != 95){
                   emptyArray.remove(index)
                }
               
            }
            if(emptyArray.count<1){
                containerViewController?.emptylbl.isHidden = true
            }
        }
        table1.reloadData()
        table2.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == table1){
            return countOptions
        }
        if(tableView == table2){
            return countRows
        }
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
        let cellReuseIdentifier = "cell"
        let cell:optionCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! optionCell
        if(tableView == table1){
            var tempIndexPath = indexPath.row
            if(isEdit){
                tempIndexPath+=1
            }
                cell.titleLbl.text = titlesArray[tempIndexPath]
                cell.switchOption.tag = tempIndexPath
                cell.switchOption.addTarget(self, action: #selector(self.switchValueDidChange), for: .valueChanged)
                if(tempIndexPath==0){
                    cell.switchOption.setOn(isOwner, animated: false)
                }
                if(tempIndexPath==1){
                    cell.switchOption.setOn(hasDKPInsurance, animated: false)
                }
                if(tempIndexPath==2){
                    cell.switchOption.setOn(hasRegInsurance, animated: false)
                }
           
        }
        
        if(tableView == table2){
                var constaintIndex = indexPath.row
                if(!hasDKPInsurance && hasRegInsurance && indexPath.row==2){
                    constaintIndex += 1
                }
                if(emptyArray.contains(constaintIndex)){
                    DispatchQueue.main.async{
                        cell.photoView.backgroundColor = UIColorFromRGB(rgbValue: 0xFFF6F6, alphaValue: 1)
                        cell.photoView.layer.borderColor = UIColorFromRGB(rgbValue: 0xE12222, alphaValue: 1).cgColor
                        cell.photoView.layer.borderWidth = 1
                        cell.labelTop.textColor = UIColorFromRGB(rgbValue: 0xE12222, alphaValue: 1)
                        cell.labelBottom.textColor = UIColorFromRGB(rgbValue: 0xE12222, alphaValue: 1)
                    }
                }else{
                    DispatchQueue.main.async{
                        cell.photoView.backgroundColor = .clear
                        cell.photoView.layer.borderColor = UIColor.clear.cgColor
                        cell.photoView.layer.borderWidth = 0
                        cell.labelTop.textColor = .black
                        cell.labelBottom.textColor = UIColorFromRGB(rgbValue: 0xADADAD, alphaValue: 1)
                    }
                }
            if((imagesInsurance[indexPath.row] as! UIImage).size.width != 95){
                cell.addPhotoBtn.setImage(UIImage(named: "edit photo"), for: .normal)
            }else{
                cell.addPhotoBtn.setImage(UIImage(named: "addPhoto-1"), for: .normal)
            }
          
            if(indexPath.row==0 || indexPath.row==1){
                cell.labelTop.text = (titles1[indexPath.row] as! String)
                cell.labelBottom.text = (titles2[indexPath.row] as! String)
                cell.photoImage.image = imagesInsurance[indexPath.row] as? UIImage
                cell.addPhotoBtn.tag = indexPath.row
                cell.photoBtn.tag = indexPath.row
                
            }
            if(indexPath.row==2 && !hasDKPInsurance){
                cell.labelTop.text = (titles1[3] as! String)
                cell.labelBottom.text = (titles2[3] as! String)
                cell.photoImage.image = imagesInsurance[3] as? UIImage
                cell.addPhotoBtn.tag = 3
                cell.photoBtn.tag = 3
            }else
                if(indexPath.row == 3 && hasRegInsurance){
                cell.labelTop.text = (titles1[3] as! String)
                cell.labelBottom.text = (titles2[3] as! String)
                cell.photoImage.image = imagesInsurance[3] as? UIImage
                cell.addPhotoBtn.tag = 3
                cell.photoBtn.tag = 3
            } else
                if(indexPath.row==2 && hasDKPInsurance){
                cell.labelTop.text = (titles1[2] as! String)
                cell.labelBottom.text = (titles2[2] as! String)
                cell.photoImage.image =  imagesInsurance[2] as? UIImage
                cell.addPhotoBtn.tag = 2
                cell.photoBtn.tag = 2
            }else
                if(indexPath.row == 2 && hasRegInsurance){
                cell.labelTop.text = (titles1[3] as! String)
                cell.labelBottom.text = (titles2[3] as! String)
                cell.photoImage.image = imagesInsurance[3] as? UIImage
                cell.addPhotoBtn.tag = 3
                cell.photoBtn.tag = 3
            }
            cell.addPhotoBtn.addTarget(self, action: #selector(self.chooseEditPhoto), for: .touchUpInside)
            cell.photoBtn.addTarget(self, action: #selector(self.showPhoto), for: .touchUpInside)
        }
        
        return cell
    }
    
    func drawEmptyPhotos()->Bool{
        isChecked = false
        emptyArray = checkInsuranceAccess().emptysIndex
        table2.reloadData()
    
        return insuranceImagesLoad()
    }
    //кнопка справа
    @objc func chooseEditPhoto(sender: UIButton){
        currentIndex = sender.tag
        self.showCamera()
      
    }
    
    @objc func showPhoto(sender: UIButton){
        currentIndex = sender.tag
        if(sender.tag == 0 ){
            if(passport1Ins.isEmpty || passport1Ins=="0"){
                self.showCamera()
            }else{
                self.showImage(image: imagesInsurance[sender.tag] as! UIImage,view:  sender,name: passport1Ins)
            }
        }
        if(sender.tag == 1){
            if(passport2Ins.isEmpty || passport2Ins == "0"){
                self.showCamera()
            }else{
                self.showImage(image: imagesInsurance[sender.tag] as! UIImage,view:  sender,name: passport2Ins)
            }
        }
        if(sender.tag == 2){
            if(DKPIns.isEmpty || DKPIns == "0"){
                self.showCamera()
            }else{
                self.showImage(image: imagesInsurance[sender.tag] as! UIImage,view:  sender, name:DKPIns )
            }
        }
        if(sender.tag == 3){
            if(regIns.isEmpty || regIns == "0"){
                self.showCamera()
            }else{
                self.showImage(image: imagesInsurance[sender.tag] as! UIImage,view:  sender,name: regIns)
            }
        }
    }
    
    func showImage(image: UIImage, view:UIView, name: String){
        if(isEdit){
            if(loadInsurance[currentIndex] as! Bool){
                let appImage = ViewerImage.appImage(forImage: image)
                let viewer = AppImageViewer(originImage: image, photos: [appImage], animatedFromView: view)
                
                present(viewer, animated: true, completion: nil)
            }else{
                DispatchQueue.main.async {
                imagesInsurance.replaceObject(at: currentIndex, with: self.load(url: "\(domain)v0/Attachments/data/\(name)") ?? "")
                loadInsurance[currentIndex] = true
                let appImage = ViewerImage.appImage(forImage: imagesInsurance[currentIndex] as! UIImage)
                let viewer = AppImageViewer(originImage: imagesInsurance[currentIndex] as! UIImage, photos: [appImage], animatedFromView: view)
            
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
                    if(isOwner){
                        countItems = 4
                    }else{
                        countItems = 2
                    }
                    
                    firstLabels = self.titles1
                    secondLabels = self.titles2
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
                    RXServerConnector.sharedInstance.uploadImage(URLString:"\(domain)v0/Attachments", image: pickedImage!, index: currentIndex,itemIndex: activeItem, name:  dateFormatterPrint.string(from: date) as NSString, completion:{  (result ,index,itemIndex) in
        
                        let idPhoto = result["attachment"] as! [String: Any]
                        if(itemIndex==1){
                            if(index==0){
                               passport1Ins =  String(idPhoto["id"] as! Int)
                            }
                            if(index==1){
                                passport2Ins =  String(idPhoto["id"] as! Int)
                            }
                            if(index==2){
                                DKPIns =  String(idPhoto["id"] as! Int)
                            }
                            if(index==3){
                                regIns =  String(idPhoto["id"] as! Int)
                            }
                        }
                    })
                    imagesInsurance.replaceObject(at: currentIndex, with: pickedImage)
                    if(currentIndex==2||currentIndex==3){
                        imagesOwner.replaceObject(at: currentIndex, with: pickedImage)
                    }
                    if(!isChecked){
                        isChecked = true
                        
                        let tempArr:NSArray = emptyArray.mutableCopy() as! NSArray
                        for i in 0..<tempArr.count {
                            let index = tempArr[i] as! Int
                            if((imagesInsurance[index] as! UIImage).size.width != 95){
                                emptyArray.remove(index)
                            }
                            
                        }
                        if(emptyArray.count<1){
                            containerViewController?.emptylbl.isHidden = true
                        }
                    }
                    table2.reloadData()
                    
        
                }else{
//                    setMessage("Отсутствует интернет соединение. Пожалуйста, проверьте доступ к сети и повторите загрузку документ")
                }
         
            }
    
    @objc func switchValueDidChange(sender:UISwitch!){
        if(sender.tag == 0){
            isOwner = sender.isOn
            containerViewController!.choseSteper(isOwner:isOwner)
                if(isOwner){
                    countOptions = 3
                    if(hasDKPInsurance){
                        countRows += 1
                    }
                    if(hasRegInsurance){
                        countRows += 1
                    }
                     self.tableHeight.constant = 153
                    UIView.animate(withDuration: 0.3, animations: {
                        self.table2.layoutIfNeeded()
                    })
                  
                }else{
                    self.tableHeight.constant = 51
                    UIView.animate(withDuration: 0.3, animations: {
                        self.table2.layoutIfNeeded()
                        
                    })
                   
                    countOptions = 1
                    countRows = 2
                }
            if(containerViewController!.steper.maxIndex>=2){
                if(isOwner){
                    containerViewController!.steper.maxIndex -= 1
                }else{
                    containerViewController!.steper.maxIndex += 1
                }
                containerViewController!.steper.setNeedsDisplay()
            }
            table1.reloadData()
            table2.reloadData()
        }else{
            if(sender.isOn){
                countRows += 1
            }else{
                countRows -= 1
            }
          
            if(sender.tag == 1){
                hasDKPInsurance = sender.isOn
            }
            if(sender.tag == 2){
                hasRegInsurance = sender.isOn
            }
              table2.reloadData()
        }
        
    }
    
   
}
