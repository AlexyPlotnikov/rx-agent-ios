//
//  VehicleController.swift
//  RXAgent
//
//  Created by RX Group on 12/08/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit

class VehicleController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var table: UITableView!
    var imagePicker = UIImagePickerController()
    var emptyArray:NSMutableArray = []
    var categoryArray:NSMutableArray = []
    var periodArray:NSMutableArray = []
    var isCategory = true
    var isChecked = true
    var picker:UIPickerView!
    var containerViewController: MainOsagoController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        getDataMethod(key: "VehicleCategories",getKey: "vehicleCategories", completion:{
            result in
            
            self.categoryArray = result
        })
        
        getDataMethod(key: "VehicleTargets",getKey: "vehicleTargets", completion:{
            result in
            self.periodArray = result
        })
       self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
            if(!isChecked){
                isChecked = true
                
                let tempArr:NSArray = emptyArray.mutableCopy() as! NSArray
                for i in 0..<tempArr.count {
                    let index = tempArr[i] as! Int
                    if(needPTS){
                        if((imagesPTS[index] as! UIImage).size.width != 95){
                            emptyArray.remove(index)
                        }
                    }else{
                        if((imagesSRTS[index] as! UIImage).size.width != 95){
                            emptyArray.remove(index)
                        }
                    }
                    
                    
                }
       
            if(emptyArray.count<1){
                containerViewController?.emptylbl.isHidden = true
            }
        }
        table.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func getDataMethod(key: String, getKey : String, completion:@escaping (NSMutableArray)->Void){
        if((UserDefaults.standard.array(forKey: key)) != nil){
            let array = UserDefaults.standard.value(forKey: key) as! NSArray
            completion(array.mutableCopy() as! NSMutableArray)
        }else{
            getRequest(URLString: "\(domain)v0/\(key)", completion:{ result in
                DispatchQueue.main.async{
                    let array = result[getKey] as! NSArray
                    let defaults = UserDefaults.standard
                    defaults.set(array, forKey: key)
                    completion(array.mutableCopy() as! NSMutableArray)
                }
            })
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var tempIndexPath = indexPath.row
        if(isEdit){
            tempIndexPath+=4
        }
        if tempIndexPath == 0 || tempIndexPath == 1 {
            
            return 65
        } else if tempIndexPath == 2 || tempIndexPath == 3 {
            
            return 51
        }else if tempIndexPath == 4 {
            if(hasDKPInsurance){
                return 0
            }else{
                return 51
            }
        }else{
            
            return 109
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return countRowVehicle
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tempIndexPath = indexPath.row
        if(isEdit){
            tempIndexPath+=4
        }
        if tempIndexPath == 0 || tempIndexPath == 1 {
            let cellReuseIdentifier = "cellRow"
            let cell:VehicleCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! VehicleCell
            if(tempIndexPath == 0){
                cell.titleChooseCell.text = categoryVehicleTitle
                cell.subtitleChooseCell.text = "Категория ТС"
            }else{
                cell.titleChooseCell.text = targetVehicleTitle
                cell.subtitleChooseCell.text = "Цель использования"
            }
            
            return cell
        } else if tempIndexPath == 2 || tempIndexPath == 3 {
            let cellReuseIdentifier = "swItchCell"
            let cell:VehicleCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! VehicleCell
           
                cell.titleSwitchCell.text = titlesVehicle[tempIndexPath]
            if(tempIndexPath==2){
                cell.switcherCell.setOn(gosNumberEmpty, animated: true)
                cell.switcherCell.tag=0
            }else if(tempIndexPath == 3){
                cell.switcherCell.setOn(trailerEmpty, animated: true)
                cell.switcherCell.tag=1
            }
            cell.switcherCell.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
            return cell
            
        } else if tempIndexPath == 4  {
            let cellReuseIdentifier = "segmentCell"
            let cell:VehicleCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! VehicleCell
            if(hasDKPInsurance){
                needPTS=true
            }
            if(needPTS){
               cell.segment.selectedSegmentIndex = 0
            }else{
               cell.segment.selectedSegmentIndex = 1
            }
            cell.segment.addTarget(self, action: #selector(indexChanged), for: .valueChanged)
            return cell
        } else {
            let cellReuseIdentifier = "photoCell"
            let cell:VehicleCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! VehicleCell
            if(hasDKPInsurance){
                needPTS=true
            }
         
            if(needPTS){
                cell.titleCell.text = (PTStitle[tempIndexPath-5] as! String)
                cell.imageViewCell.image = (imagesPTS[tempIndexPath-5] as! UIImage)
            }else{
                cell.titleCell.text = (SRTStitle[tempIndexPath-5] as! String)
                cell.imageViewCell.image = (imagesSRTS[tempIndexPath-5] as! UIImage)
            }
            if(needPTS){
                if((imagesPTS[tempIndexPath-5] as! UIImage).size.width != 95){
                    cell.editBtnCell.setImage(UIImage(named: "edit photo"), for: .normal)
                }else{
                    cell.editBtnCell.setImage(UIImage(named: "addPhoto-1"), for: .normal)
                }
            }else{
                if((imagesSRTS[tempIndexPath-5] as! UIImage).size.width != 95){
                    cell.editBtnCell.setImage(UIImage(named: "edit photo"), for: .normal)
                }else{
                    cell.editBtnCell.setImage(UIImage(named: "addPhoto-1"), for: .normal)
                }
            }
            
            cell.subtitleCell.text = (SubtitleArray[tempIndexPath-5] as! String)
            cell.editBtnCell.tag = tempIndexPath-5
            cell.photoBtnCell.tag = tempIndexPath-5
            cell.editBtnCell.addTarget(self, action: #selector(self.chooseEditPhoto), for: .touchUpInside)
            cell.photoBtnCell.addTarget(self, action: #selector(self.showPhoto), for: .touchUpInside)
            if(emptyArray.contains(tempIndexPath-5)){
                DispatchQueue.main.async{
                    cell.photoViewCell.backgroundColor = UIColorFromRGB(rgbValue: 0xFFF6F6, alphaValue: 1)
                    cell.photoViewCell.layer.borderColor = UIColorFromRGB(rgbValue: 0xE12222, alphaValue: 1).cgColor
                    cell.photoViewCell.layer.borderWidth = 1
                    cell.titleCell.textColor = UIColorFromRGB(rgbValue: 0xE12222, alphaValue: 1)
                    cell.subtitleCell.textColor = UIColorFromRGB(rgbValue: 0xE12222, alphaValue: 1)
                }
            }else{
                DispatchQueue.main.async{
                    cell.photoViewCell.backgroundColor = .clear
                    cell.photoViewCell.layer.borderColor = UIColor.clear.cgColor
                    cell.photoViewCell.layer.borderWidth = 0
                    cell.titleCell.textColor = .black
                    cell.subtitleCell.textColor = UIColorFromRGB(rgbValue: 0xADADAD, alphaValue: 1)
                }
            }
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var tempIndexPath = indexPath.row
        if(isEdit){
            tempIndexPath+=4
        }
        
        if(tempIndexPath==0){
             DispatchQueue.main.async{
                self.isCategory=true
                self.showPicker("Укажите категорию ТС")
                self.picker.selectRow(categoryVehicleID-1, inComponent: 0, animated: true)
            }
        }else if(tempIndexPath==1){
             DispatchQueue.main.async{
                self.isCategory=false
                self.showPicker("Укажите цель использования")
                self.picker.selectRow(targetVehicleID-1, inComponent: 0, animated: true)
            }
        }
        
    }
    func drawEmptyPhotos()->Bool{
        isChecked = false
        emptyArray = checkVehicleAccess().emptysIndex
        table.reloadData()
        
        return vehicleImagesLoad()
    }
    @objc func chooseEditPhoto(sender: UIButton){
        currentIndex = sender.tag
        self.showCamera()
        
    }
    
    @objc func showPhoto(sender: UIButton){
        currentIndex = sender.tag
        if(needPTS){
            if(sender.tag == 0 ){
                if(PTSidFront.isEmpty || PTSidFront == "0"){
                    self.showCamera()
                }else{
                    self.showImage(image: imagesPTS[sender.tag] as! UIImage,view:  sender,name: PTSidFront)
                }
            }
            if(sender.tag == 1){
                if(PTSidBack.isEmpty || PTSidBack == "0"){
                    self.showCamera()
                }else{
                    self.showImage(image: imagesPTS[sender.tag] as! UIImage,view:  sender,name: PTSidBack)
                }
              }
        }else{
            if(sender.tag == 0 ){
                if(SRTSidFront.isEmpty || SRTSidFront == "0"){
                    self.showCamera()
                }else{
                    self.showImage(image: imagesSRTS[sender.tag] as! UIImage,view:  sender,name: SRTSidFront)
                }
            }
            if(sender.tag == 1){
                if(SRTSidBack.isEmpty || SRTSidBack == "0"){
                    self.showCamera()
                }else{
                    self.showImage(image: imagesSRTS[sender.tag] as! UIImage,view:  sender,name: SRTSidBack)
                }
            }
        }
    }
    
    func showImage(image: UIImage, view:UIView, name: String){
        if(isEdit){
            if(needPTS){
                if(loadPTS[currentIndex] as! Bool){
                    let appImage = ViewerImage.appImage(forImage: image)
                    let viewer = AppImageViewer(originImage: image, photos: [appImage], animatedFromView: view)
                    
                    present(viewer, animated: true, completion: nil)
                }else{
                    DispatchQueue.main.async {
                        imagesPTS.replaceObject(at: currentIndex, with: self.load(url: "\(domain)v0/Attachments/data/\(name)") ?? "")
                        
                        loadPTS[currentIndex] = true
                        let appImage = ViewerImage.appImage(forImage: imagesPTS[currentIndex] as! UIImage )
                        let viewer = AppImageViewer(originImage: imagesPTS[currentIndex] as! UIImage, photos: [appImage], animatedFromView: view)
                        
                        self.present(viewer, animated: true, completion: nil)
                    }
                }
            }else{
                if(loadSRTS[currentIndex] as! Bool){
                    let appImage = ViewerImage.appImage(forImage: image)
                    let viewer = AppImageViewer(originImage: image, photos: [appImage], animatedFromView: view)
                    
                    present(viewer, animated: true, completion: nil)
                }else{
                    DispatchQueue.main.async {
                        imagesSRTS.replaceObject(at: currentIndex, with: self.load(url: "\(domain)v0/Attachments/data/\(name)") ?? "")
                        
                        loadSRTS[currentIndex] = true
                        let appImage = ViewerImage.appImage(forImage: imagesSRTS[currentIndex] as! UIImage )
                        let viewer = AppImageViewer(originImage: imagesSRTS[currentIndex] as! UIImage, photos: [appImage], animatedFromView: view)
                        
                        self.present(viewer, animated: true, completion: nil)
                    }
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
        countItems = 2
        if(needPTS){
            firstLabels = PTStitle
        }else{
            firstLabels = SRTStitle
        }
        secondLabels = SubtitleArray
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
                    if(itemIndex==3){
                        if(needPTS){
                            if(index==0){
                                PTSidFront = String(idPhoto["id"] as! Int)
                            }
                            if(index==1){
                                PTSidBack =  String(idPhoto["id"] as! Int)
                            }
                        }else{
                            if(index==0){
                                SRTSidFront = String(idPhoto["id"] as! Int)
                            }
                            if(index==1){
                                SRTSidBack = String(idPhoto["id"] as! Int)
                            }
                        }
                    }
                })
                if(currentIndex<2){
                    if(needPTS){
                         imagesPTS.replaceObject(at: currentIndex, with: pickedImage as Any)
                    }else{
                         imagesSRTS.replaceObject(at: currentIndex, with: pickedImage as Any)
                    }
                }else{
                     imagesPTS.replaceObject(at: currentIndex, with: pickedImage as Any)
                     imagesSRTS.replaceObject(at: currentIndex, with: pickedImage as Any)
                }
                if(!isChecked){
                    isChecked = true
                    
                    let tempArr:NSArray = emptyArray.mutableCopy() as! NSArray
                    for i in 0..<tempArr.count {
                        let index = tempArr[i] as! Int
                        if(needPTS){
                            if((imagesPTS[index] as! UIImage).size.width != 95){
                                emptyArray.remove(index)
                            }
                        }else{
                            if((imagesSRTS[index] as! UIImage).size.width != 95){
                                emptyArray.remove(index)
                            }
                        }
                        
                        
                    }
                    if(emptyArray.count<1){
                        containerViewController?.emptylbl.isHidden = true
                    }
                }
                table.reloadData()
            
            
        }else{
            //                    setMessage("Отсутствует интернет соединение. Пожалуйста, проверьте доступ к сети и повторите загрузку документ")
        }
        
    }
    
    func showPicker(_ string: String){
        let alert = UIAlertController(title: string, message: "\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        alert.isModalInPopover = true
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view //to set the source of your alert
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // you can set this as per your requirement.
            popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
        }
        let pickerFrame = CGRect(x: 20, y: 52, width: self.view.frame.size.width-64, height: 150)
        picker = UIPickerView(frame: pickerFrame)
        picker.delegate = self
        picker.dataSource = self
        
        alert.addAction(UIAlertAction(title: "Готово", style: .default, handler: {
            _ in
            self.table.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.view.addSubview(picker)
       
        present(alert, animated: true, completion: nil)
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(isCategory){
            let category = self.categoryArray[row] as! [String:Any]
            categoryVehicleTitle = "\(category["title"] as! String) - \(category["shortDescription"] as! String)"
            categoryVehicleID = category["id"] as! Int
        }else{
            let category = self.periodArray[row] as! [String:Any]
            targetVehicleTitle = "\(category["title"] as! String)"
            targetVehicleID = category["id"] as! Int
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(isCategory){
            let category = self.categoryArray[row] as! [String:Any]
            return "\(category["title"] as! String) - \(category["shortDescription"] as! String)"
        }else{
            let period = self.periodArray[row] as! [String:Any]
            return "\(period["title"] as! String)"
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(isCategory){
            return self.categoryArray.count
        }else{
            return self.periodArray.count
        }
    }
    @objc func switchValueDidChange(_ sender: UISwitch){
        if(sender.tag==0){
            gosNumberEmpty = sender.isOn
        }else if(sender.tag == 1){
            trailerEmpty = sender.isOn
        }
    }
    
    @objc func indexChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex
        {
        case 0:
            needPTS = true
            let tempArr:NSArray = emptyArray.mutableCopy() as! NSArray
            for i in 0..<tempArr.count {
                let index = tempArr[i] as! Int
                if(needPTS){
                    if((imagesPTS[index] as! UIImage).size.width != 95){
                        emptyArray.remove(index)
                    }
                }else{
                    if((imagesSRTS[index] as! UIImage).size.width != 95){
                        emptyArray.remove(index)
                    }
                }
                
                
            }
            if(emptyArray.count<1){
                containerViewController?.emptylbl.isHidden = true
            }
            table.reloadData()
        case 1:
            needPTS = false
            let tempArr:NSArray = emptyArray.mutableCopy() as! NSArray
            for i in 0..<tempArr.count {
                let index = tempArr[i] as! Int
                if(needPTS){
                    if((imagesPTS[index] as! UIImage).size.width != 95){
                        emptyArray.remove(index)
                    }
                }else{
                    if((imagesSRTS[index] as! UIImage).size.width != 95){
                        emptyArray.remove(index)
                    }
                }
                
                
            }
            if(emptyArray.count<1){
                containerViewController?.emptylbl.isHidden = true
            }
            table.reloadData()
        default:
            break
        }
    }

}
