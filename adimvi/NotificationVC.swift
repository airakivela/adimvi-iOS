
//  NotificationVC.swift
//  adimvi
//  Created by javed carear  on 17/06/19.
//  Copyright © 2019 webdesky.com. All rights reserved.

import UIKit
import Alamofire

class NotificationVC: BaseViewController {
    
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var tableNoti: UITableView!
    var arrayNotification = [[String: Any]]()
    var Userid:String!
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        Userid = UserDefaults.standard.string(forKey:"ID")
        if #available(iOS 10.0, *) {
            tableNoti.refreshControl = refreshControl
        } else {
            tableNoti.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        CallWebserviceNotifications()
        
    }
    
    @objc func refreshData() {
        CallWebserviceNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Userid = UserDefaults.standard.string(forKey:"ID")
        CallWebserviceNotifications()
    }
    
    @IBAction func onTapAllSeen(_ sender: Any) {
        let param: [String: String] = ["userid": Userid]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.allseenNotification)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:param)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        self.CallWebserviceNotifications()
                    }
                    objActivity.startActivityIndicator()
                    let actionSheetController: UIAlertController = UIAlertController(title: "Notificaciones vistas", message: "Todas tus nuevas notificaciones han sido marcadas como leídas.", preferredStyle: .alert)
                    let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) { action -> Void in
                    }
                    actionSheetController.addAction(cancelAction)
                    self.present(actionSheetController, animated: true, completion: nil)
                    
                    break
                case .failure(_):
                    objActivity.startActivityIndicator()
                    print(response.result.error as Any)
                    break
                }
            }
    }
    
    @IBAction func OnBack(_ sender: Any) {
        isClickedNotification = false
        self.navigationController?.popViewController(animated: true)
    }
    
}
//Mark:- UITableView delegate Methods
extension NotificationVC:UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}

//Mark:- UItableView DataSource Methods
extension NotificationVC:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayNotification.count == 0{ tableNoti.isHidden = true; emptyLabel.isHidden = false
            return 0
            
        } else {
            emptyLabel.isHidden = true; tableNoti.isHidden = false
            return arrayNotification.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as! NotificationCell
        
        let dictData = self.arrayNotification[indexPath.row]
        let Massage = dictData["title"] as! String
        cell.lblTitle.text = Massage
        let name = dictData["msg"] as! String
        cell.labelUserName.text = name
        if let readStatus = dictData["readStatus"] as? String {
            if readStatus == "1" {
                cell.readStatusUB.isHidden = true
            } else {
                cell.readStatusUB.isHidden = false
            }
        } else {
            cell.readStatusUB.isHidden = false
        }
        
        if let verify = dictData["verify"] as? String {
            if verify == "1" {
                cell.verifyUIMG.isHidden = false
            } else {
                cell.verifyUIMG.isHidden = true
            }
        } else {
            cell.verifyUIMG.isHidden = true
        }
        
        if let avatar = dictData["avatarblobid"] as? String {
            let imageURl = "\(WebURL.ImageUrl)\(avatar)"
            cell.userIMG.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        }
        
        if let name = dictData["username"] as? String {
            cell.nameLB.text = name
        }
        
        
        
        if let SubTitle = dictData["created"] as? String{
            cell.lblSubTitle.text! = SubTitle
        }
        if let Type = dictData["type"] as? String{
            if Type == "private_message"{
                cell.imgIcon.image = #imageLiteral(resourceName: "Gmail")
            }
            if Type == "post_comment_reply"||Type == "wall_post_comment_reply"{
                cell.imgIcon.image = #imageLiteral(resourceName: "Reply")
            }
            
            if Type == "following"{
                cell.imgIcon.image = #imageLiteral(resourceName: "FollowingUser")
            }
            
            if Type == "post_comment_dislike"||Type == "post_dislike"{
                cell.imgIcon.image = #imageLiteral(resourceName: "RDown")
                
            }
            if Type == "post_comment_like"||Type == "post_like"{
                cell.imgIcon.image = #imageLiteral(resourceName: "GDown")
            }
            
            if Type == "post_comment"{
                cell.imgIcon.image = #imageLiteral(resourceName: "bubble")
                
            }
            if Type == "post_rating"{
                cell.imgIcon.image = #imageLiteral(resourceName: "starFil")
                
            }
            
            if Type == "follow"{
                cell.imgIcon.image = #imageLiteral(resourceName: "FollowingUser")
                
            }
            if Type == "wall_post"{
                cell.imgIcon.image = #imageLiteral(resourceName: "imgStore")
            }
            
            if Type == "wall_post_heart"{
                cell.imgIcon.image = #imageLiteral(resourceName: "imgRedLike")
            }
            
            if Type == "post_comment_mention" {
                cell.imgIcon.image = #imageLiteral(resourceName: "at")
            }
            
            if Type == "rewall_post" {
                cell.imgIcon.image = #imageLiteral(resourceName: "Remoro")
            }
            
            
        }
        cell.profileActionUB.tag = indexPath.row
        cell.profileActionUB.addTarget(self, action: #selector(didTapProfile), for: .touchUpInside)
        cell.buttonTap.tag = indexPath.row
        cell.buttonTap.addTarget(self, action: #selector(self.tapAction(_:)), for: UIControl.Event.touchUpInside)
        
        return cell
        
    }
    
    @objc func didTapProfile(_ sender: UIButton) {
        let dict = self.arrayNotification[sender.tag]
        let OtherId = dict["eventuserID"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onCallSeenNotification(key: String) {
        let param: [String: String] = ["key": key]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.seenNotification)"
        Alamofire.request(Api, method: .post,parameters:param)
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
    
    @objc func tapAction(_ sender : UIButton) {
        let dict = self.arrayNotification[sender.tag]
        let Status = dict["status"] as! String
        let PostID = dict["postid"] as! String
        let OtherId = dict["userid"] as! String
        let type = dict["type"] as! String
        let filter_date = dict["filter_date"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        
        onCallSeenNotification(key: filter_date)
        
        if Status == "7"{
            let vc: PrivateMessageViewController =
                self.storyboard?.instantiateViewController(withIdentifier: "PrivateMessageViewController")as! PrivateMessageViewController
            //vc.NotifiationStatus = "1"
            vc.targetUserName = dict["username"] as? String
            vc.targetUserAvatar = dict["avatarblobid"] as? String
            if let verifyStr = dict["verify"] as? String {
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
        if Status == "4"{
            let vc: FollowersVc =
                self.storyboard?.instantiateViewController(withIdentifier: "FollowersVc")as! FollowersVc
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if Status == "3"{
            let Id = dict["postid"] as! String
            let vc: MoreCommentsViewController =
                self.storyboard?.instantiateViewController(withIdentifier: "MoreCommentsViewController")as! MoreCommentsViewController
            vc.PostID = Id
            vc.PostComment = NSAttributedString(string: (dict["origin_comment"] as? String)!, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)])
            vc.PostUserName = dict["origin_comment_user_name"] as? String
            vc.PostDate = dict["created"] as? String
            vc.PostUserVeify = dict["origin_comment_user_verify"] as? String
            vc.CategoryId = dict["categoryid"] as? String
            vc.PostUserImageUrl = dict["origin_comment_user_avatar"] as? String
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if Status == "11"{
            let Id = dict["postid"] as! String
            let vc: WallCommentsViewController =
                self.storyboard?.instantiateViewController(withIdentifier: "WallCommentsViewController")as!  WallCommentsViewController
            vc.MessageId = Id
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if Status == "1"{
            
            let vc: CommentListViewController =
                self.storyboard?.instantiateViewController(withIdentifier: "CommentListViewController")as! CommentListViewController
            vc.PostID = PostID
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if Status == "10"{
            if dict["type"] as? String == "post_comment_mention" {
                if dict["postid1"] as? String == "" {
                    let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
                    SharedManager.sharedInstance.otherProfile = "1"
                    vc.WallType = "1"
                    vc.isFromNotificationPost = true
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc:CommentListViewController = self.storyboard?.instantiateViewController(withIdentifier: "CommentListViewController") as!CommentListViewController
                    vc.PostID = PostID
                    vc.isFromNotification = true
                    vc.selectedPostID = dict["postid1"] as? String
                    SharedManager.sharedInstance.PostId = PostID
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            } else {
                let vc: PostDetailsViewController =
                    self.storyboard?.instantiateViewController(withIdentifier: "PostDetailsViewController")as! PostDetailsViewController
                vc.hidesBottomBarWhenPushed = true
                vc.PostID = PostID
                SharedManager.sharedInstance.PostId = PostID
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
        
        if Status == "9"{
            let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
            SharedManager.sharedInstance.otherProfile = "1"
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
        if Status == "8"{
            let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
            SharedManager.sharedInstance.otherProfile = "1"
            vc.WallType = "1"
            if type == "wall_post" || type == "wall_post_heart" || type == "rewall_post" {
                vc.isFromNotificationPost = true
            }
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    func CallWebserviceNotifications(){
        let Para =
            ["userid":"\(Userid!)"] as [String : Any]
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.mainNotification)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["notify"]as? [[String:Any]]{
                                self.arrayNotification = Data
                                self.tableNoti.reloadData()
                            }
                        }
                        objActivity.stopActivity()
                        self.refreshControl.endRefreshing()
                        DispatchQueue.main.async {
                            
                        }
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

class NotificationCell: UITableViewCell {
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var buttonTap: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var readStatusUB: UIButton!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var verifyUIMG: UIImageView!
    @IBOutlet weak var userIMG: UIImageView!
    @IBOutlet weak var profileActionUB: UIButton!
    
}



