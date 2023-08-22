//
//  DatePTOController.swift
//  RXAgent
//
//  Created by RX Group on 08.07.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import UIKit

class DatePTOController: UIViewController {
    
    var timeArray:[String]{
        return DatePTOModel.sharedInstance().timeArray ?? []
    }
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var emptyTextField:UITextField!
    var picker:UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTimeByDate(date: DatePTOModel.sharedInstance().choosenDate)
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }
    
    func showDataPicker() {
        picker = UIDatePicker()
        picker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        } 
        picker.minimumDate = Date()
        picker.date = DatePTOModel.sharedInstance().choosenDate
        picker.maximumDate = (Calendar.current.date(byAdding: .day, value: 60, to: Date())!)
        picker.locale = NSLocale.init(localeIdentifier: "ru") as Locale
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: UIBarButtonItem.Style.done, target: self, action: #selector(handleDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        emptyTextField = UITextField(frame: .zero)
        emptyTextField.spellCheckingType = .no
        self.view.addSubview(emptyTextField)

        toolbar.setItems([spaceButton,doneButton], animated: false)
        emptyTextField.inputAccessoryView = toolbar
        emptyTextField.inputView = picker
        emptyTextField.becomeFirstResponder()
        }
    
    
    @objc func handleDatePicker() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        DatePTOModel.sharedInstance().choosenDate = picker.date
        DatePTOModel.sharedInstance().choosenTime = ""
        self.loadTimeByDate(date: DatePTOModel.sharedInstance().choosenDate)
        emptyTextField.resignFirstResponder()
    }
    
    func loadTimeByDate(date:Date){
        DatePTOModel.sharedInstance().loadTimeByDate(date: self.getFormatedDate(date: date).0, category: Category.sharedInstance().currentCategoryID) { (ready, timesArray) in
            if(ready){
                self.emptyLbl.isHidden = (timesArray ?? []).count > 0
                self.emptyLbl.text = "На текущую дату нет свободного времени"
                self.collectionView.reloadData()
            }
        }
    }
    
    func getFormatedDate(date:Date)->(String, String){
      
        let dateFormatterForModel = DateFormatter()
        dateFormatterForModel.dateFormat = "yyyy-MM-dd"
        let dateFormatterForTable = DateFormatter()
        dateFormatterForTable.dateFormat = "dd MMMM yyyy"
        
        return (dateFormatterForModel.string(from: date),dateFormatterForTable.string(from: date))
    }
    
    func getMulticolorText(firstText:String, secondText:String) -> NSMutableAttributedString{
        let attrs1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : UIColor.black]
        let attrs2 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : UIColor.init(displayP3Red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)]
        let attributedString1 = NSMutableAttributedString(string:firstText, attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string:secondText, attributes:attrs2)

            attributedString1.append(attributedString2)
            return attributedString1
    }
    
    func checkDay(date:Date)->String{
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "(Сегодня)" }
        else if calendar.isDateInTomorrow(date) { return "(Завтра)" }else{
            return ""
        }
    }
    
}

extension DatePTOController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.timeArray.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(indexPath.row == 0){
            let cell:DatePTOCell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell", for: indexPath) as! DatePTOCell
            cell.dateLbl.attributedText = self.getMulticolorText(firstText: self.getFormatedDate(date: DatePTOModel.sharedInstance().choosenDate).1, secondText: " " + self.checkDay(date: DatePTOModel.sharedInstance().choosenDate))
            
            return cell
        }else{
            let cell:DatePTOCell = collectionView.dequeueReusableCell(withReuseIdentifier: "timeCell", for: indexPath) as! DatePTOCell
            cell.timeLbl.text = self.timeArray[indexPath.row-1]
            cell.checkState()
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            self.showDataPicker()
        }else{
            DatePTOModel.sharedInstance().choosenTime = self.timeArray[indexPath.row-1]
            let cell = collectionView.cellForItem(at: indexPath) as! DatePTOCell
            cell.checkState()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! DatePTOCell
        cell.checkState()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var widthCell : CGFloat = 0
        var heightCell : CGFloat = 0
        
        if(indexPath.row == 0){
            widthCell = collectionView.bounds.size.width - 16
            heightCell = 60
        }else{
            widthCell = collectionView.bounds.size.width / 4 - 12
            heightCell = 60
        }
      
        return CGSize(width: widthCell, height: heightCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    


}
