//
//  StoriesController.swift
//  RXAgent
//
//  Created by RX Group on 09.03.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit

class StoriesController: UIViewController {

    @IBOutlet weak var progressBar: StoriesProgress!
    @IBOutlet weak var storiesImage: UIImageView!
    @IBOutlet weak var storiesTitle: UILabel!
    @IBOutlet weak var storiesDescription: UITextView!
    var stories:[Pages]!
    let storiesSpeed:Double = 1/60
    let storiesTime:Double = 5
    var timer : Timer?
    var runCount = 0.0
    var numberStories = 0
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.backgroundColor = .clear
        self.setupStories(index: numberStories)
        self.startTimer()
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        longPressRecognizer.minimumPressDuration = 0.2
        self.view.addGestureRecognizer(longPressRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        progressBar.countProgress = stories.count
        
        storiesDescription.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setGradientBackground()
        
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: storiesSpeed, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    @objc func tapped(sender: UITapGestureRecognizer){
        let midX = self.view.frame.size.width/2
        if(sender.location(in: self.view).x < midX){
            self.leftAction()
        }else{
            self.rightAction()
        }
        
    }
    
    func leftAction(){
            if(self.timer != nil){
                self.timer?.invalidate()
                self.timer = nil
            }
            self.progressBar.setProgressLine(index: numberStories, progress: 0, animated: false)
            if(numberStories != 0){
                numberStories -= 1
            }else{
                numberStories = 0
            }
            self.progressBar.setProgressLine(index: numberStories, progress: 0, animated: false)
            runCount = 0
            self.setupStories(index: numberStories)
            self.startTimer()
        
    }
    
    func rightAction(){
        if(numberStories != self.stories.count){
            self.progressBar.setProgressLine(index: numberStories, progress: 1, animated: false)
            numberStories += 1
            runCount = 0
            self.setupStories(index: numberStories)
        }
    }
    
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state != .ended {
            if(self.timer != nil){
                self.timer?.invalidate()
                self.timer = nil
            }
        }else{
            if(timer == nil){
                self.startTimer()
            }
        }
        
    }
    
    @objc func updateCounter(){
        runCount += self.storiesSpeed
        if(numberStories == self.stories.count){
            if(timer != nil){
                timer?.invalidate()
                timer = nil
                }
            self.dismiss( animated: true)
        }else{
            if runCount >= self.storiesTime {
                numberStories += 1
                runCount = 0
                self.setupStories(index: numberStories)
            }else{
                self.progressBar.setProgressLine(index: numberStories, progress: Double(runCount)/storiesTime)
            }
        }
    }
    
    func setupStories(index:Int){
        if(self.stories.count > 0 && index < self.stories.count){
            let storie = self.stories[index]
            let url = URL(string: storie.imageNews )
            self.storiesImage.sd_setImage(with: url, placeholderImage: nil, options: [.continueInBackground,.progressiveLoad,.refreshCached], completed: {_,_,_,_ in 
                self.storiesTitle.text = storie.title
                self.storiesDescription.text = storie.description
            })
            
            
            
        }
    }
    
    
    @IBAction func close(_ sender: Any) {
        self.dismiss( animated: true)
    }
    

    func setGradientBackground() {
        let colorTop =  UIColor(red: 133/255.0, green: 68/255.0, blue: 139/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 54/255.0, green: 36/255.0, blue: 68/255.0, alpha: 1.0).cgColor
                    
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
                
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }

}
