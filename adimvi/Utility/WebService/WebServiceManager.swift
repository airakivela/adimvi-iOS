
//  WebServiceClass.swift
//  Created by MINDIII on 10/3/17.
//  Copyright © 2017 MINDIII. All rights reserved.
// MARK: - Required things
//  install Alamofire with cocoapods * pod 'Alamofire'
//  install SwiftyJSON with cocoapods * pod 'SwiftyJSON'

import UIKit
import Alamofire
var  strAuthToken : String = ""
let objServiceManager = WebServiceManager.sharedObject()
//let objActivity = ActivityIndicator()
//let objImageLoader = LoaderForImage()
class WebServiceManager: NSObject {
    
    //MARK: - Shared object
    var application = UIApplication.shared
    private static var sharedNetworkManager: WebServiceManager = {
        let networkManager = WebServiceManager()
        return networkManager
    }()
    // MARK: - Accessors
    class func sharedObject() -> WebServiceManager {
        return sharedNetworkManager
    }
    
    func showAlert(message: String = "", title: String , controller: UIWindow) {
        DispatchQueue.main.async(execute: {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let subView = alertController.view.subviews.first!
            let alertContentView = subView.subviews.first!
            alertContentView.backgroundColor = UIColor.gray
            alertContentView.layer.cornerRadius = 20
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(OKAction)
          //  self.application.visibleViewController?.present(alertController, animated: true, completion: nil)
        })
    }
    
      public func requestPost(strURL:String, params : [String:Any], success:@escaping(Dictionary<String,Any> ,Data) ->Void, failure:@escaping (Error) ->Void ) {
      //  objActivity.startActivityIndicator()
        if !NetworkReachabilityManager()!.isReachable{
            self.StopIndicator()
            let app = UIApplication.shared.delegate as? AppDelegate
            let window = app?.window
            self.showAlert(message: "", title: message.noNetwork , controller: window!)
             return
        }
        if UserDefaults.standard.string(forKey:UserDefaults.keys.authToken)==nil {
            strAuthToken=""
        }else{
            strAuthToken=UserDefaults.standard.string(forKey:UserDefaults.keys.authToken)!
        }
        let url = WebURL.BaseUrl+strURL
        Alamofire.request(url, method: .post, parameters: params, headers: nil).responseJSON { responseObject in
            if responseObject.result.isSuccess {
                
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: responseObject.data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    // Session Expire
                    let dict = dictionary as! Dictionary<String, Any>
                    if dict["response_code"] as! Int != 200{
                        if dict["message"] != nil  {
//                            objAppShareData.showAlert(withMessage: dict["message"]  as! String, type:    alertType.bannerDark,on: (self.application.visibleViewController)!)
                             self.StopIndicator()
                             return
                        }
                        if dict["error"] != nil{
//   objAppShareData.showAlert(withMessage: dict["error"]  as! String, type: alertType.bannerDark,on: (UIApplication.shared.visibleViewController)!)
                             self.StopIndicator()
                            return
                        }
                        
                        let msg = dict["result"] as! String
                        if msg == message.invalidToken{
//  objAppShareData.showAlert(withMessage: "", type: alertType.sessionExpire,on:                 (self.application.visibleViewController)!)
                             self.StopIndicator()
                            return
                         }
                    }
                    success(dictionary as! Dictionary<String, Any>, responseObject.data!)
                    print(dictionary)
                    self.StopIndicator()
                }catch{
                }
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
                self.StopIndicator()
            }
        }
    }
    
    public func requestGet(strURL:String, params : [String : AnyObject]?, success:@escaping(Dictionary<String,Any>,Data) ->Void, failure:@escaping (Error) ->Void ) {
        if !NetworkReachabilityManager()!.isReachable{
            self.StopIndicator()
            let app = UIApplication.shared.delegate as? AppDelegate
            let window = app?.window
            self.showAlert(message: "", title: message.noNetwork , controller: window!)
             return
        }
     
        let url = WebURL.BaseUrl+strURL
        _ = [
            "Cache-Control": "no-cache" ]
  
        Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { responseObject in
            
            self.StopIndicator()
            
            if responseObject.result.isSuccess {
                //                let resJson = JSON(responseObject.result.value!)
                //                success(resJson)
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: responseObject.data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    // Session Expire
                    let dict = dictionary as! Dictionary<String, Any>
                    if dict["status"] as! String != "ok"{
//                        let msg = dict["message"] as! String
//                        if msg == message.invalidToken{
//                            self.StopIndicator()
//                            objAppShareData.showAlert(withMessage: "", type: alertType.sessionExpire,on: (self.application.visibleViewController)!)
//                            return
//                        }
                    }
                    success(dictionary as! Dictionary<String, Any>, responseObject.data!)
                    print(dictionary)
                }catch{
                    
                }
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    
    public func uploadMultipartData(strURL:String, params : [String : AnyObject]?, imageData:Data?, fileName:String, key:String, mimeType:String, success:@escaping(Dictionary<String,Any>) ->Void, failure:@escaping (Error) ->Void){
        if !NetworkReachabilityManager()!.isReachable{
            self.StopIndicator()
            let app = UIApplication.shared.delegate as? AppDelegate
            let window = app?.window
            self.showAlert(message: "", title: message.noNetwork , controller: window!)
            
            return
        }
        if UserDefaults.standard.string(forKey:UserDefaults.keys.authToken)==nil {
            strAuthToken=""
        }else{
            strAuthToken=UserDefaults.standard.string(forKey:UserDefaults.keys.authToken)!
        }
        let url = WebURL.BaseUrl+strURL
        let headers = ["authtoken" : strAuthToken]
        //  "Content-Type":"Application/json"]
        Alamofire.upload(multipartFormData:{ multipartFormData in
            if let data = imageData{
                multipartFormData.append(data,
                                         withName:key,
                                         fileName:fileName,
                                         mimeType:mimeType)
            }
            for (key, value) in params! {
                multipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }},
                         usingThreshold:UInt64.init(),
                         to:url,
                         method:.post,
                         headers:headers,
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { responseObject in
                                    self.StopIndicator()
                                    if responseObject.result.isSuccess {
                                        //                                        let resJson = JSON(responseObject.result.value!)
                                        //                                        success(resJson)
                                        do {
                                            let dictionary = try JSONSerialization.jsonObject(with: responseObject.data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                                            // Session Expire
                                            let dict = dictionary as! Dictionary<String, Any>
                                            if dict["status"] as! String != "success"{
                                                let msg = dict["message"] as! String
                                                if msg == message.invalidToken{
//                                                    objAppShareData.showAlert(withMessage: "", type: alertType.sessionExpire,on: (self.application.visibleViewController)!)
                                                    return
                                                }
                                            }
                                            success(dictionary as! Dictionary<String, Any>)
                                            print(dictionary)
                                        }catch{
                                        }
                                    }
                                    if responseObject.result.isFailure {
                                        let error : Error = responseObject.result.error!
                                        failure(error)
                                    }
                                }
                            case .failure(let encodingError):
                                print(encodingError)
                                self.StopIndicator()
                                failure(encodingError)
                            }
              })
    }
    
    public func requestPostMultipartData(strURL:String, params : [String:Any], success:@escaping(Dictionary<String,Any>) ->Void, failure:@escaping (Error) ->Void ) {
        if !NetworkReachabilityManager()!.isReachable{
            self.StopIndicator()
            let app = UIApplication.shared.delegate as? AppDelegate
            let window = app?.window
            self.showAlert(message: "", title: message.noNetwork ,controller: window!)
            return
        }
        if UserDefaults.standard.string(forKey:UserDefaults.keys.authToken)==nil {
            strAuthToken=""
        }else{
            strAuthToken=UserDefaults.standard.string(forKey:UserDefaults.keys.authToken)!
        }
        let url = WebURL.BaseUrl+strURL
        let headers = ["authtoken" : strAuthToken,
                       "Content-Type":"multipart/form-data"]
        Alamofire.upload(multipartFormData:{ multipartFormData in
            
            for (key, value) in params {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }},
                         // usingThreshold:UInt64.init(),
            to:url,
            method:.post,
            headers:headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { responseObject in
                        self.StopIndicator()
                        if responseObject.result.isSuccess {
                            //                                        let resJson = JSON(responseObject.result.value!)
                            //                                        success(resJson)
                            do {
                                let dictionary = try JSONSerialization.jsonObject(with: responseObject.data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                                // Session Expire
                                let dict = dictionary as! Dictionary<String, Any>
                                if dict["status"] as! String != "success"{
                                    let msg = dict["message"] as! String
                                    if msg == message.invalidToken{
//   objAppShareData.showAlert(withMessage: "", type: alertType.sessionExpire,on: (self.application.visibleViewController)!)
                                        return
                                    }
                                }
                                success(dictionary as! Dictionary<String, Any>)
                                print(dictionary)
                            }catch{
                            }
                        }
                        if responseObject.result.isFailure {
                            let error : Error = responseObject.result.error!
                            failure(error)
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                    self.StopIndicator()
                    failure(encodingError)
                }
        })
    }
    //MARK : -  Return Json Methods
    public func requestPostForJson(strURL:String, params : [String:Any], success:@escaping(Dictionary<String,Any>) ->Void, failure:@escaping (Error) ->Void ) {
        
        if !NetworkReachabilityManager()!.isReachable{
            self.StopIndicator()
            let app = UIApplication.shared.delegate as? AppDelegate
            let window = app?.window
            self.showAlert(message: "", title: message.noNetwork , controller: window!)
            
            return
        }
        
        if UserDefaults.standard.string(forKey:UserDefaults.keys.authToken)==nil {
            strAuthToken=""
        }else{
            strAuthToken=UserDefaults.standard.string(forKey:UserDefaults.keys.authToken)!
        }
        let url = WebURL.BaseUrl+strURL
        let headers = ["authtoken" : strAuthToken]
        //"Content-Type":"multipart/form-data"]
        
        Alamofire.request(url, method: .post, parameters: params, headers: headers).responseJSON { responseObject in
            self.StopIndicator()
            if responseObject.result.isSuccess {
                let convertedString = String(data: responseObject.data!, encoding: String.Encoding.utf8) // the data will be converted to the string
                let dict = self.convertToDictionary(text: convertedString!)
                if dict!["status"] as! String != "success"{
                    let msg = dict!["message"] as! String
                    if msg == message.invalidToken{
//                        objAppShareData.showAlert(withMessage: "", type: alertType.sessionExpire,on:              (self.application.visibleViewController)!)
                        return
                    }
                }
                success(dict!)
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    
    // Return Json Methods
    public func requestGetForJson(strURL:String, params : [String:Any], success:@escaping(Dictionary<String,Any>) ->Void, failure:@escaping (Error) ->Void ) {
        
        if !NetworkReachabilityManager()!.isReachable{
            self.StopIndicator()
            let app = UIApplication.shared.delegate as? AppDelegate
            let window = app?.window
            self.showAlert(message: "", title: message.noNetwork , controller: window!)
            
            return
        }
        
        if UserDefaults.standard.string(forKey:UserDefaults.keys.authToken)==nil {
            strAuthToken=""
        }else{
            strAuthToken=UserDefaults.standard.string(forKey:UserDefaults.keys.authToken)!
        }
        let url = WebURL.BaseUrl+strURL
        let headers = ["authtoken" : strAuthToken]
        //"Content-Type":"multipart/form-data"]
        
        Alamofire.request(url, method: .get, parameters: params, headers: headers).responseJSON { responseObject in
            self.StopIndicator()
            if responseObject.result.isSuccess {
                let convertedString = String(data: responseObject.data!, encoding: String.Encoding.utf8) // the data will be converted to the string
                let dict = self.convertToDictionary(text: convertedString!)
                if dict!["status"] as! String != "success"{
                    let msg = dict!["message"] as! String
                    if msg == message.invalidToken{
//                        objAppShareData.showAlert(withMessage: "", type: alertType.sessionExpire,on:          (self.application.visibleViewController)!)
                        return
                    }
                }
                success(dict!)
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    
    //MARK: - mathod without indicators
    public func requestPostWithOutIndicator(strURL:String, params : [String:Any], success:@escaping(Dictionary<String,Any>) ->Void, failure:@escaping (Error) ->Void ) {
        
        if !NetworkReachabilityManager()!.isReachable{
            self.StopIndicator()
            let app = UIApplication.shared.delegate as? AppDelegate
            let window = app?.window
            self.showAlert(message: "", title: message.noNetwork , controller: window!)
            
            return
        }
        
        if UserDefaults.standard.string(forKey:UserDefaults.keys.authToken)==nil {
            strAuthToken=""
        }else{
            strAuthToken=UserDefaults.standard.string(forKey:UserDefaults.keys.authToken)!
        }
        let url = WebURL.BaseUrl+strURL
        let headers = ["authtoken" : strAuthToken]
        //"Content-Type":"multipart/form-data"]
        
        Alamofire.request(url, method: .post, parameters: params, headers: headers).responseJSON { responseObject in
            if responseObject.result.isSuccess {
                let convertedString = String(data: responseObject.data!, encoding: String.Encoding.utf8) // the data will be converted to the string
                let dict = self.convertToDictionary(text: convertedString!)
                if dict!["status"] as! String != "success"{
                    let msg = dict!["message"] as! String
                    if msg == message.invalidToken{
//                        objAppShareData.showAlert(withMessage: "", type: alertType.sessionExpire,on: (self.application.visibleViewController)!)
                        return
                    }
                }
                success(dict!)
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    //MARK: - Convert String to Dict
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func isNetworkAvailable() -> Bool{
        if !NetworkReachabilityManager()!.isReachable{
            return false
        }else{
            return true
        }
    }
    func StartIndicator(){
      //  objActivity.startActivityIndicator()
    }
    func StopIndicator(){
     //   objActivity.stopActivity()
    }
}
