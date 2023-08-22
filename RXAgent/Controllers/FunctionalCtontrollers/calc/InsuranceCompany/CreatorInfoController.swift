//
//  CreatorInfoController.swift
//  RXAgent
//
//  Created by RX Group on 09.06.2020.
//  Copyright © 2020 RX Group. All rights reserved.
//

import UIKit

class CreatorInfoController: UIViewController,UITextViewDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneField: JMMaskTextField!
    @IBOutlet weak var commentView: UITextView!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColorFromRGB(rgbValue: 0x8E8E93, alphaValue: 0.8),
            NSAttributedString.Key.font : UIFont(name: "Roboto-Regular", size: 15)! // Note the !
        ]
        
        nameField.attributedPlaceholder = NSAttributedString(string: "Укажите Ваше имя", attributes:attributes)
        phoneField.attributedPlaceholder = NSAttributedString(string: "Укажите номер телефона", attributes:attributes)
        let toolbar = UIToolbar()
            toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: UIBarButtonItem.Style.done, target: self, action: #selector(doneField))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            toolbar.setItems([spaceButton,doneButton], animated: false)
        
        phoneField.inputAccessoryView = toolbar
        nameField.delegate = self
        phoneField.delegate = self
        commentView.delegate = self
        commentView.layer.cornerRadius = 10
        commentView.layer.masksToBounds = true
        commentView.layer.borderWidth = 1
        commentView.layer.borderColor = UIColorFromRGB(rgbValue: 0xC7C7CC, alphaValue: 1).cgColor
        commentView.backgroundColor = .white
        commentView.setPlaceholder()
    }
   @objc func doneField(){
        self.view.endEditing(true)
    }

    func textViewDidChange(_ textView: UITextView) {
        textView.checkPlaceholder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        commentAgent = textView.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(textField == phoneField){
            creatorPhone = (textField as! JMMaskTextField).unmaskedText!+string
            if(creatorPhone.count>1){
                creatorPhone.remove(at: creatorPhone.startIndex)
            }
            if(creatorPhone.count>=11){
              creatorPhone.remove(at: creatorPhone.index(before: creatorPhone.endIndex))
            }
        }else{
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            creatorInsurance = currentText.replacingCharacters(in: stringRange, with: string)
        }
        return true
    }

}

extension UITextView{

    func setPlaceholder() {

        let placeholderLabel = UILabel()
        placeholderLabel.text = "Комментарий"
        placeholderLabel.font = UIFont(name: "Roboto-Regular", size: 17)
        placeholderLabel.sizeToFit()
        placeholderLabel.tag = 222
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (self.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColorFromRGB(rgbValue: 0x000000, alphaValue: 0.5)
        placeholderLabel.backgroundColor = .clear
        placeholderLabel.isHidden = !self.text.isEmpty

        self.addSubview(placeholderLabel)
    }

    func checkPlaceholder() {
        let placeholderLabel = self.viewWithTag(222) as! UILabel
        placeholderLabel.isHidden = !self.text.isEmpty
    }

}
