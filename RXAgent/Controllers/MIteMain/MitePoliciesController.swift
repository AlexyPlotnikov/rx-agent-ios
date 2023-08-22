//
//  MitePoliciesController.swift
//  RXAgent
//
//  Created by RX Group on 08.04.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit

class MitePoliciesController: UIViewController {
    
    var items:[MiteItemPeople]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    

}

extension MitePoliciesController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "Cell"
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellReuseIdentifier)
        
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .black
        cell.textLabel?.font = UIFont(name: "Roboto-Regular", size: 15)
        cell.textLabel?.numberOfLines = 0
        if(indexPath.row == 0){
            cell.textLabel?.text = "Скачать все"
        }else{
            cell.textLabel?.text = items[indexPath.row-1].fullName + " (\(self.dateFromJSON(items[indexPath.row-1].dob)))"
        }
        cell.imageView?.image = UIImage(named: "documentIcon")
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true)
        if(indexPath.row==0){
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showLoadView"), object: nil, userInfo: nil)
        }else{
            let idDataDict:[String: Int] = ["id": items[indexPath.row-1].id]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showLoadView"), object: nil, userInfo: idDataDict)
        }
    }
    
}
