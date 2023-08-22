//
//  CameraController.swift
//  RXAgent
//
//  Created by RX Group on 14/02/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit
import AVFoundation


class CameraController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate,PreviewDelegate {
   
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    var titleCamera: String = ""
  //  @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var photoView: UIView!
    var numberPhoto:Int = 0
    @IBOutlet weak var closeBtn: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var doneBtn: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func createViews(){
         miniPhoto = []
    
        for i in 0..<countItems{
            let prevView = PreviewCameraView(frame: CGRect(x: self.scroll.frame.size.width/4*CGFloat(i), y: (self.scroll.frame.size.height-self.scroll.frame.size.height*0.8)/2, width: self.scroll.frame.size.width/4, height: self.scroll.frame.size.height*0.8))
            prevView.tag = i
            print(secondLabels[i])
            prevView.setTextLabel(text: "\(firstLabels[i]) \(secondLabels[i])")
            prevView.setSwitchHiden(hide: true)
            prevView.delegate = self
            if(activeItem==1||activeItem==2){
                if(i==2){
                    prevView.setSwitchHiden(hide: false)
                    prevView.setAccessSwitch(access: hasDKPInsurance)
                }
                if(i==3){
                    prevView.setSwitchHiden(hide: false)
                    prevView.setAccessSwitch(access: hasRegInsurance)
                }
            }
           
          
            if(activeItem==1){
                    if((imagesInsurance[i] as! UIImage).size.width != 95){
                        prevView.imageForPreview(image: (imagesInsurance[i] as! UIImage))
                    }
            }
            if(activeItem==2){
                if((imagesOwner[i] as! UIImage).size.width != 95){
                    prevView.imageForPreview(image: (imagesOwner[i] as! UIImage))
                }
            }
            if(activeItem==3){
                if(needPTS){
                    if((imagesPTS[i] as! UIImage).size.width != 95){
                        prevView.imageForPreview(image: (imagesPTS[i] as! UIImage))
                    }
                }else{
                    if((imagesSRTS[i] as! UIImage).size.width != 95){
                        prevView.imageForPreview(image: (imagesSRTS[i] as! UIImage))
                    }
                }
            }
            if(activeItem==4){
                if((imagesDriver[i] as! UIImage).size.width != 95){
                    prevView.imageForPreview(image: (imagesDriver[i] as! UIImage))
                }
            }
            miniPhoto.add(prevView)
            
            if(currentIndex == i){
                prevView.setSelected()
            }
            
            self.scroll.addSubview(prevView)
        }
        scroll.contentSize=CGSize(width: scroll.frame.size.width/4*CGFloat(countItems), height: scroll.frame.size.height)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        captureSession = AVCaptureSession()
//        captureSession!.sessionPreset = AVCaptureSession.Preset.photo
//
//        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
//
//            var error: NSError?
//            var input: AVCaptureDeviceInput!
//            do {
//                input = try AVCaptureDeviceInput(device: backCamera!)
//            } catch let error1 as NSError {
//                error = error1
//                input = nil
//            }
//
//            if error == nil && captureSession!.canAddInput(input) {
//                captureSession!.addInput(input)
//
//                stillImageOutput = AVCaptureStillImageOutput()
//                stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecType.jpeg]
//                if captureSession!.canAddOutput(stillImageOutput!) {
//                    captureSession!.addOutput(stillImageOutput!)
//
//                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
//                    previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
//                    previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
//                    photoView.layer.addSublayer(previewLayer!)
//
//                    captureSession!.startRunning()
//                }
//            }
//
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.createViews()
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()

            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
            DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
                self.captureSession.startRunning()
                //Step 13
            }
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.photoView.bounds
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
        
//        Multiple commands produce '/Users/ivanzubarev/Library/Developer/Xcode/DerivedData/RXAgent-adwslibhvwpjrwagbzyendgioohk/Build/Products/Debug-iphoneos/RXAgent.app/Frameworks/CardScan.framework':
//        1) Target 'RXAgent' has copy command from '/Volumes/Vertulexa/rxagent-ios/Pods/CardScan/CardScan.xcframework/ios-arm64/CardScan.framework' to '/Users/ivanzubarev/Library/Developer/Xcode/DerivedData/RXAgent-adwslibhvwpjrwagbzyendgioohk/Build/Products/Debug-iphoneos/RXAgent.app/Frameworks/CardScan.framework'
//        2) That command depends on command in Target 'RXAgent': script phase “[CP] Embed Pods Frameworks”

        
        
        doneBtn.layer.cornerRadius = 6
        doneBtn.layer.masksToBounds = true
        doneBtn.backgroundColor = UIColorFromRGB(rgbValue: 0x000000, alphaValue: 0.7)
        if(activeItem==1){
            doneBtn.isHidden = !insuranceImagesLoad()
        }
        
        if(activeItem==2){
            doneBtn.isHidden = !ownerImagesLoad()
        }
        if(activeItem==3){
            doneBtn.isHidden = !vehicleImagesLoad()
        }
        if(activeItem==4){
            doneBtn.isHidden = !driverImagesLoad()
        }
    
        
    }
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        photoView.layer.addSublayer(videoPreviewLayer)
        
        //Step12
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    //    captureSession.stopRunning()
    }
    
//    func setupLivePreview() {
//        DispatchQueue.global().async { //[weak self] in
//            captureSession.startRunning()
//            DispatchQueue.main.async {
//                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//                videoPreviewLayer.videoGravity = .resizeAspectFill
//                videoPreviewLayer.connection?.videoOrientation = .portrait
//                videoPreviewLayer.frame = self.photoView.bounds
//                self.photoView.layer.addSublayer(videoPreviewLayer)
//                self.photoView.bringSubviewToFront(self.captureButton)
//                self.photoView.bringSubviewToFront(self.closeBtn)
//                self.photoView.bringSubviewToFront(self.doneBtn)
//
//            }
//        }
//    }
    
    //НАЖАТИЕ НА МИНИАТЮРКУ ВНУТРИ КАМЕРЫ
    func previewDidClick(button: UIButton, index: Int) {
        self.selectIndex(index: index)
    }
    
    func selectIndex(index: Int){
        currentIndex = index
        for i in 0..<countItems{
            let preview = miniPhoto[i] as! PreviewCameraView
            if(index == i){
                if(i>3){
                    UIView.animate(withDuration: 0.5, animations: {
                        self.scroll.contentOffset = CGPoint(x: self.scroll.frame.size.width, y: 0)
                    })
                    }
                preview.setSelected()
            }else{
                preview.setUnSelected()
            }
        }
    }
    
    func switcherChoseState(sender: UISwitch, index: Int) {
    
            if(sender.isOn){
                self.selectIndex(index: index)
            }
            
            if(index == 2){
                if(!sender.isOn){
                  self.selectIndex(index: 1)
                }
                hasDKPInsurance = sender.isOn
            }
            if(index == 3){
                if(!sender.isOn){
                    if(hasDKPInsurance){
                        self.selectIndex(index: 2)
                    }else{
                         self.selectIndex(index: 1)
                    }
                   
                }
                hasRegInsurance = sender.isOn
            }
        if(!hasDKPInsurance && !hasRegInsurance){
            countRowsOwner=2
            countRows = 2
        }
        if(hasDKPInsurance && !hasRegInsurance){
            countRowsOwner=3
            countRows = 3
        }
        if(!hasDKPInsurance && hasRegInsurance){
            countRowsOwner=3
            countRows = 3
        }
        if(hasDKPInsurance && hasRegInsurance){
            countRowsOwner=4
            countRows = 4
        }
            doneBtn.isHidden = !insuranceImagesLoad()

    }

    
    @IBAction func capture(_ sender: Any) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    
    @IBAction func close(_ sender: Any) {
        doneBtn.isHidden=true
        cmartCamera.needSmart = false
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name("didReceiveData"), object: nil)
    }
    
    
    @IBAction func done(_ sender: Any) {
        doneBtn.isHidden=true
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name("didReceiveData"), object: nil)
    }
    
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        if(isReach){
            let image = UIImage(data: imageData)
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "dd-MMMM-yyyy-HH-mm-ss"
            
            let date = Date()
            RXServerConnector.sharedInstance.uploadImage(URLString:"\(domain)v0/Attachments", image: image!, index: currentIndex, itemIndex:activeItem , name:  dateFormatterPrint.string(from: date) as NSString, completion:{  (result, index, itemIndex) in
                //замена айдишников для отправки модели
                let idPhoto = result["attachment"] as! [String: Any]
                if(itemIndex==1){
                    if(index==0){
                        passport1Ins = String(idPhoto["id"] as! Int)
                    }
                    if(index==1){
                        passport2Ins = String(idPhoto["id"] as! Int)
                    }
                    if(index==2){
                        DKPIns = String(idPhoto["id"] as! Int)
                    }
                    if(index==3){
                        regIns = String(idPhoto["id"] as! Int)
                    }
                    
                }
                if(itemIndex==2){
                    if(index==0){
                        passport1Owner = String(idPhoto["id"] as! Int)
                    }
                    if(index==1){
                        passport2Owner = String(idPhoto["id"] as! Int)
                    }
                    if(index==2){
                        DKPIns = String(idPhoto["id"] as! Int)
                    }
                    if(index==3){
                        regIns = String(idPhoto["id"] as! Int)
                    }
                    
                }
                
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
            
            //замена миниатюрки фотографии
            
            let preview = miniPhoto[currentIndex] as! PreviewCameraView
            preview.imageForPreview(image: image!)
            //замена фотографий в массиве
            if(activeItem==1){
                imagesInsurance.replaceObject(at: currentIndex, with: image as Any)
                if(currentIndex==2||currentIndex==3){
                    imagesOwner.replaceObject(at: currentIndex, with: image as Any)
                }
            }
            if(activeItem==2){
                imagesOwner.replaceObject(at: currentIndex, with: image as Any)
                if(currentIndex==2||currentIndex==3){
                    imagesInsurance.replaceObject(at: currentIndex, with: image as Any)
                }
            }
            if(activeItem==3){
                if(currentIndex<2){
                    if(needPTS){
                        imagesPTS.replaceObject(at: currentIndex, with: image as Any)
                    }else{
                        imagesSRTS.replaceObject(at: currentIndex, with: image as Any)
                    }
                }else{
                    imagesPTS.replaceObject(at: currentIndex, with: image as Any)
                    imagesSRTS.replaceObject(at: currentIndex, with: image as Any)
                }
            }
            if(activeItem==4){
                imagesDriver.replaceObject(at: currentIndex, with: image as Any)
            }
          
            //проверка на "не последний" индекс и переключение между миниатюрками
            var tempCount = 0
            
            if(activeItem==1){
                tempCount=countRows
            }
            if(activeItem==2){
                tempCount=countRowsOwner
            }
            if(activeItem==3){
                tempCount=2
            }
            if(activeItem==4){
                tempCount=countItems
            }
            for i in currentIndex..<tempCount{
                if(i+1<tempCount){
                        currentIndex += 1
                        break
                }
            }
            
            //выделение следующей миниатюрки
            for i in 0..<countItems{
                let preview = miniPhoto[i] as! PreviewCameraView
                if(currentIndex == i){
                    if(i>3){
                        UIView.animate(withDuration: 0.5, animations: {
                            self.scroll.contentOffset = CGPoint(x: self.scroll.frame.size.width, y: 0)
                        })
                    }
                    preview.setSelected()
                }else{
                    preview.setUnSelected()
                }
            }
            //активация кнопки готово
            if(activeItem==1){
                doneBtn.isHidden = !insuranceImagesLoad()
            }
            if(activeItem==2){
                doneBtn.isHidden = !ownerImagesLoad()
            }
            if(activeItem==3){
                doneBtn.isHidden = !vehicleImagesLoad()
            }
            if(activeItem==4){
                doneBtn.isHidden = !driverImagesLoad()
            }
        }else{
            
            setMessage("Отсутствует интернет соединение. Пожалуйста, проверьте доступ к сети и повторите загрузку документа.")
            
        }
        
    }
    func setMessage(_ text:String) {
        DispatchQueue.main.async{
            let alertController = UIAlertController(title: "Внимание!", message:
                text , preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
}



