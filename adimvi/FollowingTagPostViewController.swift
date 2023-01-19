
//  FollowingTagPostViewController.swift
//  adimvi
//  Created by Mac on 24/04/20.
//  Copyright © 2020 webdesky.com. All rights reserved.


import UIKit
import Alamofire
import SDWebImage
class FollowingTagPostViewController: UIViewController,UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var tableviewTagPost: UITableView!
    var arrayFollowing =  [[String: Any]]()
    @IBOutlet weak var CollectionviewTag: UICollectionView!
    var OtherUserId:String!
    var UserID:String!
    let defaults = UserDefaults.standard
    var arrayTagPost = [[String: Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserID = UserDefaults.standard.string(forKey: "ID")
        CallWebserviceFollowers()
        CallWebserviceGetTags()
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.darkGray]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CallWebserviceGetTags()
        CallWebserviceFollowers()
    }
    
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
//MARK:- Extension TableView Delegate/DataSource Methods
extension FollowingTagPostViewController : UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayFollowing.count
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 505
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 505
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idetifier = "FollowingTagPostTableViewCell"
        let cell:FollowingTagPostTableViewCell = tableviewTagPost.dequeueReusableCell(withIdentifier: idetifier)as! FollowingTagPostTableViewCell
        let dictData = self.arrayFollowing[indexPath.row]
        if let Title = dictData["post_title"] as? String {
            cell.labelTitle.text = Title
        }
        if let verify = dictData["verify"] as? String {
            if verify == "0" {
                cell.verified.isHidden = true
            } else {
                cell.verified.isHidden = false
            }
        }
        if let Title = dictData["price"] as? String {
            cell.labelPrice.text = Title
        }
        if let Username = dictData["username"] as? String {
            cell.labelusName.text = Username
        }
        if let PostContent = dictData["shortPostLink"] as? String {
            cell.webviewContent.backgroundColor = .clear
            cell.webviewContent.isOpaque = false
            cell.webviewContent.backgroundColor = .clear
            cell.webviewContent.isOpaque = false
            cell.webviewContent.loadRequest(URLRequest(url: URL(string: "\(PostContent)")!))
        }
        if let CategoriesName = dictData["category_name"] as? String {
            cell.buttonCategoriesName.setTitle( CategoriesName, for: .normal)
        }
        if let Rating = dictData["avgRating"] as? Double {
            cell.RatingView.rating = Rating
        }
        if let Votas = dictData["ratingVotes"] as? String {
            cell.labelVotes.text = Votas
        }
        if let CategoriesName = dictData["views"] as? String {
            cell.buttonSeen.setTitle( CategoriesName, for: .normal)
        }
        if let CategoriesName = dictData["total_message"] as? String {
            cell.buttonMessageCount.setTitle( CategoriesName, for: .normal)
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
        if let CategoriesName = dictData["netvotes"] as? String {
            cell.buttonlike.setTitle( CategoriesName, for: .normal)
        }
        if let Time = dictData["post_created"] as? String{
            cell.buttonTime.setTitle(Time, for: .normal)
        }
        let Image = dictData["post_image"] as! String
        cell.imageFollowers.sd_setImage(with: URL(string: Image), placeholderImage: UIImage(named: "Place.png"))
        if  let profilePic = dictData["avatarblobid"] as? String{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            cell.imgProfilePic.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        } else {
            cell.imgProfilePic.image = UIImage(named: "Splaceicon")
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
        cell.buttonTab.tag = indexPath.row
        cell.buttonTab.addTarget(self, action: #selector(self.OnDetail(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonUsersTab.tag = indexPath.row
        cell.buttonUsersTab.addTarget(self, action: #selector(self.OnUsers(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonCategoriesName.tag = indexPath.row
        cell.buttonCategoriesName.addTarget(self, action: #selector(self.OnCategories(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonShare.tag = indexPath.row
        cell.buttonShare.addTarget(self, action: #selector(self.OnShare(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonFollow.tag = indexPath.row
        cell.buttonFollow.addTarget(self, action: #selector(self.OnFollow(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonUnFollow.tag = indexPath.row
        cell.buttonUnFollow.addTarget(self, action: #selector(self.OnFollow(_:)), for: UIControl.Event.touchUpInside)
        cell.remuroUB.tag = indexPath.row
        cell.remuroUB.addTarget(self, action: #selector(onTapRemuro), for: .touchUpInside)
        return cell
    }
    
    @objc func onTapRemuro(sender: UIButton) {
        let dict = self.arrayFollowing[sender.tag]
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
    
    @objc func OnFollow(_ sender: UIButton) {
        let dict = self.arrayFollowing[sender.tag]
        let User = dict["userid"] as! String
        OtherUserId = User
        CallWebSetFollow(sender.tag)
    }
    
    @objc func OnShare(_ sender : UIButton) {
        let dict = self.arrayFollowing[sender.tag]
        let ShareLink = dict["share_link"] as! String
        let shareText = "\(ShareLink)"
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        DispatchQueue.main.async() { () -> Void in
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @objc func OnDetail(_ sender: UIButton) {
        let dict = self.arrayFollowing[sender.tag]
        let PostId = dict["postid"] as! String
        let vc: PostDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier:"PostDetailsViewController")as! PostDetailsViewController
        vc.hidesBottomBarWhenPushed = true
        vc.PostID = PostId
        SharedManager.sharedInstance.PostId = PostId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func OnUsers(_ sender: UIButton) {
        let dict = self.arrayFollowing[sender.tag]
        let OtherId = dict["userid"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func OnCategories(_ sender : UIButton){
        let dict = self.arrayFollowing[sender.tag]
        let Title = dict["category_name"] as! String
        let ID = dict["categoryid"] as! String
        let vc: CategoriesDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "CategoriesDetailViewController")as! CategoriesDetailViewController
        vc.hidesBottomBarWhenPushed = true
        vc.CategoriesID = ID
        vc.titleCategories.title = Title
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func CallWebserviceFollowers(){
        let Para =
            ["userid":"\(UserID!)","limit":"0","offset":"50"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.followTagPostList)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        let code = myData["code"] as! String
                        if code == "200"{
                            self.tableviewTagPost.isHidden = false
                            if let arr = myData["response"] as? [String:Any]{
                                if let Data = arr["posts"]as? [[String:Any]]{
                                    self.arrayFollowing = Data
                                    self.tableviewTagPost.reloadData()
                                }
                            }
                        }else{
                            self.tableviewTagPost.isHidden = true
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
}
//Mark:- Collection view delegate methods
extension FollowingTagPostViewController:UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
// Mark:- Collection view data source and layout menthods
extension FollowingTagPostViewController:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayTagPost.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.CollectionviewTag.frame.size.width / 4
        let height = self.CollectionviewTag.frame.size.height
        return CGSize(width: width - 0, height: height - 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as! TagCollectionViewCell
        let dictData = self.arrayTagPost[indexPath.item]
        let Title = dictData["tag"] as! String
        cell.labelTagName.text = Title
        cell.buttonTag.tag = indexPath.row
        cell.buttonTag.addTarget(self, action: #selector(self.OnPost(_:)), for: UIControl.Event.touchUpInside)
        return cell
    }
    
    @objc func OnPost(_ sender : UIButton) {
        let dict = self.arrayTagPost[sender.tag]
        let NotasID = dict["tagid"] as! String
        let Title = dict["tag"] as! String
        let vc: PopularTagPostViewController = self.storyboard?.instantiateViewController(withIdentifier:"PopularTagPostViewController")as! PopularTagPostViewController
        vc.TagPostrId = NotasID
        vc.titleTags.title = Title
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func CallWebserviceGetTags(){
        let Para =
            ["userid":"\(UserID!)","limit":"0","offset":"100"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.followTagList)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["followTags"]as? [[String:Any]]{
                                self.arrayTagPost = Data
                                self.CollectionviewTag.reloadData()
                            }
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
