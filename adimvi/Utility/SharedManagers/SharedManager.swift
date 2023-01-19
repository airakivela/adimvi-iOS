
//  SharedManager.swift
//  Fleet Management
//  Created by iMac on 01/11/17.
//  Copyright © 2017 iMac. All rights reserved.

import UIKit

let objActivity = activityIndicator()
class SharedManager: NSObject {
    var UserName:String!
    var arrayEditProfie = [[String: Any]]()
    var otherProfile:String!
    var EditComment:String!
    var PostId:String!
    var DeviceToken:String!
    var ScrollStatus:String!
    var hearticon:String!
    var SalesNotify:String!
    
    var TagList = 1
    
    //MARK:- Create Instance Variable for SingleTon Classes
    class var sharedInstance: SharedManager {
        struct Static {
            static let instance: SharedManager = SharedManager()
        }
        return Static.instance
    }
    
    //MARK:- Set current login user data
    
    func setUserInfo(dictObject: Dictionary<String, Any>)  {
        let defaultUser = UserDefaults.standard
        let encodedData : Data = NSKeyedArchiver.archivedData(withRootObject: dictObject)
        defaultUser.set(encodedData, forKey: "USER_DATA")
        defaultUser.synchronize()
    }
    
    //MARK:- Get current login user data
    func dictUserInfo() -> Dictionary<String, Any>  {
        let defaultUser = UserDefaults.standard
        if(UserDefaults.standard.object(forKey: "USER_DATA") == nil) {
            let dict = Dictionary<String, Any>()
            print(dict.keys.count)
            return dict
        } else {
            let encodedData : Data = defaultUser.object(forKey: "USER_DATA") as! Data
            guard  let tempDict : Dictionary<String, Any> = NSKeyedUnarchiver.unarchiveObject(with: encodedData) as? Dictionary<String, Any> else {
                let dict = Dictionary<String, Any>()
                print(dict.keys.count)
                return dict
            }
            return tempDict
        }
    }
    
    //MARK:- Clear current login user data
    func  resetAllData()  {
        let defaultUser = UserDefaults.standard
        defaultUser.set(nil, forKey: "USER_DATA")
        defaultUser.synchronize()
    }
}
