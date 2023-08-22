//
//  AppDelegate.swift
//  RXAgent
//
//  Created by RX Group on 24/01/2019.
//  Copyright © 2019 RX Group. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import YandexMobileMetrica


var token: String = ""
var isTechnicalSupport = false
var deviceToken:String = ""
var refresh_token = ""
var domain: String = "https://api.rx-agent.ru/"
var newDomain = "https://master-pto.rx-agent.ru"
var reachability = Reachability()!
var isLoggedIn = false

struct SmartCamera:Codable{
    var isChecked:Bool = true
    var needCamera:Bool = false
    var needSmart:Bool = false
}

var cmartCamera = SmartCamera()
var isReach = true

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UITabBarControllerDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var noIinternet:NoInternetView!
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        

        let configuration = YMMYandexMetricaConfiguration.init(apiKey: "f2580103-bbfa-4184-99ad-98f8d8b03007")
            YMMYandexMetrica.activate(with: configuration!)
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "kbmItems")
        if let savedPerson = defaults.object(forKey: "smart") as? Data {
            let decoder = JSONDecoder()
            if let loadedPerson = try? decoder.decode(SmartCamera.self, from: savedPerson) {
                do{
                    cmartCamera = loadedPerson
                }catch{
                    
                }
            }
        }
        
       
        if(!UserDefaults.standard.bool(forKey: "reloaded")){
            UserDefaults.standard.set(true, forKey: "reloaded")
            cmartCamera = SmartCamera()
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(cmartCamera) {
               let defaults = UserDefaults.standard
               defaults.set(encoded, forKey: "smart")
            }
        }
        
        reachability.whenReachable = { reachability in
            self.noIinternet.isHidden = true
        }
        reachability.whenUnreachable = { _ in
            let name = Notification.Name(rawValue: "closeFaceID")
            NotificationCenter.default.post(name: name, object: nil, userInfo:nil)
            self.window?.endEditing(true)
            self.noIinternet.frame = self.window!.frame
            self.window!.bringSubviewToFront(self.noIinternet)
            self.noIinternet.isHidden = false
            self.noIinternet.setImage(isTechnicalError: false)
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        UIApplication.shared.isIdleTimerDisabled = true
        self.window = UIWindow(frame: UIScreen.main.bounds)
        noIinternet = NoInternetView(frame: window!.bounds)
        window?.addSubview(noIinternet)
        noIinternet.isHidden = true
        
        FirebaseApp.configure()
        Messaging.messaging().isAutoInitEnabled = true
        registerForPushNotifications(app: application)
        
        
        
      
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            token = UserDefaults.standard.string(forKey: "token") ?? ""
            refresh_token = UserDefaults.standard.string(forKey: "refresh_token") ?? ""

            var initialViewController = storyboard.instantiateViewController(withIdentifier: "FaceID")

            if(token.isEmpty){
                initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")
            }
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            let Tcontroller = self.window?.rootViewController as? UITabBarController
                Tcontroller?.tabBar.unselectedItemTintColor = UIColor.lightGray
            
            let ref = Database.database().reference().child("technicalError")
            ref.observe(.value, with: { snapshot in
                self.noIinternet.frame = self.window!.frame
                self.window!.bringSubviewToFront(self.noIinternet)
                self.noIinternet.isHidden = !(snapshot.value as! Bool)
                self.noIinternet.setImage(isTechnicalError: (snapshot.value as! Bool))
                isTechnicalSupport = (snapshot.value as! Bool)
                if(isTechnicalSupport){
                    let name = Notification.Name(rawValue: "closeFaceID")
                    NotificationCenter.default.post(name: name, object: nil, userInfo:nil)
                }
            })
        
        return true
    }

  
    func registerForPushNotifications(app: UIApplication) {
           UNUserNotificationCenter.current().delegate = self
           Messaging.messaging().delegate = self
          

           let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
           UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (authorized, error) in
               if let error = error {
                   print(error.localizedDescription)
                   return
               }
               if authorized {
                   print("authorized")
                   DispatchQueue.main.async {
                     UIApplication.shared.registerForRemoteNotifications()
                   }
               } else {
                   print("denied")
               }
           }
           app.registerForRemoteNotifications()
       }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is AddNavigationController{
            if let newVC = tabBarController.storyboard?.instantiateViewController(withIdentifier: "addVC") {
                tabBarController.present(newVC, animated: true)
              return false
            }
        }
        return true
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        
        completionHandler(UNNotificationPresentationOptions.alert)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if(isLoggedIn){
            if(!["id":userInfo["id"] as? String ?? ""].isEmpty){
                let name = Notification.Name(rawValue: "openOsago")
                NotificationCenter.default.post(name: name, object: nil, userInfo:["id":userInfo["id"] as? String ?? ""])
            }
        }else{
            if(!["id":userInfo["id"] as? String ?? ""].isEmpty){
                let name = Notification.Name(rawValue: "openOsagoFaceID")
                NotificationCenter.default.post(name: name, object: nil, userInfo:["id":userInfo["id"] as? String ?? ""])
            }
        }
//        switch UIApplication.shared.applicationState {
//        case .active:
//            print("Received push message from APNs on Foreground")
//           
//        case .background:
//            let name = Notification.Name(rawValue: "openOsago")
//            NotificationCenter.default.post(name: name, object: nil, userInfo:["id":userInfo["id"] as? String ?? ""])
//            print("Received push message from APNs on Background")
//        case .inactive:
//            print("Received push message from APNs back to Foreground")
//            let name = Notification.Name(rawValue: "openOsago")
//            NotificationCenter.default.post(name: name, object: nil, userInfo:["id":userInfo["id"] as? String ?? ""])
//        }

        completionHandler(.newData)
    }
 
}

extension AppDelegate:MessagingDelegate{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")
      deviceToken = fcmToken ?? ""
      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
      
    }

   
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }


}


