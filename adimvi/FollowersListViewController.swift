//
//  FollowersListViewController.swift
//  adimvi
//
//  Created by javed carear  on 27/08/19.
//  Copyright © 2019 webdesky.com. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import XLPagerTabStrip
class FollowersListViewController: UIViewController {
    
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var tableviewFollowingList: UITableView!
    var arrayFollowers =  [[String: Any]]()
    var UserID:String!
    let defaults = UserDefaults.standard
    var ProfileType:String!
    var pageIndex: Int = 0
    var pageTitle: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        ProfileType = SharedManager.sharedInstance.otherProfile
        if  ProfileType == "1" {
            UserID = UserDefaults.standard.string(forKey: "OtherUserID")
            
        }else{
            UserID = UserDefaults.standard.string(forKey: "ID")
            
        }
        
        
        CallWebserviceFollowers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ProfileType = SharedManager.sharedInstance.otherProfile
        if  ProfileType == "1" {
            UserID = UserDefaults.standard.string(forKey: "OtherUserID")
            
        }else{
            UserID = UserDefaults.standard.string(forKey: "ID")
            
        }
        CallWebserviceFollowers()
    }
    
    
    func CallWebserviceFollowers(){
        let loginUserID = UserDefaults.standard.string(forKey: "ID")
        let Para =
            ["userid":"\(profileVCInstatnce.userId!)", "login_userid": loginUserID!] as [String : Any]
        print(Para)
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.getFollowersNew)"
        
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["followers"]as? [[String:Any]]{
                                self.arrayFollowers = Data
                                print(self.arrayFollowers)
                                self.tableviewFollowingList.reloadData()
                                
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
//MARK:- Extension TableView Delegate/DataSource Methods
extension FollowersListViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayFollowers.count == 0{ tableviewFollowingList.isHidden = true
            emptyLabel.isHidden = false
            return 0
            
        } else {
            emptyLabel.isHidden = true; tableviewFollowingList.isHidden = false
            return arrayFollowers.count
            
        }
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idetifier = "FollowersListViewCell"
        let cell:FollowersListViewCell = tableviewFollowingList.dequeueReusableCell(withIdentifier: idetifier)as! FollowersListViewCell
        
        let dictData = arrayFollowers[indexPath.row]
        //
        if let Username = dictData["username"] as? String {
            cell.labelUserName.text = Username
        }
        
        cell.seguirLB.text = (dictData["totalFollowers"] as? String)! + " Seguidores"
        cell.siguiendoLB.text = (dictData["totalFollowing"] as? String)! + " Siguiendo"
        if let followStatus = dictData["post_followup"] as? String {
            if followStatus == "1" {
                cell.seguirUB.isHidden = true
                cell.siguiendoUB.isHidden = false
            } else {
                cell.seguirUB.isHidden = false
                cell.siguiendoUB.isHidden = true
            }
        }
        cell.seguirUB.tag = indexPath.row
        cell.seguirUB.addTarget(self, action: #selector(didTapFollow), for: .touchUpInside)
        cell.siguiendoUB.tag = indexPath.row
        cell.siguiendoUB.addTarget(self, action: #selector(didTapFollow), for: .touchUpInside)
        if  let profilePic = dictData["avatarblobid"] as? String{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            cell.imgProfilePic.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
            
        }  else {
            cell.imgProfilePic.image = UIImage(named: "Splaceicon")
        }
        
        if let hasRecentPost = dictData["hasRecentPost"] as? Int {
            if hasRecentPost == 1{
                if (dictData["userid"] as! String) != UserID {
                    cell.recentWallUV.layer.borderWidth = 4.0
                } else {
                    cell.recentWallUV.layer.borderWidth = 0.0
                }
            } else {
                cell.recentWallUV.layer.borderWidth = 0.0
            }
        }
        
        cell.buttonProfile.tag = indexPath.row
        cell.buttonProfile.addTarget(self, action: #selector(self.OnUsers(_:)), for: UIControl.Event.touchUpInside)
        if  SharedManager.sharedInstance.ScrollStatus == "0"{
            let containerViewHight = self.tableviewFollowingList.contentSize.height
            NotificationCenter.default.post(name: Notification.Name("reloadTable"), object: nil, userInfo: ["hight": containerViewHight])
        }
        
        if let verify = dictData["verify"] as? String {
            cell.verifiedMarker.isHidden = verify == "1" ? false : true
        }
        return cell
    }
    
    @objc func didTapFollow(sender: UIButton) {
        let loginUserID = UserDefaults.standard.string(forKey: "ID")
        let dictData = self.arrayFollowers[sender.tag]
        let userid = dictData["userid"] as? String
        let Para =
            ["entityid":"\(userid!)","userid":"\(loginUserID!)"] as [String : Any]
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.setUserFollowing)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        self.CallWebserviceFollowers()
                    }
                    break
                case .failure(_):
                    objActivity.stopActivity()
                    print(response.result.error as Any)
                    break
                }
            }
    }
    
    @objc func OnUsers(_ sender : UIButton) {
        let dict = self.arrayFollowers[sender.tag]
        let OtherId = dict["userid"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
extension FollowersListViewController: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo.init(title: pageTitle ?? "Tab \(pageIndex)")
    }
}
