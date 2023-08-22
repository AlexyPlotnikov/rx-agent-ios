//
//  InsurerDetailController.swift
//  RXAgent
//
//  Created by RX Group on 18.04.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit

class InsurerDetailController: UIViewController {
    var tempItems:[ClientMite] = []
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd.MM.yyyy"
        tempItems = MiteModel.sharedInstance().miteItem.items.filter({dateFormatterGet.date(from:$0.dob)!<=date!})
        self.table.reloadData()
    }
    

    func dateFromJSON(_ JSONdate: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd.MM.yyyy"
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy-MM-dd"
        dateFormatterPrint.dateStyle = DateFormatter.Style.short
        dateFormatterPrint.locale = NSLocale(localeIdentifier: "ru") as Locale

        let date = dateFormatterGet.date(from: JSONdate)

        return dateFormatterPrint.string(from: date!)
    }

}

extension InsurerDetailController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "Cell"
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellReuseIdentifier)
        
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .black
        cell.textLabel?.font = UIFont(name: "Roboto-Regular", size: 16)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = tempItems[indexPath.row].fullName + " (\(self.dateFromJSON(tempItems[indexPath.row].dob)))"
       
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MiteModel.sharedInstance().miteItem.fullName = tempItems[indexPath.row].fullName
        MiteModel.sharedInstance().miteItem.dob = tempItems[indexPath.row].dob
        NotificationCenter.default.post(name: Notification.Name("reloadRegion"), object: self)
        self.dismiss(animated: true)
    }
}
