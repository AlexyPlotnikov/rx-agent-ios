//
//  ViewController.swift
//  RXAgent
//
//  Created by RX Group on 24/01/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import AudioToolbox


struct News:Codable{
    var id:Int
    var miniImage:String
    var pages:[Pages]
    var shortTitle:String
}

struct Pages:Codable{
    var description:String
    var imageNews:String
    var title:String
    var url:String
}

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
   
 //   @IBOutlet weak var searchBar: SearchTextField!
    @IBOutlet weak var header: HeaderView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var balanceLbl: UILabel!
    @IBOutlet weak var numberLbl: UILabel!
    @IBOutlet weak var noFoundImg: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var registerBg: UIView!
    @IBOutlet weak var balanceBG: UIView!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var refreshBtn: UIButton!
    
    struct ViewedNews:Codable{
        var contractors:[String]?
        var newsID:Int?
    
        var asDictionary : [String:Any] {
          let mirror = Mirror(reflecting: self)
          let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
            guard let label = label else { return nil }
            return (label, value)
          }).compactMap { $0 })
          return dict
        }
    }
    
   
    var newsArray:[News] = []
    var viewedNewsArray:[ViewedNews] = []
    
    var refreshControl = UIRefreshControl()
    var isLoadingReady:Bool=true
    var offset:Int=15
    var isSearch:Bool = false
    
    var ref: DatabaseReference!
    var refUser: DatabaseReference!
   
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        registerBg.layer.cornerRadius = 16
        balanceBG.layer.cornerRadius = 12
        balanceBG.backgroundColor = UIColor.init(displayP3Red: 70/255, green: 54/255, blue: 81/255, alpha: 1)
        
        

        
        let cellSize = CGSize(width:collectionView.bounds.size.height, height:collectionView.bounds.size.height)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal //.horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 0
        collectionView.setCollectionViewLayout(layout, animated: true)
        
        ref = Database.database().reference().child("newsMobile")
        ref.observe(.value, with: { snapshot in
           
                //сериализация справочника в Data, чтобы декодировать ее в структуру
                if (!JSONSerialization.isValidJSONObject(snapshot.value as Any)) {
                        print("is not a valid json object")
                        self.newsArray = []
                        return
                }else{
                    if let jsonData = try? JSONSerialization.data(withJSONObject: snapshot.value!, options: .prettyPrinted){
                        if let tempNews = try? JSONDecoder().decode([News].self, from: jsonData){
                            self.newsArray = tempNews
                            self.newsArray.remove(at: 0)
                        }
                        
                    }
                }
                self.updateViewedNews()
            
        })

        
      
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: NSNotification.Name(rawValue: "close"), object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(openOsagoRemote(_:)),
                                               name: NSNotification.Name(rawValue: "openOsago"),
                                               object: nil)
//        searchBar.delegate=self
//        self.addToolBarTextfield(textField: searchBar)
        
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        table.addSubview(refreshControl)
        table.tableFooterView?.isHidden = true
        

        let tapGestureRecognizer = UITapGestureRecognizer()
            tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
            tapGestureRecognizer.cancelsTouchesInView=false
            self.view.addGestureRecognizer(tapGestureRecognizer)
            self.table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
   
            if #available(iOS 15.0, *) {
                self.table.sectionHeaderTopPadding = 0
            }
     
    }
    
    
    
    
    @objc func openOsagoRemote(_ notification:Notification){
       
        mainID = notification.userInfo!["id"] as? String ?? ""
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "StateVC") as! DetailStateController
        viewController.viewModel = StateViewModel()
        viewController.modalPresentationStyle = .fullScreen
        isEdit = true
        self.table.isUserInteractionEnabled = true
        clearAgregator()
        self.navigationController?.pushViewController(viewController, animated: true)
//        getRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)", completion: {
//            result in
//            DispatchQueue.main.async{
//                currentFullPolice = result["eosagoPolicy"] as! [String : Any]
//                isEdit = true
//               
//                clearAgregator()
////                state = police.state
////                isPaid = police.paid!
////                if(EOSAGOPolicies.shared.needSetInsurance(policy: police)){
////                    isIns=true
////                }else{
////                    isIns=false
////                }
////
////                if(police.insuranceCompany != nil){
////                    insuranceID = "\(police.insuranceCompany!)"
////                }else{
////                    insuranceID = ""
////                }
////                let storyboard = UIStoryboard(name: "Main", bundle: nil)
////                let viewController = storyboard.instantiateViewController(withIdentifier: "DetailNC") as! DetailStateNavigation
////                viewController.modalPresentationStyle = .fullScreen
////                self.navigationController?.pushViewController(viewController, animated: true)
//                self.table.isUserInteractionEnabled = true
//            }
//        })
    }
    
    @IBAction func refreshBalance(_ sender: Any) {
        loadIndicator.isHidden = false
        refreshBtn.isHidden = true
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: {timer in
            self.loadIndicator.isHidden = true
            timer.invalidate()
            self.refreshBtn.isHidden = false
            Profile.shared.loadProfile { (loaded, profile) in
                if(loaded){
                    self.configUI()
                    if(profile!.isSystemAdmin){
                        self.showAlert(with: "Доступ к админскому аккаунту недоступен, выберите другой аккаунт.")
                    }else{
                        
                        if(profile!.contractor!.modules!.contains(8)){
                            self.loadData(index: self.offset)
                        }else{
                            self.setMessage("У Вас не подключен модуль Е-ОСАГО")
                        }
                    }
                }else{
                    self.showAlert(with: "Для продолжения работы необходимо заново авторизоваться.")
                }
            }
        })

        
    }
    
    
    func updateViewedNews(){
        refUser = Database.database().reference().child("viewedNewsId")
        refUser.observe(.value, with: { snapshot in
           
//                print(snapshot.value)
                //сериализация справочника в Data, чтобы декодировать ее в структуру
              
                if (!JSONSerialization.isValidJSONObject(snapshot.value as Any)) {
                        print("is not a valid json object")
                        self.viewedNewsArray = []
                        return
                }else{
                    if let jsonData = try? JSONSerialization.data(withJSONObject: snapshot.value!, options: .prettyPrinted){
                        if let viewedTempArray = try? JSONDecoder().decode([ViewedNews].self, from: jsonData){
                            self.viewedNewsArray = viewedTempArray
                        }
                    }
                }
                self.collectionView.reloadData()
           
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateProfile()
        
    }
    
    func updateProfile(){
        if(Profile.shared.profileLoaded){
            self.configUI()
            self.table.tableFooterView?.isHidden = true
            if(Profile.shared.profile!.isSystemAdmin){
                self.showAlert(with: "Доступ к админскому аккаунту недоступен, выберите другой аккаунт.")
            }else{
                self.loadData(index: self.offset)
                self.loadCardHide()
            }
        }else{
            self.table.tableFooterView?.isHidden = true
            Profile.shared.loadProfile { (loaded, profile) in
                if(loaded){
                    self.loadCardHide()
                    self.configUI()
                    if(profile!.isSystemAdmin){
                        self.showAlert(with: "Доступ к админскому аккаунту недоступен, выберите другой аккаунт.")
                    }else{
                        
                        if(profile!.contractor!.modules!.contains(8)){
                            self.loadData(index: self.offset)
                        }else{
                            self.setMessage("У Вас не подключен модуль Е-ОСАГО")
                        }
                    }
                }else{
                    self.showAlert(with: "Для продолжения работы необходимо заново авторизоваться.")
                }
            }
        }
    }
    
    func loadCardHide(){
        getRequest(URLString: domain + "v0/eosagoPolicySettings/\(String(format: "%04d", Profile.shared.profile?.contractor?.id ?? 0))", completion: {
            result in
            hidePayCard = (result["eosagoPolicySetting"] as? [String:Any] ?? [:])["hidePayCard"] as? Bool ?? false
        })
    }
    
    
    func loadData(index: Int, loadReady: ((Bool) -> Void)? = nil){
        if(isLoadingReady){
            isLoadingReady=false
            self.table.tableFooterView?.isHidden = true
            if(isReach){
                EOSAGOPolicies.shared.loadPolices(countItems: self.offset) { (loaded, policies) in
                    if(loaded){
                        self.noFoundImg.isHidden = (policies ?? []).count > 0
                        self.table.reloadData()
                        
                        self.refreshControl.endRefreshing()
                        self.isLoadingReady = true
                      //  print(token)
                    }
                    
                }
                
            }else{
                self.setMessage("Отсутствует интернет соединение.")
                balanceLbl.text = ""
                numberLbl.text = ""
            }
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (navigationController?.viewControllers.count ?? 0) > 1
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func onDidReceiveData(_ notification:Notification) {
        self.updateProfile()
        self.loadData(index: self.offset)
    }
    
    @objc fileprivate func handleTap(_ tap: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc func refreshData(_ sender: Any) {
        AudioServicesPlaySystemSound(1519)
//        if(searchBar.text!.isEmpty){
            self.loadData(index: self.offset)
//        }else{
//             self.refreshControl.endRefreshing()
//        }
       
    }
    
    func showAlert(with text:String){
        DispatchQueue.main.async{
            let alert = UIAlertController(title: "Внимание!", message: text, preferredStyle: .alert)
            let updateAction = UIAlertAction(title: "ОК", style: .default) { _ in
                UserDefaults.standard.removeObject(forKey: "token")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")
                UIApplication.shared.keyWindow?.rootViewController = initialViewController
            }
            
            alert.addAction(updateAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
 
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func configUI() {
        balanceLbl.text = Int((Profile.shared.profile?.contractor?.balance) ?? 0).formattedWithSeparator + " ₽"
        profileID = "\(Profile.shared.profile?.id ?? 0)"
        numberLbl.text = String(format: "№ %04d", Profile.shared.profile?.contractor?.id ?? 0)
    }
    
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            loadMore()
        }
    }
    
    func loadMore() {
        if (isLoadingReady) {
            self.table.tableFooterView?.isHidden = false
            loadMoreBegin(loadMoreEnd: {() -> () in
                DispatchQueue.main.async {
                    self.table.tableFooterView?.isHidden = true
                }
                            
            })
        }
    }
    
    func loadMoreBegin(loadMoreEnd:@escaping () -> ()) {
            self.table.tableFooterView?.isHidden = false
            if(self.offset <= EOSAGOPolicies.shared.meta?.total ?? 0){
                self.offset += 15
            }
        self.loadData(index: self.offset) {
            _ in
            loadMoreEnd()
        }
            
    
    }
   
   

   
    
    func openPolice(police: PoliceData){
        mainID = "\(police.id)"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "StateVC") as! DetailStateController
        viewController.viewModel = StateViewModel()
        viewController.modalPresentationStyle = .fullScreen
        isEdit = true
        self.table.isUserInteractionEnabled = true
        clearAgregator()
        self.navigationController?.pushViewController(viewController, animated: true)
//        getRequest(URLString: "\(domain)v0/EOSAGOPolicies/\(mainID)", completion: {
//            result in
//            DispatchQueue.main.async{
//                currentFullPolice = result["eosagoPolicy"] as! [String : Any]
//                isEdit = true
//
//                clearAgregator()
//                state = police.state
//                isPaid = police.paid!
//                if(EOSAGOPolicies.shared.needSetInsurance(policy: police)){
//                    isIns=true
//                }else{
//                    isIns=false
//                }
//
//                if(police.insuranceCompany != nil){
//                    insuranceID = "\(police.insuranceCompany!)"
//                }else{
//                    insuranceID = ""
//                }
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let viewController = storyboard.instantiateViewController(withIdentifier: "fullVC") as! FullStateController
//             //   viewController.viewModel = StateViewModel()
//                viewController.modalPresentationStyle = .fullScreen
//                self.navigationController?.pushViewController(viewController, animated: true)
//
//
//            }
//        })
        
        
    }
    
   
    func setMessage(_ text:String) {
        DispatchQueue.main.async{
            let alertController = UIAlertController(title: "Внимание!", message:
                text , preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
   

    func dateFromJSON(_ JSONdate: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd"
        dateFormatterPrint.dateStyle = DateFormatter.Style.short
        dateFormatterPrint.locale = NSLocale(localeIdentifier: "ru") as Locale

        let date = dateFormatterGet.date(from: JSONdate)

        return dateFormatterPrint.string(from: date!)
    }

  
    @IBAction func goprofile(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "profileVC") as! ProfileViewController
        viewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    @IBAction func addAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "addVC")
        self.present(initialViewController, animated: true, completion: nil)
    }
    
    func addToolBarTextfield(textField:UITextField){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Найти", style: UIBarButtonItem.Style.done, target: self, action: #selector(searchHandle))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spaceButton,doneButton], animated: false)
        textField.inputAccessoryView = toolbar
    }
    
    @objc func searchHandle(){
        self.view.endEditing(true)
//        guard let text = searchBar.text else { return }
//        if(text.count>0){
//            EOSAGOPolicies.shared.loadSearchPolice(idPolice: text) { (ready, policies) in
//                self.isSearch = ready
//                if(ready){
//                    self.table.reloadData()
//                }
//            }
//        }
    }
    
    
    @IBAction func getBalance(_ sender: Any) {
        if(Profile.shared.profileLoaded){
            if(Profile.shared.profile!.contractor!.balanceRefillCard == nil){
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "payVC") as! MBPaymentController
                self.present(viewController, animated: true, completion: nil)
                
            }else{
                        getRequest(URLString: domain + "v0/BalanceRefillCards/\(Profile.shared.profile!.contractor!.balanceRefillCard!)", completion: {
                            result in
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "", message: "Пополнить свой баланс можно, отправив деньги на карту «\((result["balanceRefillCard"] as! [String:Any])["formatNumber"] as! String), \((result["balanceRefillCard"] as! [String:Any])["ownerName"] as! String)» с комментарием «\(Profile.shared.profile!.contractor!.id)».", preferredStyle: UIAlertController.Style.alert)
                
                                alert.addAction(UIAlertAction(title: "Скопировать номер карты", style: UIAlertAction.Style.default, handler: {_ in
                                    UIPasteboard.general.string = ((result["balanceRefillCard"] as! [String:Any])["formatNumber"] as! String)
                                        }))
                                        alert.addAction(UIAlertAction(title: "Отмена", style: UIAlertAction.Style.cancel, handler: nil))
                
                                        self.present(alert, animated: true, completion: nil)
                
                
                
                            }
                
                        })
            }
        }
        
    }
    
    
}



//MARK: TextField Delegates
extension ViewController:UITextFieldDelegate{
//    func textFieldShouldClear(_ textField: UITextField) -> Bool {
//        searchBar.text = ""
//        isSearch = false
//        table.reloadData()
//        return true
//    }
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        guard let text = searchBar.text else { return false }
//        let count = text.count + string.count - range.length
//        if(count == 0){
//            searchBar.text = ""
//            isSearch = false
//            table.reloadData()
//        }
//        return true
//    }
    
}

//MARK: TableView Delegates
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isSearch ? 1:EOSAGOPolicies.shared.policies.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 32))
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.size.width, height: 32))
        label.font = UIFont(name: "Roboto-Regular", size: 12)
        label.text = "\(self.dateFromJSON(isSearch ? EOSAGOPolicies.shared.searchPolicies.createDate :EOSAGOPolicies.shared.policies[section][0].createDate))"
        label.textColor = UIColorFromRGB(rgbValue: 0x868686, alphaValue: 1)
        view.backgroundColor = UIColorFromRGB(rgbValue: 0xF6F3F8, alphaValue: 1)
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return isSearch ? 1:EOSAGOPolicies.shared.policies[section].count
        
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cellReuseIdentifier = "cell"
        let cell:FeedCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! FeedCell
        
        let police = EOSAGOPolicies.shared.getPolicyByParam(isSearch: self.isSearch, index: indexPath.row, section: indexPath.section)
        
        cell.autoLbl.text = (police.vehicleMark ?? "") + " " + (police.vehicleModel ?? "")
        cell.nameLbl.text = police.insurantShortName ?? ""
        cell.numberPolice.text = "№\(police.id)"
        
        cell.setStatus(state: police.state, isShort: police.isShort!, isPaid: police.paid!,isInsurance: EOSAGOPolicies.shared.needSetInsurance(policy: police))
        cell.setPrice(isRX: EOSAGOPolicies.shared.isRXPolicy(policy: police), finalBonus: police.finalBonus, baseCost: EOSAGOPolicies.shared.getCost(policy: police), state: police.state, super: police.super)
        cell.icon.image = EOSAGOPolicies.shared.getIcon(policy: police)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.table.isUserInteractionEnabled = false
        if(isReach){
            let police = EOSAGOPolicies.shared.getPolicyByParam(isSearch: self.isSearch, index: indexPath.row, section: indexPath.section)
            self.openPolice(police: police)
        }else{
            self.setMessage("Отсутствует интернет соединение.")
        }
        
    }
}

extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.newsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! StoriesCell
        
        let news = self.newsArray[indexPath.row]
       
        let url = URL(string: news.miniImage)
       
        cell.storieImage.sd_setImage(with: url, placeholderImage: nil, options: [.continueInBackground,.progressiveLoad,.refreshCached], completed: {_,_,_,_ in
        cell.storiesTitle.text = news.shortTitle
           
            if let storie = self.viewedNewsArray.filter({$0.newsID == news.id && $0.newsID != 0}).first {
                let profileID = String(format: "%04d", Profile.shared.profile?.contractor?.id ?? 0)
                
                if((storie.contractors?.contains(profileID)) != nil){
                    cell.viewedStories()
                }else{
                    cell.gradientStories()
                }
            }else{
                cell.gradientStories()
            }
        })
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "storiesVC") as! StoriesController
            viewController.stories = self.newsArray[indexPath.row].pages
            self.senddb(id: self.newsArray[indexPath.row].id)
            self.present(viewController, animated: true, completion: nil)
        
    }
    
  func senddb( id: Int) {
        
        let profileID = String(format: "%04d", Profile.shared.profile?.contractor?.id ?? 0)
        var news = self.viewedNewsArray.filter{$0.newsID == id}
        
        if(news.count == 0){
            var tempViewed = self.viewedNewsArray.map{$0.asDictionary}
            tempViewed.append(ViewedNews(contractors: [profileID], newsID: id).asDictionary)
            self.refUser.setValue(tempViewed)
        }else{
            if(!(news[0].contractors?.contains(profileID) ?? true)){
                var tempViewed = self.viewedNewsArray.filter{$0.newsID != id}.map{$0.asDictionary}
                news[0].contractors!.append(profileID)
                tempViewed.append(news[0].asDictionary)
                self.refUser.setValue(tempViewed)
            }
        }
       
    }
}

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {

    func loadImageUsingCacheWithURLString(_ URLString: String, placeHolder: UIImage?) {

        self.image = nil
        if let cachedImage = imageCache.object(forKey: NSString(string: URLString)) {
            self.image = cachedImage
            return
        }

        if let url = URL(string: URLString) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in

                //print("RESPONSE FROM API: \(response)")
                if error != nil {
                    print("ERROR LOADING IMAGES FROM URL: \(String(describing: error))")
                    DispatchQueue.main.async { [weak self] in
                        self?.image = placeHolder
                    }
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    if let data = data {
                        if let downloadedImage = UIImage(data: data) {
                            imageCache.setObject(downloadedImage, forKey: NSString(string: URLString))
                            self?.image = downloadedImage
                        }
                    }
                }
            }).resume()
        }
    }
}
