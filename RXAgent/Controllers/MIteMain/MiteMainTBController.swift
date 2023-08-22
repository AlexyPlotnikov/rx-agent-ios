//
//  MiteMainTBController.swift
//  RXAgent
//
//  Created by RX Group on 28.03.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class MiteMainTBController: UIViewController {

    @IBOutlet weak var balanceLbl: UILabel!
    @IBOutlet weak var numberLbl: UILabel!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var registerBg: UIView!
    @IBOutlet weak var balanceBG: UIView!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var refreshBtn: UIButton!
    
    var refreshControl = UIRefreshControl()
    var isLoadingReady:Bool=true
    var offset:Int=15
    var meta:MetaDataMite!
    @IBOutlet weak var miteEmptyImg: UIImageView!
    
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
    var policies:[[MiteMainStruct]] = []
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: NSNotification.Name(rawValue: "close"), object: nil)
       
        if #available(iOS 15.0, *) {
            self.table.sectionHeaderTopPadding = 0
        }
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
            }
        }else{
            self.table.tableFooterView?.isHidden = true
            self.loadProfile()
        }
    }
    
    func loadProfile(){
        Profile.shared.loadProfile { (loaded, profile) in
            if(loaded){
                self.configUI()
                if(profile!.isSystemAdmin){
                    self.showAlert(with: "Доступ к админскому аккаунту недоступен, выберите другой аккаунт.")
                }else{
                    if(profile!.contractor!.modules!.contains(8)){
                        self.loadData(index: self.offset)
                    }else{
                        self.showAlert(with:"У Вас не подключен модуль Е-ОСАГО")
                    }
                }
            }else{
                self.showAlert(with: "Для продолжения работы необходимо заново авторизоваться.")
            }
        }
    }
    
    @IBAction func refreshBalance(_ sender: Any) {
        loadIndicator.isHidden = false
        refreshBtn.isHidden = true
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: {timer in
            self.loadIndicator.isHidden = true
            self.refreshBtn.isHidden = false
            timer.invalidate()
            self.loadProfile()
        })

        
    }
    
    
    @objc func onDidReceiveData(_ notification:Notification) {
        self.loadProfile()
        self.loadData(index: self.offset)
    }
    
    func loadData(index: Int, loadReady: ((Bool) -> Void)? = nil){
        if(isLoadingReady){
            isLoadingReady=false
            self.table.tableFooterView?.isHidden = true
                getRequest(URLString: domain + "v0/MitePolicies?Page=1&PerPage=\(self.offset)", completion: {
                    result in
                    DispatchQueue.main.async {
                        do {
                            //сериализация справочника в Data, чтобы декодировать ее в структуру
                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                            var tempPolicies = try! JSONDecoder().decode(MitePolicies.self, from: jsonData)
                            self.meta = tempPolicies.meta
                            let dateFormatter = DateFormatter()
                           
                                dateFormatter.dateFormat = "yyyy-MM-dd"
                            var newPolices:[MiteMainStruct] = []
                            for i in 0..<tempPolicies.mitePolicies.count{
                                if let dotRange = tempPolicies.mitePolicies[i].createDate.range(of: "T") {
                                   tempPolicies.mitePolicies[i].createDate.removeSubrange(dotRange.lowerBound..<tempPolicies.mitePolicies[i].createDate.endIndex)
                                }
                                newPolices.append(tempPolicies.mitePolicies[i])
                            }
                                  
                            self.policies = newPolices.groupSort(byDate: { dateFormatter.date(from: $0.createDate)! })
                            self.miteEmptyImg.isHidden = !self.policies.isEmpty
                            self.isLoadingReady = true
                            self.table.reloadData()
                          
                        }catch{
                            
                        }
                    }
                    
        
                })
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    
    func updateViewedNews(){
        refUser = Database.database().reference().child("viewedNewsId")
        refUser.observe(.value, with: { snapshot in
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

   
    @IBAction func goProfile(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "profileVC") as! ProfileViewController
        viewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    func configUI() {
        balanceLbl.text = Int((Profile.shared.profile?.contractor?.balance)!).formattedWithSeparator + " ₽"
        profileID = "\(Profile.shared.profile?.id ?? 0)"
        numberLbl.text = String(format: "№ %04d", Profile.shared.profile?.contractor?.id ?? 0)
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
    
    func dateFromJSON(_ JSONdate: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd"
        dateFormatterPrint.dateStyle = DateFormatter.Style.short
        dateFormatterPrint.locale = NSLocale(localeIdentifier: "ru") as Locale

        let date = dateFormatterGet.date(from: JSONdate)

        return dateFormatterPrint.string(from: date!)
    }
    
    @IBAction func balanceReq(_ sender: Any) {
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
    
    
    func getMulticolorText(firstText:String, secondText:String) -> NSMutableAttributedString{
        let attrs1 = [NSAttributedString.Key.font : UIFont(name: "Roboto-Bold", size: 16), NSAttributedString.Key.foregroundColor : UIColor.black]
        let attrs2 = [NSAttributedString.Key.font : UIFont(name: "Roboto-Regular", size: 14), NSAttributedString.Key.foregroundColor : UIColor.init(displayP3Red: 40/255, green: 40/255, blue: 40/255, alpha: 0.5)]
        let attributedString1 = NSMutableAttributedString(string:firstText, attributes:attrs1 as [NSAttributedString.Key : Any])
        let attributedString2 = NSMutableAttributedString(string:secondText, attributes:attrs2 as [NSAttributedString.Key : Any])

            attributedString1.append(attributedString2)
            return attributedString1
    }
}

extension MiteMainTBController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 32))
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.size.width, height: 32))
        label.font = UIFont(name: "Roboto-Regular", size: 12)
        label.text = "\(self.dateFromJSON(self.policies[section][0].createDate))"
        label.textColor = UIColorFromRGB(rgbValue: 0x868686, alphaValue: 1)
        view.backgroundColor = UIColorFromRGB(rgbValue: 0xF6F3F8, alphaValue: 1)
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.policies.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.policies[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "cell"
        let cell:MainMiteCell = self.table.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MainMiteCell
        let police = self.policies[indexPath.section][indexPath.row]
        cell.costLbl.attributedText = self.getMulticolorText(firstText: "\(Int(police.costClient).formattedWithSeparator) ₽", secondText: "(КВ:\(Int(Double(police.costClient)/100*25).formattedWithSeparator) ₽)")
        cell.countLbl.attributedText = self.getMulticolorText(firstText: "\(police.itemsCount) ", secondText: "чел.")
        cell.nameLbl.text = police.shortName
        cell.statusLbl.text = police.paid ? "Оплачено":"Ожидает оплаты"
        cell.statusLbl.textColor = police.paid ? UIColor.init(displayP3Red: 128/255, green: 161/255, blue: 43/255, alpha: 1):UIColor.init(displayP3Red: 243/255, green: 162/255, blue: 60/255, alpha: 1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.table.isUserInteractionEnabled = false
        let police = self.policies[indexPath.section][indexPath.row]
        getRequest(URLString: domain + "v0/MitePolicies/\(police.id)", completion: {
            result in
            DispatchQueue.main.async {
              
                    do {
                        //сериализация справочника в Data, чтобы декодировать ее в структуру
                        let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                        let tempPolice = try! JSONDecoder().decode(MiteDetailPolice.self, from: jsonData)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier: "MDetailVC") as! MiteDetailController
                        viewController.police = tempPolice.mitePolicy
                       
                       
                        self.table.isUserInteractionEnabled = true
                       
                        viewController.modalPresentationStyle = .fullScreen
                        self.navigationController?.pushViewController(viewController, animated: true)
                      
                    }catch{
                        
                    }
            
                
                
                
            }
            print(result)
           
        })
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            self.loadMore()
        }
    }
    
    func loadMore() {
        if (isLoadingReady) {
            self.table.tableFooterView?.isHidden = false
            self.loadMoreBegin(loadMoreEnd: {() -> () in
                DispatchQueue.main.async {
                    self.table.tableFooterView?.isHidden = true
                }
                            
            })
        }
    }
    
    func loadMoreBegin(loadMoreEnd:@escaping () -> ()) {
            self.table.tableFooterView?.isHidden = false
            if(self.offset <= self.meta.total){
                self.offset += 15
            }
        self.loadData(index: self.offset) {
            _ in
            loadMoreEnd()
        }
            
    
    }
    
}


extension MiteMainTBController:UICollectionViewDelegate, UICollectionViewDataSource{

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

