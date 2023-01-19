//
//  PopularTagPostViewController.swift
//  adimvi
//
//  Created by javed carear  on 20/05/1942 Saka.
//  Copyright © 1942 webdesky.com. All rights reserved.

import UIKit
import Alamofire
class PopularTagPostViewController: UIViewController {
    @IBOutlet weak var tableviewTagPost: UITableView!
    @IBOutlet weak var buttonFollow: UIButton!
    @IBOutlet weak var buttonUnFllow: UIButton!
    @IBOutlet weak var titleTags: UINavigationItem!
    @IBOutlet weak var tableTagMuro: UITableView!
    @IBOutlet weak var segmentUV: UISegmentedControl!
    @IBOutlet weak var txtNoData: UILabel!
    
    var OtherUserId:String!
    var TagPostrId:String!
    var arrayTagPost = [[String: Any]]()
    var arrayTagMuro = [[String: Any]]()
    var UserID:String!
    var FollowStatus = "0"
    let defaults = UserDefaults.standard
    var MessageId:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableTagMuro.isHidden = true
        tableviewTagPost.isHidden = false
        
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
    }
    
    @IBAction func segmentHandle(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            tableviewTagPost.isHidden = false
            tableTagMuro.isHidden = true
            CallWebservicePost()
        } else {
            tableviewTagPost.isHidden = true
            tableTagMuro.isHidden = false
            CallWebserviceWallList()
        }
    }
    
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserID = UserDefaults.standard.string(forKey: "ID")
        CallWebservicePost()
    }
    
    @IBAction func OnFollow(_ sender: UIButton) {
        if sender.tag == 1{
            buttonUnFllow.isHidden = false
            buttonFollow.isHidden = true
            CallWebserviceFollowTags()
        }
        if sender.tag == 2{
            buttonUnFllow.isHidden = true
            buttonFollow.isHidden = false
            CallWebserviceFollowTags()
        }
    }
    
}
//MARK:- Extension TableView Delegate/DataSource Methods
extension PopularTagPostViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableviewTagPost {
            return arrayTagPost.count
        } else if tableView == tableTagMuro {
            return arrayTagMuro.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tableTagMuro {
            return UITableView.automaticDimension
        } else {
            return 505
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tableTagMuro {
            return UITableView.automaticDimension
        } else {
            return 505
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableTagMuro {
            if let cell = tableView.cellForRow(at: indexPath) as? FollowingTagMuroCell {
                if cell.imgWallPost.image == nil {
                    let alert = UIAlertController(title: "Attention", message: "image not available", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                } else {
                    let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier:  "FullImageVC") as! FullImageVC
                    vc.image = cell.imgWallPost.image!
                    present(vc, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableviewTagPost {
            let idetifier = "TagsPostTableViewCell"
            let cell:TagsPostTableViewCell = tableviewTagPost.dequeueReusableCell(withIdentifier: idetifier)as! TagsPostTableViewCell
            
            let dictData = self.arrayTagPost[indexPath.row]
            if let Title = dictData["post_title"] as? String {
                cell.labelTitle.text = Title
            }
            
            if let CategotiesName = dictData["category_name"] as? String {
                cell.buttonCategoriesname.setTitle(CategotiesName, for: .normal)
            }
            
            if let verify = dictData["verify"] as? String {
                cell.verifiedMarker.isHidden = verify == "1" ? false : true
            }
            
            if let Pricer = dictData["pricer"] as? String{
                let Buy = dictData["post_buy"] as! String
                let Postuser = dictData["userid"]as! String
                if Pricer == "1"{
                    cell.labelPrice.isHidden = false
                    if Buy == "1"&&UserID != Postuser{
                        cell.labelPrice.isHidden = false
                        cell.labelPrice.text = "Libre"
                        cell.labelPrice.textColor = UIColor(named: "labelBuy")
                    } else {
                        let price = dictData["price"] as! String
                        cell.labelPrice.text = price
                        cell.labelPrice.textColor = UIColor(named: "labelPrice")
                    }
                }else{
                    cell.labelPrice.isHidden = true
                }
            }
            
            if let PostContent = dictData["shortPostLink"] as? String {
                cell.webviewContent.backgroundColor = .clear
                cell.webviewContent.isOpaque = false
                cell.webviewContent.loadRequest(URLRequest(url: URL(string: "\(PostContent)")!))
                
            }
            
            if let Rating = dictData["avgRating"] as? Double {
                cell.RatingView.rating = Rating
            }
            if let Votas = dictData["ratingVotes"] as? String {
                cell.labelVotes.text = Votas
            }
            
            if let userName = dictData["username"] as? String {
                cell.labelUserName.text = userName
            }
            if let CategoriesName = dictData["category_name"] as? String {
                cell.buttonCategoriesname.setTitle( CategoriesName, for: .normal)
            }
            if let Like = dictData["netvotes"] as? String {
                cell.buttonLike.setTitle( Like, for: .normal)
            }
            if let Time = dictData["post_created"] as? String {
                cell.buttonSeenTime.setTitle(Time, for: .normal)
            }
            
            if let View = dictData["views"] as? String {
                cell.buttonSeen.setTitle( View, for: .normal)
            }
            if let comment = dictData["total_message"] as? String {
                cell.buttonMessage.setTitle( comment, for: .normal)
            }
            
            if  let Image = dictData["post_image"] as? String{
                cell.imageCategories.sd_setImage(with: URL(string: Image), placeholderImage: UIImage(named: "Place.png"))
            }
            
            if  let profilePic = dictData["avatarblobid"] as? String{
                let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                cell.ProfilePic.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
            }  else {
                cell.ProfilePic.image = UIImage(named: "Splaceicon")
            }
            if let hasRecentPost = dictData["hasRecentPost"] as? Int {
                if hasRecentPost == 1{
                    if (dictData["userid"] as! String) != UserID {
                        cell.recentWallUV.layer.borderWidth = 2.0
                    } else {
                        cell.recentWallUV.layer.borderWidth = 0.0
                    }
                } else {
                    cell.recentWallUV.layer.borderWidth = 0.0
                }
            }
            if let Post = dictData["post_followup"] as? String {
                if Post == "1"{
                    cell.buttonFollow.isHidden = true
                    cell.buttonUnFollow.isHidden = false
                }else{
                    cell.buttonFollow.isHidden = false
                    cell.buttonUnFollow.isHidden = true
                }
            }
            
            
            cell.buttonUser.tag = indexPath.row
            cell.buttonUser.addTarget(self, action: #selector(self.tapAction(_:)), for: UIControl.Event.touchUpInside)
            
            cell.buttonShare.tag = indexPath.row
            cell.buttonShare.addTarget(self, action: #selector(self.OnShare(_:)), for: UIControl.Event.touchUpInside)
            
            cell.buttonPostDetail.tag = indexPath.row
            cell.buttonPostDetail.addTarget(self, action: #selector(self.OnDetail(_:)), for: UIControl.Event.touchUpInside)
            
            cell.buttonFollow.tag = indexPath.row
            cell.buttonFollow.addTarget(self, action: #selector(self.Follow(_:)), for: UIControl.Event.touchUpInside)
            
            cell.buttonUnFollow.tag = indexPath.row
            cell.buttonUnFollow.addTarget(self, action: #selector(self.Follow(_:)), for: UIControl.Event.touchUpInside)
            cell.labelPrice.layer.cornerRadius = 8.0
            cell.labelPrice.layer.masksToBounds = true
            cell.remuroUB.tag = indexPath.row
            cell.remuroUB.addTarget(self, action: #selector(onTapRemuroUB), for: .touchUpInside)
            return cell
        } else if tableView == tableTagMuro {
            let idetifier = "FollowingTagMuroCell"
            let cell:FollowingTagMuroCell = tableTagMuro.dequeueReusableCell(withIdentifier: idetifier)as! FollowingTagMuroCell
            
            let dictData = self.arrayTagMuro[indexPath.row]
            if let tagData = dictData["tags"] as? [[String: Any]] {
                cell.initTag(tags: tagData)
                cell.delegate = self
            } else {
                
            }
            
            if let Comments = dictData["content"] as? String{
                cell.labelComments.text = Comments
            }
            if let time = dictData["created"] as? String{
                cell.labelTime.text = time
            }
            if let massage = dictData["totalComments"] as? String {
                cell.buttonmassageCount.setTitle(massage, for: .normal)
            }
            if let favourite = dictData["total_favourite"] as? String {
                cell.buttonFavourite.setTitle(favourite, for: .normal)
                cell.buttonUnFavourite.setTitle(favourite, for: .normal)
            }
            
            if let verify = dictData["verify"] as? String {
                cell.verifyMarker.isHidden = verify == "1" ? false : true
            }
            
            if let Image = dictData["imageUrl"] as?String{
                cell.imgWallPost.sd_setImage(with: URL(string:Image))
                
                if cell.imgWallPost.image != nil{
                    cell.htImages.constant = 180
                    
                }else{
                    cell.htImages.constant = 0
                    //
                }
                
            }
            
            if let hasRecentPost = dictData["hasRecentPost"] as? Int {
                if hasRecentPost == 1{
                    if (dictData["fromuserid"] as! String) != UserID {
                        cell.recentWallUV.layer.borderWidth = 2.0
                    } else {
                        cell.recentWallUV.layer.borderWidth = 0.0
                    }
                } else {
                    cell.recentWallUV.layer.borderWidth = 0.0
                }
            }
            
            
            if let Favourite = dictData["favourite"] as? String{
                if Favourite == "1"{
                    cell.buttonUnFavourite.isHidden = true
                    cell.buttonFavourite.isHidden = false
                }else{
                    cell.buttonUnFavourite.isHidden = false
                    cell.buttonFavourite.isHidden = true
                }
                
                
            }
            
            if let username = dictData["username"] as? String{
                cell.labelUserName.text = username
            }
            
            if  let profilePic = dictData["avatarblobid"] as? String{
                let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                cell.imgProfile.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
            } else {
                cell.imgProfile.image = UIImage(named: "Splaceicon")
            }
            
            cell.buttonFavourite.tag = indexPath.row
            cell.buttonFavourite.addTarget(self, action: #selector(self.Onfavourite(_:)), for: UIControl.Event.touchUpInside)
            
            cell.buttonUnFavourite.tag = indexPath.row
            cell.buttonUnFavourite.addTarget(self, action: #selector(self.Onfavourite(_:)), for: UIControl.Event.touchUpInside)
            
            
            
            cell.buttonmassageCount.tag = indexPath.row
            cell.buttonmassageCount.addTarget(self, action: #selector(self.OnComments(_:)), for: UIControl.Event.touchUpInside)
            
            cell.buttonUserProfile.tag = indexPath.row
            cell.buttonUserProfile.addTarget(self, action: #selector(self.OnUsers(_:)), for: UIControl.Event.touchUpInside)
            
            if let rewall = dictData["rewall"] as? [String: Any] {
                cell.originWallUV.isHidden = false
                cell.originPostUV.isHidden = true
                if let profilePic = rewall["origin_wall_useravatar"] as? String{
                    let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                    cell.originWallUserAvatar.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
                } else {
                    cell.originWallUserAvatar.image = UIImage(named: "Splaceicon")
                }
                cell.originWallUserName.text = rewall["origin_wall_username"] as? String
                cell.originWallContent.text = rewall["origin_wall_content"] as? String
                cell.originWallCreated.text = rewall["origin_wall_created"] as? String
                if let verify = rewall["origin_wall_userverify"] as? String {
                    cell.originWallUserVerify.isHidden = verify == "1" ? false : true
                }
                if let Image = rewall["origin_wall_imageUrl"] as?String{
                    cell.originWallExtra.sd_setImage(with: URL(string:Image))
                    
                    if cell.originWallExtra.image != nil{
                        cell.originWallExtraHeight.constant = 120
                        cell.originWallExtraUB.tag = indexPath.row
                        cell.originWallExtraUB.addTarget(self, action: #selector(onTapOriginWallExtra), for: .touchUpInside)
                        
                    }else{
                        cell.originWallExtraHeight.constant = 0
                    }
                }
            } else {
                cell.originWallUV.isHidden = true
                if let repost = dictData["repost"] as? [String: Any] {
                    cell.originPostUV.isHidden = false
        //            cell.originPostUVHeight.constant = 50.0
        //            cell.originPostUVTopSpacing.constant = 12.0
                    if  let profilePic = repost["origin_post_content"] as? String{
                        cell.originPostExtra.sd_setImage(with: URL(string: profilePic), placeholderImage: UIImage(named: "Splaceicon"))
                    }
                    if let title = repost["origin_post_title"] as? String {
                        cell.originPostTitle.text = title
                    }
                    if let created = repost["origin_post_created"] as? String {
                        cell.originPostCreated.text = created
                    }
                } else {
                    cell.originPostUV.isHidden = true
                }
                cell.originPostActionUB.tag = indexPath.row
                cell.originPostActionUB.addTarget(self, action: #selector(onTapOriginPost), for: .touchUpInside)
            }
            
            
            if let remuroCount = dictData["remuroCount"] as? String {
                cell.remuroUB.setTitle(remuroCount, for: .normal)
            }
            cell.remuroUB.tag = indexPath.row
            cell.remuroUB.addTarget(self, action: #selector(onTapRemuroTagUB), for: .touchUpInside)
            return cell
        }
        
        return UITableViewCell()
        
    }
    
    @objc func onTapOriginWallExtra(sender: UIButton) {
        let cell = tableTagMuro.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as? WallFollowingViewCell
        let image: UIImage = cell!.originWallExtra.image!
        let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier:  "FullImageVC") as! FullImageVC
        vc.image = image
        present(vc, animated: true, completion: nil)
    }
    
    @objc func onTapOriginPost(sender: UIButton) {
        let dictData = self.arrayTagMuro[sender.tag]
        let originPost = dictData["repost"] as! [String: Any]
        let postID = originPost["origin_post_id"] as! String
        let vc: PostDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier:"PostDetailsViewController")as! PostDetailsViewController
        vc.hidesBottomBarWhenPushed = true
        vc.PostID = postID
        SharedManager.sharedInstance.PostId = postID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onTapRemuroTagUB(sender: UIButton) {
        let dict: [String: Any] = self.arrayTagMuro[sender.tag]
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        ISREWALL = true
        ORIGINWALLDATA = dict
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func OnComments(_ sender : UIButton) {
        let dict = self.arrayTagMuro[sender.tag]
        let OtherId = dict["fromuserid"] as! String
        let message = dict["messageid"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        
        let vc: WallCommentsViewController = self.storyboard?.instantiateViewController(withIdentifier:"WallCommentsViewController")as! WallCommentsViewController
        vc.MessageId = message
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func Onfavourite(_ sender : UIButton) {
        let dict = self.arrayTagMuro[sender.tag]
        let Mid = dict["messageid"] as! String
        MessageId = Mid
        webserviceWallFavourite()
    }
    
    @objc func OnUsers(_ sender : UIButton) {
        let dict = self.arrayTagMuro[sender.tag]
        let OtherId = dict["fromuserid"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onTapRemuroUB(sender: UIButton) {
        let dict = self.arrayTagPost[sender.tag]
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        vc.isFromPostDetail = true
        vc.orginalPostData = [
            "origin_post_id": dict["postid"]!,
            "orgin_post_image": dict["post_image"]!,
            "orgin_post_title": dict["post_title"]!,
            "origin_post_created": dict["post_date"]!
        ]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func OnShare(_ sender : UIButton) {
        let dict = self.arrayTagPost[sender.tag]
        let ShareLink = dict["share_link"] as! String
        let shareText = "\(ShareLink)"
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        DispatchQueue.main.async() { () -> Void in
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    @objc func tapAction(_ sender : UIButton) {
        let dict = self.arrayTagPost[sender.tag]
        let OtherId = dict["userid"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func Follow(_ sender: UIButton) {
        let dict = self.arrayTagPost[sender.tag]
        let User = dict["userid"] as! String
        OtherUserId = User
        CallWebSetFollow(sender.tag)
    }
    
    
    
    @objc func OnDetail(_ sender: UIButton) {
        let dict = self.arrayTagPost[sender.tag]
        let PostId = dict["postid"] as! String
        let vc: PostDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier:"PostDetailsViewController")as! PostDetailsViewController
        vc.hidesBottomBarWhenPushed = true
        vc.PostID = PostId
        SharedManager.sharedInstance.PostId = PostId
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    func CallWebserviceWallList(){
        txtNoData.isHidden = true
        let Para =
            ["userid":"\(UserID!)",
             "limit":"0",
             "offset":"200",
             "tagid":"\(TagPostrId!)",
             "tagName":titleTags.title!
            ] as [String : Any]
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.GET_MUROS_BY_TAG)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["wallPost"]as? [[String:Any]]{
                                self.arrayTagMuro = Data
                                self.tableTagMuro.reloadData()
                                if self.arrayTagMuro.count == 0 {
                                    self.txtNoData.isHidden = false
                                    self.txtNoData.text = "¡Ups! Todavía no hay contenido para mostrarte en esta sección"
                                } else {
                                    self.txtNoData.isHidden = true
                                }
                            }
                        }
                        objActivity.stopActivity()
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
    
    func webserviceWallFavourite(){
        let Para =
            ["messageid":"\(MessageId!)","userid":"\(UserID!)","login_userId":"\(UserID!)"] as [String : Any]
        print(Para)
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.setWallfavourite)"
        
        
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        _ = response.result.value as! [String :Any]
                        
                        self.CallWebserviceWallList()
                        
                        
                        
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
    
    
    func CallWebservicePost(){
        txtNoData.isHidden = true
        let Para =
            ["userid":"\(UserID!)","limit":"0","offset":"200","tagid":"\(TagPostrId!)"] as [String : Any]
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.popularTagPostList)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let status = myData["tag_follow"] as? String {
                            if status == "1"{
                                self.buttonUnFllow.isHidden = false
                                self.buttonFollow.isHidden = true
                            }else{
                                self.buttonUnFllow.isHidden = true
                                self.buttonFollow.isHidden = false
                            }
                            
                        }
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["posts"]as? [[String:Any]]{
                                self.arrayTagPost = Data
                                self.tableviewTagPost.reloadData()
                                if self.arrayTagPost.count == 0 {
                                    self.txtNoData.isHidden = false
                                    self.txtNoData.text = "¡Ups! De momento no hay contenido para mostrarte en esta sección."
                                } else {
                                    self.txtNoData.isHidden = true
                                }
                            }
                        }
                        
                        
                        objActivity.stopActivity()
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
    
    func CallWebserviceFollowTags(){
        let Para =
            ["userid":"\(UserID!)","tagid":"\(TagPostrId!)"] as [String : Any]
        print(Para)
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.popularTagPostFollow)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["posts"]as? [[String:Any]]{
                                self.arrayTagPost = Data
                                self.tableviewTagPost.reloadData()
                                
                            }
                        }
                        
                        
                        objActivity.stopActivity()
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
    
    func CallWebSetFollow(_ index: Int){
        let Para =
            ["entityid":"\(OtherUserId!)","userid":"\(UserID!)"] as [String : Any]
        
        let dict = arrayTagPost[index] as [String: Any]
        if let Post = dict["post_followup"] as? String {
            if Post == "1"{
                NotificationCenter.default.post(name: .didChangePostByFollowUser, object: nil, userInfo: ["removeUserID": self.OtherUserId!])
            }else{
                NotificationCenter.default.post(name: .didChangePostByFollowUser, object: nil)
            }
        }
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.setUserFollowing)"
        
        // objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        self.CallWebservicePost()
                        DispatchQueue.main.async {
                            
                        }
                    }
                    // objActivity.stopActivity()
                    break
                case .failure(_):
                    objActivity.stopActivity()
                    print(response.result.error as Any)
                    break
                }
            }
        
    }
    
}

extension PopularTagPostViewController: FollowingTagMuroCellDelegate {
    func onTapTag(tag: TagModel) {
        let vc: PopularTagPostViewController = self.storyboard?.instantiateViewController(withIdentifier:"PopularTagPostViewController")as! PopularTagPostViewController
        vc.TagPostrId = tag.tagID
        vc.titleTags.title = tag.tags
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
