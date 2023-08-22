//
//  Helper.swift
//  RXAgent
//
//  Created by RX Group on 02.07.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import Foundation
import UIKit


extension Sequence {
    func groupSort(ascending: Bool = false, byDate dateKey: (Element) -> Date) -> [[Element]] {
        var categories: [[Element]] = []
        for element in self {
            let key = dateKey(element)
            guard let dayIndex = categories.index(where: { $0.contains(where: { Calendar.current.isDate(dateKey($0), inSameDayAs: key) }) }) else {
                guard let nextIndex = categories.index(where: { $0.contains(where: { dateKey($0).compare(key) == (ascending ? .orderedDescending : .orderedAscending) }) }) else {
                    categories.append([element])
                    continue
                }
                categories.insert([element], at: nextIndex)
                continue
            }
            
            guard let nextIndex = categories[dayIndex].index(where: { dateKey($0).compare(key) == (ascending ? .orderedDescending : .orderedAscending) }) else {
                categories[dayIndex].append(element)
                continue
            }
            categories[dayIndex].insert(element, at: nextIndex)
        }
        return categories
    }
}

extension String {
    @discardableResult
    func containsText(of textField: UITextField) -> Bool {
        // Precondition
        guard let text = textField.text else { return false }
        
        let isContained = self.contains(text)
        if isContained { print("\(self) contains \(text)") }
        return isContained
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
         let View = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.height, height: self.frame.size.height))
        let paddingView = UIImageView(frame: CGRect(x: View.frame.size.width/2-7, y: View.frame.size.height/2-7, width: 14, height: 14))
        paddingView.image = UIImage(named: "Search")
        View.addSubview(paddingView)
        self.leftView = View
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func leftPaddingPoints(_ amount:CGFloat){
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
            self.leftView = paddingView
            self.leftViewMode = .always
        }
}

class TextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

extension Float{
    func roundTo(places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return roundf(self * divisor) / divisor
    }
}


extension Date {

    var onlyDate: Date? {
        get {
            let calender = Calendar.current
            var dateComponents = calender.dateComponents([.year, .month, .day], from: self)
            dateComponents.timeZone = NSTimeZone.system
            return calender.date(from: dateComponents)
        }
    }

}

extension UIColor {
  struct StatesColor {
    static var noneColor: UIColor  { return UIColor.init(displayP3Red: 184/255, green: 184/255, blue: 184/255, alpha: 1) }
    static var orangeColor: UIColor { return UIColor.init(displayP3Red: 243/255, green: 162/255, blue: 60/255, alpha: 1) }
    static var redColor: UIColor { return UIColor.init(displayP3Red: 231/255, green: 51/255, blue: 51/255, alpha: 1) }
    static var greenColor: UIColor { return UIColor.init(displayP3Red: 163/255, green: 205/255, blue: 58/255, alpha: 1) }
  }
}

extension UIViewController {

    func registerForKeyboardWillShowNotification(_ scrollView: UIScrollView, bottomInset:CGFloat? = 0, usingBlock block: ((CGSize?) -> Void)? = nil) {
        print("show")
        _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil, using: { notification -> Void in
            let userInfo = notification.userInfo!
            let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
            let contentInsets = UIEdgeInsets(top: scrollView.contentInset.top, left: scrollView.contentInset.left, bottom: keyboardSize.height , right: scrollView.contentInset.right)
            scrollView.setContentInsetAndScrollIndicatorInsets(contentInsets)
            block?(keyboardSize)
        })
    }

    func registerForKeyboardWillHideNotification(_ scrollView: UIScrollView,bottomInset:CGFloat? = 0, usingBlock block: ((CGSize?) -> Void)? = nil) {
        print("hide")
        _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil, using: { notification -> Void in
            let userInfo = notification.userInfo!
            let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
            let contentInsets = UIEdgeInsets(top: scrollView.contentInset.top, left: scrollView.contentInset.left, bottom: bottomInset ?? 0, right: scrollView.contentInset.right)

            scrollView.setContentInsetAndScrollIndicatorInsets(contentInsets)
            block?(keyboardSize)
        })
    }
}

extension UIScrollView {

    func setContentInsetAndScrollIndicatorInsets(_ edgeInsets: UIEdgeInsets) {
        self.contentInset = edgeInsets
        self.scrollIndicatorInsets = edgeInsets
    }
}


extension UIViewController{
    
    func setTap(){
        let tapGestureRecognizer = UITapGestureRecognizer()
            tapGestureRecognizer.addTarget(self, action: #selector(handlerTap))
            tapGestureRecognizer.cancelsTouchesInView=false
            self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handlerTap(){
        self.view.endEditing(true)
    }
    
    func setMessage(_ text:String, rootVC:UIViewController) {
        DispatchQueue.main.async{
            let alertController = UIAlertController(title: "Внимание!", message:
                text , preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
            
            rootVC.present(alertController, animated: true, completion: nil)
        }
    }
}

extension UITextView{
    func addToolBar(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneButtonAction))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spaceButton,doneButton], animated: false)
        self.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonAction(){
            self.resignFirstResponder()
    }
}
