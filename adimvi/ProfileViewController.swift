
//  ProfileViewController.swift
//  adimvi
//  Created by javed carear  on 22/08/19.
//  Copyright © 2019 webdesky.com. All rights reserved.


import UIKit
import Alamofire
import SDWebImage
import XLPagerTabStrip
class ProfileViewController: UIViewController {
    @IBOutlet weak var textviewAboutMe: UITextView!
    @IBOutlet weak var labelSocialNetwork: UILabel!
    @IBOutlet weak var labelDecription: UILabel!
    
    @IBOutlet weak var buttonActividad: UIButton!
    @IBOutlet weak var labelLinkAndWebside: UILabel!
    @IBOutlet weak var labelLocation: UILabel!
    @IBOutlet weak var labelFullname: UILabel!
    @IBOutlet weak var labelRegisterdSince: UILabel!
    @IBOutlet weak var htStackView: NSLayoutConstraint!
    var ProfileType:String!
    var ShareLink:String!
    var userId:String!
    var LoginUser:String!
    var arrayProfile =  [[String: Any]]()
    @IBOutlet weak var buttonprivateMassage: UIButton!
    var pageIndex: Int = 0
    var pageTitle: String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoginUser = UserDefaults.standard.string(forKey: "ID")
        ProfileType = SharedManager.sharedInstance.otherProfile
        
        if  self.ProfileType == "1" {
            self.buttonprivateMassage.isHidden = false
            self.userId = UserDefaults.standard.string(forKey: "OtherUserID")
            
            if self.LoginUser! == self.userId! {
                self.buttonprivateMassage.isHidden = true
            }
            
        }else{
            self.buttonprivateMassage.isHidden = true
            // htStackView.constant = 35
            self.userId = UserDefaults.standard.string(forKey: "ID")
            self.buttonActividad.imageEdgeInsets = UIEdgeInsets(top: 0, left: -200, bottom: 0, right: 0)
        }
        CallWebserviceGetProfile()
        
        
    }
    
    
    
    
    
    @IBAction func OnLink(_ sender: Any) {
        let vc:WebviewTabController = self.storyboard?.instantiateViewController(withIdentifier: "WebviewTabController") as! WebviewTabController
        vc.UrlLink  = "\(ShareLink!)"
        //        vc.Title = "Términos y política de privacidad"
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
        
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CallWebserviceGetProfile()
    }
    
    @IBAction func OnRecentActivity(_ sender: Any) {
    }
    
    @IBAction func OnRecentPublication(_ sender: Any) {
    }
    
    
    @IBAction func OnPrivateMassage(_ sender: Any) {
        let vc: PrivateMessageViewController = self.storyboard?.instantiateViewController(withIdentifier:"PrivateMessageViewController")as!PrivateMessageViewController
        let data = self.arrayProfile[0]
        vc.targetUserName = data["username"] as? String
        vc.targetUserAvatar = data["avatarblobid"] as? String
        if let verifyStr = data["isVerify"] as? String {
            if verifyStr == "1" {
                vc.targetUserVerify = true
            } else {
                vc.targetUserVerify = false
            }
        } else {
            vc.targetUserVerify = false
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func CallWebserviceGetProfile(){
        let Para =
            ["userid":"\(userId!)","login_userid":"\(LoginUser!)"
            ] as [String : Any]
        let myService:String = "\(WebURL.BaseUrl)\(WebURL.getProfile)"
        objActivity.startActivityIndicator()
        Alamofire.request(myService, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [[String:Any]]{
                            self.arrayProfile = arr
                            SharedManager.sharedInstance.arrayEditProfie = arr
                            let data =  self.arrayProfile[0]
                            if let Username = data["name"]as? String{
                                self.labelFullname.text = Username
                            }
                            if let Username = data["created"]as? String{
                                self.labelRegisterdSince.text = Username
                            }
                            if let SocialNet = data["social-networks"]as? String{
                                self.labelSocialNetwork.text = SocialNet
                            }
                            if let webside = data["website"]as? String{
                                self.labelLinkAndWebside.text = webside
                                self.ShareLink = webside
                            }
                            if let AboutMe = data["about"]as? String{
                                self.labelDecription.text = AboutMe
                            }
                            if let AboutMe = data["location"]as? String{
                                self.labelLocation.text = AboutMe
                            }
                            if let UserName = data["username"]as? String{
                                SharedManager.sharedInstance.UserName = UserName
                            }
                            if  self.ProfileType == "1" {
                                if let flags = data["flags"] as? String {
                                    if flags == "4" || flags == "260" || flags == "0" || flags == "256" || flags == "5" || flags == "261"{
                                        self.buttonprivateMassage.isHidden = false
                                    } else {
                                        self.buttonprivateMassage.isHidden = true
                                    }
                                } else {
                                    self.buttonprivateMassage.isHidden = false
                                }
                                self.userId = UserDefaults.standard.string(forKey: "OtherUserID")
                                if self.LoginUser! == self.userId! {
                                    self.buttonprivateMassage.isHidden = true
                                }
                            } else {
                                self.buttonprivateMassage.isHidden = true
                                self.userId = UserDefaults.standard.string(forKey: "ID")
                                self.buttonActividad.imageEdgeInsets = UIEdgeInsets(top: 0, left: -200, bottom: 0, right: 0)
                            }
                        }
                        objActivity.stopActivity()
                    }
                    objActivity.stopActivity()
                    break
                case .failure(_):
                    objActivity.stopActivity()
                    print(response.result.error as Any)
                    break
                }
            }
    }
    
}
extension ProfileViewController: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo.init(title: pageTitle ?? "Tab \(pageIndex)")
    }
}
