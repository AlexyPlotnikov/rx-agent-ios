//
//  ContainerViewController.swift
//  RXAgent
//
//  Created by RX Group on 22.06.2021.
//  Copyright © 2021 RX Group. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

       fileprivate weak var viewController : UIViewController!
       fileprivate var containerViewObjects = Dictionary<String,UIViewController>()
       var animationDurationWithOptions:(TimeInterval, UIView.AnimationOptions) = (0,[])
       open var currentViewController : UIViewController{
           get {
               return self.viewController
               
           }
       }
       
       
       fileprivate var segueIdentifier : String!
       @IBInspectable internal var firstLinkedSubView : String!
       
       
       override open func viewDidLoad() {
           super.viewDidLoad()
           
       }
    
       open override func viewDidAppear(_ animated: Bool) {
           if let identifier = firstLinkedSubView{
               segueIdentifierReceivedFromParent(identifier)
           }
       }
       
       func segueIdentifierReceivedFromParent(_ identifier: String){
           self.segueIdentifier = identifier
           self.performSegue(withIdentifier: self.segueIdentifier, sender: nil)
           
       }
       
       
       
       
       override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == segueIdentifier{
               if viewController != nil{
                   viewController.view.removeFromSuperview()
                   viewController = nil
                   
               }
               if ((self.containerViewObjects[self.segueIdentifier] == nil)){
                   viewController = segue.destination
                   self.containerViewObjects[self.segueIdentifier] = viewController
                   
               }else{
                   for (key, value) in self.containerViewObjects{
                       if key == self.segueIdentifier{
                           viewController = value
                       }
                   }
                   
               }
               UIView.transition(with: self.view, duration: animationDurationWithOptions.0, options: animationDurationWithOptions.1, animations: {
                   self.addChild(self.viewController)
                   self.viewController.view.frame = CGRect(x: 0,y: 0, width: self.view.frame.width,height: self.view.frame.height)
                   self.view.addSubview(self.viewController.view)
               }, completion: { (complete) in
                   self.viewController.didMove(toParent: self)
               })
              
              
               
           }
           
       }

}
