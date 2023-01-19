
//  AppDelegate.swift
//  adimvi
//  Created by javed carear  on 15/06/19.
//  Copyright © 2019 webdesky.com. All rights reserved.

import UIKit
import CoreData
import Firebase
import FirebaseMessaging
import UserNotifications
import FirebaseAuth
import FirebaseInstanceID
import IQKeyboardManagerSwift
import Alamofire
import SwiftyJSON

var isClickedNotification: Bool = false
var isClickedSaleNotification: Bool = false
var isClickNewPostNotification: Bool = false
var isClickFollowRoom: Bool = false

var allMentionUsers: [UserModel] = [UserModel]()
var mentionDataSource: [String] = [String]()

@UIApplicationMain
class AppDelegate: UIResponder,UIApplicationDelegate, MessagingDelegate {
    var navigation = UINavigationController()
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        callOneTimeLogin()
        FirebaseApp.configure()
        Messaging.messaging().isAutoInitEnabled = true
        Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                SharedManager.sharedInstance.DeviceToken  = "\(result.token)"
                if let Userid = UserDefaults.standard.string(forKey: "ID") {
                    let para = [
                        "userid": Userid,
                        "device": "ios",
                        "fcmID": SharedManager.sharedInstance.DeviceToken!
                    ] as [String: Any]
                    
                    let Api: String = "\(WebURL.BaseUrl)\(WebURL.updateFcmDevice)"
                    Alamofire.request(Api, method: .post,parameters:para)
                        .responseJSON { response in
                            switch(response.result) {
                            case .success(_):
                                if response.result.value != nil{
                                    debugPrint(response.result)
                                    
                                }
                                break
                            case .failure(_):
                                print(response.result.error as Any)
                                break
                            }
                        }
                }
            }
        }
        
        //MARK: - FetchAllUsers
        allMentionUsers.removeAll()
        let Api: String = "\(WebURL.BaseUrl)\(WebURL.Fetch_All_Members)"
        Alamofire.request(Api, method: .post,parameters:nil)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if let data = response.result.value {
                        let json = JSON.init(data)
                        let respones = json["response"]
                        let users = respones["search"]
                        for user in users.arrayValue {
                            let userModel = UserModel()
                            userModel.initWithJSON(data: user)
                            allMentionUsers.append(userModel)
                            mentionDataSource.append(userModel.name)
                        }
                    }
                    break
                case .failure(_):
                    print(response.result.error as Any)
                    break
                }
            }
        
        //STPPaymentConfiguration.shared().publishableKey = "pk_live_UrsiLIqmjSW0dPRX11jh9dbI00cJzPcbka"
        if let option = launchOptions {
            let info = option[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any]
            if info != nil {
                let aps = info!["aps"] as? [String: Any]
                let data = aps!["alert"] as? [String: Any]
                let msg = data!["body"] as? String
                if let type = info!["gcm.notification.type"] as? String {
                    if type == "1" {
                        isClickNewPostNotification = true
                    } else if type == "2" {
                        isClickFollowRoom = true
                    }
                } else {
                    if msg!.contains("$") {
                        isClickedSaleNotification = true
                    } else {
                        isClickedNotification = true
                    }
                }
            }
        }
        return true
        
       
        
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "123456")")
        if let token = fcmToken {
            let dataDict:[String: String] = ["token": "\(token)"]
            SharedManager.sharedInstance.DeviceToken = token
            NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        }
        
    }
    private func application(application: UIApplication,
                             didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Messaging.messaging().apnsToken = deviceToken as Data
        
    }
    
//    private func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
//        self.application(application, didReceiveRemoteNotification: userInfo) { (UIBackgroundFetchResult) in
//            addNotificationForNow(body: userInfo["body"] as? String ?? "no body")
//        }
//    }
    
    func callOneTimeLogin() {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        
        let story = UIStoryboard.init(name: "TabViewController", bundle: nil)
        let tabbarVC: TabViewController = story.instantiateViewController(withIdentifier: "TabViewController") as! TabViewController
        navigation.isNavigationBarHidden = true
        let logInVC  = storyBoard.instantiateViewController(withIdentifier:"PageVC") as! PageVC
        if SharedManager.sharedInstance.dictUserInfo().keys.count > 0 {
            let rootVC = UINavigationController.init(rootViewController: logInVC)
            rootVC.isNavigationBarHidden = true
            rootVC.viewControllers = [logInVC, tabbarVC]
            navigation = rootVC
            self.window?.rootViewController = rootVC
            self.window?.makeKeyAndVisible()
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("will resign active")
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("did enter backgorund")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("Did Enter Foreground")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("Applicetion did becomee activve")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("Applicaiton terminatee")
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name:"adimvi")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

@available (iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        if let type = userInfo["gcm.notification.type"] as? String {
            if type == "1" {
                UserDefaults.standard.setValue(true, forKey: "HASNEWPOST")
            }
        }
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let aps = userInfo["aps"] as? [String: Any]
        let data = aps!["alert"] as? [String: Any]
        let msg = data!["body"] as? String
        Messaging.messaging().appDidReceiveMessage(userInfo)
        if let type = userInfo["gcm.notification.type"] as? String {
            if type == "1" {
                NotificationCenter.default.post(name: .didClickNewPost, object: nil)
            } else if type == "2" {
                NotificationCenter.default.post(name: .didClickRoom, object: nil)
            }
        } else {
            if msg!.contains("$") {
                NotificationCenter.default.post(name: .didClickSaleNotification, object: nil)
            } else {
                NotificationCenter.default.post(name: .didClickNotification, object: nil)
            }
        }
        
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler(.noData)
    }
}

extension Notification.Name {
    static let didClickNotification = Notification.Name("ClickNotificaiton")
    static let didClickSaleNotification = Notification.Name("ClickSaleNotification")
    static let didClickNewPost = Notification.Name("ClickNewPostNotificaiton")
    static let didClickRoom = Notification.Name("ClickNewFollowRoom")
    static let didChangePostByFollowUser = Notification.Name("didChangePostByFollowUser")
}

