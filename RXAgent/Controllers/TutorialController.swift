//
//  TutorialController.swift
//  RXAgent
//
//  Created by RX Group on 08/02/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit
import AudioToolbox

class TutorialController: UIViewController,UIScrollViewDelegate{

    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var pageControll: UIPageControl!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var textView: UITextView!
    var textArray:NSMutableArray = ["В Ленте Вы можете отслеживать статус заявок в реальном времени","В зависимости от статуса, Вы можете управлять заявками и смотреть информацию о них","Вы можете оформить заявку без внесения данных, просто сфотографировав документы","Вы можете управлять своим профилем прямо из приложения"]
    var tutorialImages:NSMutableArray = ["tutor01","tutor02","tutor03","tutor04"]
    var headerArray:NSMutableArray = ["ЛЕНТА","УПРАВЛЕНИЕ ЗАЯВКАМИ","ЗАЯВКА Е-ОСАГО","ПРОФИЛЬ"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gradient = CAGradientLayer()
        gradient.frame = self.view.bounds
        gradient.colors = [UIColorFromRGB(rgbValue: 0x32294C, alphaValue: 1).cgColor, UIColorFromRGB(rgbValue: 0x3B1D37, alphaValue: 1).cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.view.layer.insertSublayer(gradient, at: 0)
       
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.initScroll()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            AudioServicesPlaySystemSound(1519)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        if(Int(pageNumber)<tutorialImages.count && pageNumber>=0){
            self.pageControll.currentPage = Int(pageNumber)
            self.textView.text=self.textArray[Int(pageNumber)] as? String
            self.headerLbl.text=self.headerArray[Int(pageNumber)] as? String
        }
    }
   
    func initScroll(){
        scroll.delegate = self
        scroll.contentSize = CGSize(width: scroll.frame.size.width*4, height: 0)
        textView.text=textArray[0] as? String
        headerLbl.text=headerArray[0] as? String
        for i in 0..<tutorialImages.count{
            let imageView = UIImageView(frame: CGRect(x: scroll.frame.size.width * CGFloat(i), y: scroll.frame.origin.y+10, width: scroll.frame.size.width, height: scroll.frame.size.height))
            imageView.image = UIImage(named: (tutorialImages[i] as? String)!)
            imageView.contentMode = .scaleAspectFit
            scroll.addSubview(imageView)
        }
    }

    @IBAction func closeTutor(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
