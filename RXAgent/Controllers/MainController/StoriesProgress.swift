//
//  StoriesProgress.swift
//  RXAgent
//
//  Created by RX Group on 09.03.2022.
//  Copyright © 2022 RX Group. All rights reserved.
//

import UIKit

class StoriesProgress: UIView {
    var countProgress:Int = 2{
        didSet{
            setNeedsDisplay()
        }
    }
    
    private var progressArray:[UIProgressView] = []

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.createProgress()
    }
    
    func createProgress(){
       
        for view in self.subviews{
            view.removeFromSuperview()
            progressArray = []
        }
        
        for i in 0..<countProgress{
            let newWidth = self.frame.size.width / Double(countProgress)-5
            let progress = UIProgressView(frame: CGRect(x: Double(i) * (newWidth + 5), y: 0, width: newWidth, height: 3))
            progress.setProgress(0, animated: false)
            progress.progressTintColor = .white
            self.addSubview(progress)
            progressArray.append(progress)
        }
       
    }
    
    func setProgressLine(index:Int, progress:Double,animated:Bool = true){
        if(progressArray.count > 0){
            progressArray[index].setProgress(Float(progress), animated: animated)
        }
    }
}
