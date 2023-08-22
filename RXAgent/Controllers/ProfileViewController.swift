//
//  ProfileViewController.swift
//  RXAgent
//
//  Created by Алексей on 06.07.2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit
import CardScan

class ProfileViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate {
   
    @IBOutlet weak var opacityAvatar: UIImageView!
    
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var numberLbl: UILabel!
    @IBOutlet weak var balanceLbl: UILabel!
    @IBOutlet weak var cardScroll: UIScrollView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var cardLbl: UILabel!
    
    var context = CIContext(options: nil)
    var cardArray = [[String:String]]()
    var addCard:UIButton!
    
    var icons: NSMutableArray = ["whatsapp", "phone", "tutorial","cmartChoise","redCross"]
    var namesArray: NSMutableArray = ["Написать в WhatsApp", "Позвонить в поддержку", "Обучение", "Смарт-выбор","Удалить аккаунт"] 
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionHeight.constant = (hidePayCard ?? false) ? 0:132
        cardLbl.isHidden = (hidePayCard ?? false)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        let cellSize = CGSize(width:194 , height:123)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal //.horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        collectionView.setCollectionViewLayout(layout, animated: true)
   
        self.table.tableFooterView = UIView()
        self.configUI()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCards), name: NSNotification.Name(rawValue: "reloadCards"), object: nil)
        self.reloadCards()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    @objc func reloadCards(){
        Cards.sharedInstance().loadCards { (loaded, cards) in
            self.collectionView.reloadData()
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (navigationController?.viewControllers.count ?? 0) > 1
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
  
    func blurImage(usingImage image: UIImage, blurAmount:CGFloat)->UIImage?{
        let currentFilter = CIFilter(name: "CIGaussianBlur")
        let beginImage = CIImage(image: image)
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(blurAmount, forKey: kCIInputRadiusKey)
        
        let cropFilter = CIFilter(name: "CICrop")
        cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
        cropFilter!.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
        
        let output = cropFilter!.outputImage
        let cgimg = context.createCGImage(output!, from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!)
       
        
        return processedImage
    }
    
    func configUI(){
        
        avatar.layer.cornerRadius=avatar.frame.size.width/2
        avatar.layer.masksToBounds=true
        avatar.layer.borderColor = UIColorFromRGB(rgbValue: 0xFFFFFF, alphaValue: 0.3).cgColor
        avatar.layer.borderWidth = 4
        balanceLbl.font = UIFont(name: "Roboto-Bold", size: 14)
        numberLbl.font = UIFont(name: "Roboto-Bold", size: 14)
        nameLbl.font = UIFont(name: "Roboto-Medium", size: 17)
        let defaults = UserDefaults.standard
        if let imgData = defaults.object(forKey: "imageAva\(profileID)") as? Data
        {
            if let image = UIImage(data: imgData)
            {
              self.avatar.image = image
              self.opacityAvatar.image = blurImage(usingImage: image, blurAmount: 3)
            }
        }else{
            if(Profile.shared.avatarLoaded){
                let defaults = UserDefaults.standard
                let imgData = self.load(url: "https://api.rx-agent.ru/v0/attachments/data/\(Profile.shared.profile!.avatarMinID!)")!.jpegData(compressionQuality: 1.0)
                defaults.set(imgData, forKey: "imageAva\(profileID)")
                self.avatar.image = UIImage(data: imgData!)
                self.opacityAvatar.image = self.blurImage(usingImage: UIImage(data: imgData!)!, blurAmount: 3)
            }else{
                avatar.image = UIImage(named: "ava")
                self.opacityAvatar.image = blurImage(usingImage: UIImage(named: "ava")!, blurAmount: 3)
            }

        }
       
        nameLbl.text = Profile.shared.profile?.fullName
        balanceLbl.text = String(format: "%.0f ₽", Profile.shared.profile?.contractor?.balance ?? "0")
        numberLbl.text = String(format: "%04d", Profile.shared.profile?.contractor?.id ?? 0)
    }
    
    @objc func switchChanged(switcher:UISwitch){
        cmartCamera.isChecked = switcher.isOn
        cmartCamera.needSmart = false
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(cmartCamera) {
           let defaults = UserDefaults.standard
           defaults.set(encoded, forKey: "smart")
        }
    }
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return namesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "Cell"
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellReuseIdentifier)
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = indexPath.row != 4 ? .black:.red
        cell.textLabel?.font = UIFont(name: "Roboto-Regular", size: 14)
        cell.imageView?.image = UIImage(named: icons[indexPath.row] as! String)
        cell.textLabel?.text = namesArray[indexPath.row] as? String
        cell.selectionStyle = .none
        if(indexPath.row<3 || indexPath.row == 4){
            if(indexPath.row == 4){
                cell.accessoryType = .none
            }else{
                cell.accessoryType = .disclosureIndicator
            }
            
        }else{
            cell.accessoryType = .none
            let switchView = UISwitch(frame: .zero)
                switchView.setOn(cmartCamera.isChecked, animated: true)
               switchView.tag = indexPath.row
               switchView.addTarget(self, action: #selector(self.switchChanged(switcher:)), for: .valueChanged)
               cell.accessoryView = switchView
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row==0){
            DispatchQueue.main.async{
                let phoneNumber =  "+79628295322"
             //   let message = "Привет".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                let newURL = "https://api.whatsapp.com/send?phone=\(phoneNumber)" //&text=\(message!)"
                let appURL = URL(string: newURL)!
                if UIApplication.shared.canOpenURL(appURL) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
                    }
                    else {
                        UIApplication.shared.openURL(appURL)
                    }
                }else{
                    self.setMessage("У Вас не установлено приложение WhatsApp")
                }
            }
        }
        if(indexPath.row == 1){
            if let url = URL(string: "tel://+73833194022") {
                    UIApplication.shared.openURL(url)
                }
        }
        if(indexPath.row==2){
            DispatchQueue.main.async{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "tutorialVC")
                self.present(initialViewController, animated: true, completion: nil)
            }
        }
        if(indexPath.row == 4){
            let alert = UIAlertController(title: "Внимание", message: "Вы действительно хотите удалить аккаунт?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { action in
                deleteRequest(URLString: domain + "v0/employees/me", completion: {
                    result in
                    
                    print(result)
                    DispatchQueue.main.async {
                        UserDefaults.standard.removeObject(forKey: "token")
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")
                        UIApplication.shared.keyWindow?.rootViewController = initialViewController
                    }
                   
                })
            }))
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        
        }
    }
    func replaceObjectToCard(textStr:String)->String{
        
        if(textStr.count<16){
            return textStr
        }
        var result = ""
        let start = textStr.startIndex;
        let end = textStr.index(textStr.startIndex, offsetBy: textStr.count-4);
        result = "**** **** ***\(textStr.replacingCharacters(in: start..<end, with: "* "))"
        
        
        return result
    }
    
    func setMessage(_ text:String) {
        DispatchQueue.main.async{
            let alertController = UIAlertController(title: "Внимание!", message:
                text , preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
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
    
    @IBAction func logOut(_ sender: Any) {
        let alert = UIAlertController(title: "Внимание", message: "Вы действительно хотите выйти из аккаунта?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive, handler: { action in
            UserDefaults.standard.removeObject(forKey: "token")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")
            UIApplication.shared.keyWindow?.rootViewController = initialViewController
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func close(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showAlert(action1:String, action2:String, style:UIAlertAction.Style, isEdit:Bool, index:Int? = 0) {
        let alert = UIAlertController(title: "", message: "Выберите действие", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: action1, style: .default , handler:{ (UIAlertAction)in
            if(isEdit){
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "detailCardVC") as! DetailCardController
                vc.isEdit = true
                Cards.sharedInstance().editCardIndex = index!
                self.present(vc, animated: true)
            }else{
                self.openScaner()
            }
        }))
        
        alert.addAction(UIAlertAction(title: action2, style: style , handler:{ (UIAlertAction)in
            if(isEdit){
                Cards.sharedInstance().removeCardByIndex(index: index!, deleted: { _ in
                    self.collectionView.reloadData()
                })
             
            }else{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "detailCardVC") as! DetailCardController
                Cards.sharedInstance().scanedCard = nil
                self.present(vc, animated: true)
            }
        }))

      
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler:{ (UIAlertAction)in
            
        }))

        
        //uncomment for iPad Support
        alert.popoverPresentationController?.sourceView = self.view

        self.present(alert, animated: true, completion: nil)
    }
    
    func openScaner(){
           guard let vc = ScanViewController.createViewController(withDelegate: self) else {
               print("scan view controller not supported on this hardware")
               return
           }
           vc.stringDataSource = self
           vc.hideBackButtonImage = true
           vc.positionCardFont = UIFont.systemFont(ofSize: 16)
           CreditCardUtils.prefixesRegional = ["2200", "2201", "2202", "2203", "2204"]

           self.present(vc, animated: true)
    }
   
}

extension ProfileViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return (Cards.sharedInstance().cardsArray ?? []).count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if((Cards.sharedInstance().cardsArray ?? []).count == indexPath.row){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addCell", for: indexPath) as! CardsCell
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCard", for: indexPath) as! CardsCell
                cell.cardNumber.text = self.replaceObjectToCard(textStr: Cards.sharedInstance().cardsArray![indexPath.row].payCardNumber!)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if((Cards.sharedInstance().cardsArray ?? []).count == indexPath.row){
            self.showAlert(action1: "Отсканировать карту", action2: "Ввести вручную", style: .default, isEdit: false)
        }else{
            Cards.sharedInstance().scanedCard = Cards.sharedInstance().cardsArray![indexPath.row]
            self.showAlert(action1: "Редактировать карту", action2: "Удалить карту", style: .destructive, isEdit: true,index: indexPath.row)
        }
    }
    
}
extension ProfileViewController: FullScanStringsDataSource {
    func denyPermissionTitle() -> String {
        return ""
    }
    
    func denyPermissionMessage() -> String {
        return ""
    }
    
    func denyPermissionButton() -> String {
        return ""
    }
    
    func scanCard() -> String {
        return "Отсканируйте карту"
    }
    
    func positionCard() -> String {
        return "Держите карту внутри рамки.\nОна будет считана автоматически."
    }
    
    func backButton() -> String {
        return "Закрыть"
    }
    
    func skipButton() -> String {
        return "РУЧНОЙ ВВОД"
    }
    
    
}

extension ProfileViewController: ScanDelegate {
   func userDidSkip(_ scanViewController: ScanViewController) {
        self.dismiss(animated: true)
    }

    func userDidCancel(_ scanViewController: ScanViewController) {
        self.dismiss(animated: true)
    }

    func userDidScanCard(_ scanViewController: ScanViewController, creditCard: CreditCard) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "detailCardVC") as! DetailCardController
        let words = creditCard.name?.components(separatedBy: " ") ?? []
        var firstName = ""
        var lastName = ""
        if(words.count == 2){
            firstName = words[0]
            lastName = words[1]
        }
        Cards.sharedInstance().scanedCard = Card(payCardLastName: lastName, payCardYear: creditCard.expiryYear ?? "", payCardFirstName: firstName, payCardNumber: creditCard.number , payCardCVC: creditCard.cvv ?? "", payCardMonth: creditCard.expiryMonth ?? "")

        self.dismiss(animated: true)
        self.present(vc, animated: true)
    }

    func userDidScanQrCode(_ scanViewController: ScanViewController, payload: String) {
        self.dismiss(animated: true)
        print(payload)
    }
}
