//
//  TOController.swift
//  RXAgent
//
//  Created by RX Group on 12.07.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import UIKit
import MessageUI

class TOController: UIViewController {

    @IBOutlet weak var searchBar: SearchTextField!
    @IBOutlet weak var contractorNumberLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var noFoundImg: UIImageView!
    @IBOutlet weak var getButton: UIButton!
    var refreshControl = UIRefreshControl()
    var isSearch:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.table.tableFooterView = UIView()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: "updateTO"), object: nil)
        searchBar.delegate = self
        self.addToolBarTextfield(textField: searchBar)
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        table.addSubview(refreshControl)
        
        let tapGestureRecognizer = UITapGestureRecognizer()
            tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
            tapGestureRecognizer.cancelsTouchesInView=false
            self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    //    self.refreshData()
        
        if(Profile.shared.profileLoaded){
            balanceLabel.text = String(format: "%.0f ₽", Profile.shared.profile?.contractor?.balance ?? "0")
            contractorNumberLabel.text = String(format: "№ %04d", Profile.shared.profile?.contractor?.id ?? 0)
        }
    }
    
    @objc func refreshData(){
        TORecords.shared.getRecordInfo(canCreate: {
            canCreate in
            self.refreshControl.endRefreshing()
            self.table.tableFooterView?.isHidden = true
           // self.getButton.isHidden = canCreate
            if (canCreate){
                TORecords.shared.loadTORecords { (loaded, records) in
                    if(loaded){
//                        self.noFoundImg.isHidden = (records ?? []).count > 0
//                        self.noFoundImg.image = UIImage(named: "noFound")
                        self.table.reloadData()
                    }
                }
            }else{
//                self.noFoundImg.isHidden = false
//                self.noFoundImg.image = UIImage(named: "noFoundTO")
            }
        })
    }
    
    @objc func reloadData(){
        self.table.reloadData()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
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
    
    @IBAction func goProfile(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "profileVC") as! ProfileViewController
        viewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func getPTOAction(_ sender: Any) {
        self.sendEmail()
    }
    
    func addToolBarTextfield(textField:UITextField){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Найти", style: UIBarButtonItem.Style.done, target: self, action: #selector(searchHandle))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spaceButton,doneButton], animated: false)
        textField.inputAccessoryView = toolbar
    }
    
    @objc func searchHandle() {
        self.view.endEditing(true)
        guard let text = searchBar.text else { return }
        if(text.count>0){
            if(TORecords.shared.searchRecord(index: Int(searchBar.text!) ?? 0) != nil){
                isSearch = true
                self.table.reloadData()
            }
        }

    }

}
//MARK: Инициализация свайпов
extension TOController:UIGestureRecognizerDelegate{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (navigationController?.viewControllers.count ?? 0) > 1
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: Отправка письма на почту
extension TOController:MFMailComposeViewControllerDelegate{
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["ageeva.f@rxgroup.ru"])
            mail.setSubject("Подключение модуля Техосмотр")
            mail.setMessageBody("Добрый день!<br><br>Пожалуйста, подключите модуль Техосмотр<br><br>Номер договора: \(String(format: "№ %04d", Profile.shared.profile?.contractor?.id ?? 0))<br>Номер телефона: \(Profile.shared.profile?.phone ?? "")<br>Имя: \(Profile.shared.profile?.fullName ?? "")<br>Почта: \(Profile.shared.profile?.email ?? "")", isHTML: true)
            present(mail, animated: true)
        } else {
            let alert = UIAlertController(title: "Внимание", message: "К сожалению на Вашем устройстве не настроен почтовый клиент, для подключения модуля свяжитесь с нами по телефону.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Позвонить", style: .default, handler: { action in
                DispatchQueue.main.async{
                    if let url = URL(string: "tel://+73833194022") {
                        UIApplication.shared.openURL(url)
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        print(result)
        controller.dismiss(animated: true)
    }
    
    
    
}

//MARK: Делегаты таблицы
extension TOController:UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return (isSearch && TORecords.shared.searchRecord != nil) ? 1:(TORecords.shared.records ?? []).count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (isSearch && TORecords.shared.searchRecord != nil) ? 1:(TORecords.shared.records ?? [])[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 32))
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.size.width, height: 32))
        label.font = UIFont(name: "Roboto-Regular", size: 12)
        label.text = "\(self.dateFromJSON(isSearch ? TORecords.shared.searchRecord?.date ?? "":TORecords.shared.records![section][0].date!))"
        label.textColor = UIColorFromRGB(rgbValue: 0x868686, alphaValue: 1)
        view.backgroundColor = UIColorFromRGB(rgbValue: 0xF6F3F8, alphaValue: 1)
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TOCell
        let record = TORecords.shared.getRecordByParam(isSearch: isSearch, section: indexPath.section, index: indexPath.row)
        
        cell.carNameLbl.text = record?.car ?? ""
        cell.numberLbl.text = "№ \(record?.id ?? 0)"
        cell.priceLbl.isHidden = record?.originalPrice == 0 && record?.price == 0
        cell.priceLbl.text = "\((record?.originalPrice ?? 0) + (record?.price ?? 0)) ₽"
        cell.gosnumberCell.text = record?.gosnumber ?? ""
        cell.setStatusForCell(status: record?.status, categoryID: record?.categoryId ?? 0, state: record?.state)
        
        return cell
    }
    
    
}

extension TOController: UITextFieldDelegate{
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchBar.text = ""
        isSearch = false
        table.reloadData()
        return true
    }
   
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = searchBar.text else { return false }
        let count = text.count + string.count - range.length
        if(count == 0){
            searchBar.text = ""
            isSearch = false
            table.reloadData()
        }
        return true
    }
    
   
}
