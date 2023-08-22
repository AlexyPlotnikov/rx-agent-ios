//
//  RXServerConnector.swift
//  AbieSystem
//
//  Created by RX Group on 28/12/2018.
//  Copyright © 2018 RX Group. All rights reserved.
//

import Foundation
import UIKit

var movieData = [String: Any]()


var taskArray:[CustomTask] = []


class RXServerConnector: NSObject,URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    static let sharedInstance = RXServerConnector()
    
    func uploadImage(URLString:String, image:UIImage, index:Int, itemIndex:Int, name: NSString, completion:@escaping (Dictionary<String, Any>, Int, Int)->Void) {
        refreshToken(completion: {
        let myUrl = NSURL(string: URLString)
        var request = URLRequest(url:myUrl! as URL)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let imageData = image.jpegData(compressionQuality: 0.1)
        
        if(imageData==nil)  { return }
        
        request.httpBody = createBodyWithParameters( filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary, filename: name as String) as Data
        let opQueue = OperationQueue()
        opQueue.isSuspended = true
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.urlCache = nil
        
        let session: URLSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request, completionHandler:  {(data, response, error) in
            guard let data = data else { return }
            do {
                let newItem = taskArray.filter{$0.session == session}
                movieData  =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                completion(movieData, newItem[0].index, newItem[0].itemIndex)
                
                if let index = taskArray.firstIndex(of: newItem[0]) {
                    taskArray.remove(at: index)
                }
             
              
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        })
       
       taskArray.append(CustomTask(index: index, session: session,itemIndex: itemIndex))
       task.resume()
        })
    }
    
}

func refreshToken(controller:UIViewController? = nil,completion:@escaping ()->Void){
    do {
        let jwt = try decode(jwt: token)
        let expDate = Date(timeIntervalSince1970: (TimeInterval(jwt.body["exp"] as! Int)))
        
        if(expDate <= Date()){
            let bodyStr = "grant_type=refresh_token&client_id=b2b.app.ios&refresh_token=\(refresh_token)"
                postLoginRequest(URLString: "https://accounts.rx-agent.ru/connect/token", body: bodyStr, completion: {
                    result in
                    if((result["error"] as? String) == nil){
                        DispatchQueue.main.async {
                            token = result["access_token"] as! String
                            refresh_token = result["refresh_token"] as! String
                            UserDefaults.standard.set(token, forKey: "token")
                            UserDefaults.standard.set(refresh_token, forKey: "refresh_token")
                            completion()
                        }
                    }else{
                        if let savedArray = UserDefaults.standard.object(forKey: "loginPair") as? [String:Any] {
                           
                            let bodyStr = "grant_type=password&client_id=b2b.app.ios&scope=openid profile b2b.api offline_access&username=\(savedArray["login"] as! String)&password=\(savedArray["password"] as! String)"
                                
                                postLoginRequest(URLString: "https://accounts.rx-agent.ru/connect/token", body: bodyStr, completion: {
                                    result in
                                       //             print(result)
                                    token = result["access_token"] as! String
                                    refresh_token = result["refresh_token"] as! String
                                    UserDefaults.standard.set(token, forKey: "token")
                                    UserDefaults.standard.set(refresh_token, forKey: "refresh_token")
                                    completion()
                                })
                        }else{
                           
                            completion()
                        }
                        
                    }
                })
        }else{
         
            completion()
        }

    } catch  {

    }
}

func postLoginRequest(URLString:String,body:String, completion:@escaping (_ array: [String:Any])->Void) {
 
    let myURL = NSURL(string: URLString)!
    let request = NSMutableURLRequest(url: myURL as URL)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.httpBody = body.data(using: .utf8)
       
      
       let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
           
           guard let data = data else { return }
           do {
               movieData  =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
               completion(movieData)
           } catch let error as NSError {
               
               print(error)
           }
       })
       
       task.resume()

}

func getPatchRequest(URLString:String, completion:@escaping (Dictionary<String, Any>)->Void) {
    refreshToken(completion: {
    var request = URLRequest(url: NSURL(string: URLString)! as URL)
    if !token.isEmpty {
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PATCH"
    }
    
    let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
        guard let data = data else { return }
        do {
            
            movieData  =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
            completion(movieData)
            
        } catch let error as NSError {
            print(error)
        }
    })
    
    task.resume()
    })
}


func getRequest(URLString:String, needSecretKey:Bool = false, completion:@escaping (Dictionary<String, Any>)->Void) {
    refreshToken(completion: {
        var request = URLRequest(url: NSURL(string: URLString)! as URL)
        if !token.isEmpty {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            if(needSecretKey){
                request.addValue("1cdb8148-69ac-47a3-85f3-5440e85cbd5f", forHTTPHeaderField: "x-api-key")
            }
            request.httpMethod = "GET"
        }
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 300.0
        sessionConfig.timeoutIntervalForResource = 600.0
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
           
            guard let data = data else { return }
          
            if let movieData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any] {
              
                        completion(movieData)
            }else{
                completion(["error":"401"])
            }
                
            
        })
        
        task.resume()
    })
}

func deleteRequest(URLString:String, completion:@escaping (Dictionary<String, Any>)->Void) {
    refreshToken(completion: {
        print(URLString)
        var request = URLRequest(url: NSURL(string: URLString)! as URL)
        if !token.isEmpty {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "DELETE"
        }
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 300.0
        sessionConfig.timeoutIntervalForResource = 600.0
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
           
            guard let data = data else { return }
          
            if let movieData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any] {
              
                        completion(movieData)
            }else{
                completion(["error":"401"])
            }
                
            
        })
        
        task.resume()
    })
}

func getArrayRequest(URLString:String, needSecretKey:Bool = false, completion:@escaping (_ array: NSArray)->Void) {
    refreshToken(completion: {
    print(URLString)
    var request = URLRequest(url: NSURL(string: URLString)! as URL)
        request.httpMethod = "GET"
    if(needSecretKey){
        request.addValue("1cdb8148-69ac-47a3-85f3-5440e85cbd5f", forHTTPHeaderField: "x-api-key")
    }

    let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
         guard let data = data else { return }
           do {
            if let GETdata  =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSArray{
                completion(GETdata)
            }else{
                completion([])
            }
           
             
           } catch  {
            print(error.localizedDescription)
           completion([])
       }
    })
    
    task.resume()
    })
}



func postReq(URLString:String, completion:@escaping (Dictionary<String, Any>)->Void) {
    refreshToken(completion: {
    var request = URLRequest(url: NSURL(string: URLString)! as URL)
    if !token.isEmpty {
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
    }
    
    let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
        
        guard let data = data else { return }
        do {
            movieData  =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
            
            completion(movieData)
            
            
        } catch let error as NSError {
            if let httpResponse = response as? HTTPURLResponse {
                if(httpResponse.statusCode == 401){
                    
                    completion(["error":"401"])
                }
            }
            print(error)
        }
    })
    
    task.resume()
    })
}

func postRequest(JSON:[String: Any], URLString:String, needSecretKey:Bool = false, completion:@escaping (Dictionary<String, Any>)->Void) {
    refreshToken(completion: {
    var request = URLRequest(url: NSURL(string: URLString)! as URL)
    if(needSecretKey){
        request.addValue("1cdb8148-69ac-47a3-85f3-5440e85cbd5f", forHTTPHeaderField: "x-api-key")
    }else{
        if !token.isEmpty {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
    request.httpMethod = "POST"
  
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: JSON, options: .prettyPrinted)
    } catch let error {
        print(error.localizedDescription)
    }
        
 
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
   
    let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
        
        guard let data = data else {
            return
        }
        do {
            if let GETdata  =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]{
                 completion(GETdata)
            }else{
                let GETdata  =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! String
                completion(["id":GETdata])
                
            }
        } catch {
            if let httpResponse = response as? HTTPURLResponse {
                if(httpResponse.statusCode == 200){

                    completion([:])
                }
            }
        }
        
    })
    
    task.resume()
    })
}
func postPaymentRequest(JSON:String,needAuth:Bool = false, URLString:String, completion:@escaping (Dictionary<String, Any>)->Void) {
    refreshToken(completion: {
    var request = URLRequest(url: NSURL(string: URLString)! as URL)
   
        if !token.isEmpty && needAuth {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
       
    request.httpMethod = "POST"
    request.httpBody = JSON.data(using: .utf8)
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
  
    let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
        
        guard let data = data else {
            
            return
        }
     
            if let GETdata  =  try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]{
                 completion(GETdata!)
            }else{
                if let GETdata  =  try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? String {
                    completion(["id":GETdata!])
                }else{
                    let contents = String(data: data, encoding: .ascii)
                    completion(["html":contents!])
                }
               
                
            }
//        } catch {
//            if let httpResponse = response as? HTTPURLResponse {
//                if(httpResponse.statusCode == 200){
//                     let theJSONData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
//                       print(theJSONData)
//
//                    completion([:])
//                }
//            }
//        }
        
    })
    
    task.resume()
    })
}


func putRequest(JSON:[String: Any], URLString:String, completion:@escaping (Dictionary<String, Any>)->Void){
    refreshToken(completion: {
    var request = URLRequest(url: NSURL(string: URLString)! as URL)
    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "PUT"
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: JSON, options: .prettyPrinted)
    } catch let error {
        print(error.localizedDescription)
    }
    
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
        
        guard let data = data else { return }
        do {
            movieData  =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
            completion(movieData)
        } catch let error as NSError {
            
            print(error)
        }
    })
    
    task.resume()
    })
}



func createBodyWithParameters(filePathKey: String?, imageDataKey: NSData, boundary: String, filename: String) -> NSData {
    let body = NSMutableData();
    let mimetype = "image/jpg"
    
    body.appendString(string: "--\(boundary)\r\n")
    body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
    body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
    body.append(imageDataKey as Data)
    body.appendString(string: "\r\n")
    
    
    
    body.appendString(string: "--\(boundary)--\r\n")
    
    return body
}



func generateBoundaryString() -> String {
    return "Boundary-\(NSUUID().uuidString)"
}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}


fileprivate extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(obj: Element) {
        if let index = firstIndex(of: obj) {
            remove(at: index)
        }
    }
}
