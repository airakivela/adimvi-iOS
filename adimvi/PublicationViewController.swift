
//  PublicationViewController.swift
//  adimvi
//  Created by javed carear  on 22/08/19.
//  Copyright © 2019 webdesky.com. All rights reserved.


import UIKit
import Alamofire
import SDWebImage
import XLPagerTabStrip
class PublicationViewController: UIViewController {
    
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var tableviewDraft: UITableView!
    
    @IBOutlet weak var tableviewPublication: UITableView!
    var arrayPulication =  [[String: Any]]()
    var arrayDraft =  [[String: Any]]()
    var UserID:String!
    var ProfileType:String!
    var OtherUserId:String!
    let defaults = UserDefaults.standard
    @IBOutlet weak var labelDraftName: UILabel!
    var pageIndex: Int = 0
    var pageTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ProfileType = SharedManager.sharedInstance.otherProfile
        if  ProfileType == "1" {
            UserID = UserDefaults.standard.string(forKey: "OtherUserID")
        }else{
            UserID = UserDefaults.standard.string(forKey: "ID")
        }
        CallWebservicePulication()
    }
}
//MARK:- Extension TableView Delegate/DataSource Methods
extension PublicationViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayPulication.count == 0{
            tableviewPublication.isHidden = true
            emptyLabel.isHidden = false
            return 0
        } else {
            emptyLabel.isHidden = true
            tableviewPublication.isHidden = false
            return self.arrayPulication.count
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 505
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 505
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idetifier = "PublicationViewCell"
        let cell:PublicationViewCell = tableviewPublication.dequeueReusableCell(withIdentifier: idetifier)as! PublicationViewCell        
        let dictData = self.arrayPulication[indexPath.row]
        if let Title = dictData["post_title"] as? String {
            cell.labelTitle.text = Title
        }
        if let CategoriesName = dictData["category_name"] as? String {
            cell.buttonCategoriesName.setTitle( CategoriesName, for: .normal)
        }
        if let Pricer = dictData["pricer"] as? String{
            let Buy = dictData["post_buy"] as! String
            let Postuser = dictData["userid"]as! String
            if Pricer == "1"{
                cell.labelPrice.isHidden = false
                if Buy == "1" && UserDefaults.standard.string(forKey: "ID") != Postuser{
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
        }else{
            cell.labelPrice.isHidden = true
        }
        
        if let Rating = dictData["avgRating"] as? Double {
            cell.RatingView.rating = Rating
        }
        if let Votas = dictData["ratingVotes"] as? String {
            cell.labelVotes.text = Votas
        }
        if let Username = dictData["username"] as? String {
            cell.labelusName.text = Username
        }
        if let PostContent = dictData["shortPostLink"] as? String {
            cell.webviewContent.backgroundColor = .clear
            cell.webviewContent.isOpaque = false
            cell.webviewContent.loadRequest(URLRequest(url: URL(string: "\(PostContent)")!))
        }
        if let CategoriesName = dictData["cat_title"] as? String {
            cell.buttonCategoriesName.setTitle( CategoriesName, for: .normal)
        }
        if let CategoriesName = dictData["views"] as? String {
            cell.buttonSeen.setTitle( CategoriesName, for: .normal)
        }
        if let CategoriesName = dictData["total_message"] as? String {
            cell.buttonMessageCount.setTitle( CategoriesName, for: .normal)
        }
        if let CategoriesName = dictData["netvotes"] as? String {
            cell.buttonlike.setTitle( CategoriesName, for: .normal)
        }
        if let Time = dictData["post_created"] as? String {
            cell.buttonSeenTime.setTitle(Time, for: .normal)
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
        cell.verifiedMarker.isHidden = dictData["verify"] as! String == "1" ? false : true
        let Image = dictData["post_image"] as! String
        cell.imageFollowers.sd_setImage(with: URL(string: Image), placeholderImage: UIImage(named: "Place"))
        if  let profilePic = dictData["avatarblobid"] as? String{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            cell.imgProfilePic.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        } else {
            cell.imgProfilePic.image = UIImage(named: "Splaceicon")
        }
        if let hasRecentPost = dictData["hasRecentPost"] as? Int {
            if hasRecentPost == 1{
                if (dictData["userid"] as! String) != UserDefaults.standard.string(forKey: "ID") {
                    cell.recentWallUV.layer.borderWidth = 2.0
                } else {
                    cell.recentWallUV.layer.borderWidth = 0.0
                }
            } else {
                cell.recentWallUV.layer.borderWidth = 0.0
            }
        }
        cell.buttonTap.tag = indexPath.row
        cell.buttonTap.addTarget(self, action: #selector(self.OnDetail(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonCategoriesName.tag = indexPath.row
        cell.buttonCategoriesName.addTarget(self, action: #selector(self.OnCategories(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonProfile.tag = indexPath.row
        cell.buttonProfile.addTarget(self, action: #selector(self.OnUsers(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonShare.tag = indexPath.row
        cell.buttonShare.addTarget(self, action: #selector(self.OnShare(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonFollow.tag = indexPath.row
        cell.buttonFollow.addTarget(self, action: #selector(self.OnFollow(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonUnFollow.tag = indexPath.row
        cell.buttonUnFollow.addTarget(self, action: #selector(self.OnFollow(_:)), for: UIControl.Event.touchUpInside)
        if  SharedManager.sharedInstance.ScrollStatus == "0"{
            let containerViewHight = self.tableviewPublication.contentSize.height
            NotificationCenter.default.post(name: Notification.Name("reloadTable"), object: nil, userInfo: ["hight": containerViewHight])
        }
        
        cell.remuroUB.tag = indexPath.row
        cell.remuroUB.addTarget(self, action: #selector(onTapRemuroUB), for: .touchUpInside)
        return cell
    }
    
    @objc func onTapRemuroUB(sender: UIButton) {
        let dict = self.arrayPulication[sender.tag]
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
        let dict = self.arrayPulication[sender.tag]
        let ShareLink = dict["share_link"] as! String
        let shareText = "\(ShareLink)"
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        DispatchQueue.main.async() { () -> Void in
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    
    @objc func OnCategories(_ sender : UIButton) {
        let dict = self.arrayPulication[sender.tag]
        let Title = dict["category_name"] as! String
        let ID = dict["categoryid"] as! String
        
        let vc: CategoriesDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "CategoriesDetailViewController")as! CategoriesDetailViewController
        vc.hidesBottomBarWhenPushed = true
        vc.CategoriesID = ID
        vc.titleCategories.title = Title
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func OnDetail(_ sender: UIButton) {
        let dict = self.arrayPulication[sender.tag]
        let PostId = dict["postid"] as! String
        let vc: PostDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier:"PostDetailsViewController")as! PostDetailsViewController
        vc.hidesBottomBarWhenPushed = true
        vc.PostID = PostId
        SharedManager.sharedInstance.PostId = PostId
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func OnFollow(_ sender: UIButton) {
        let dict = self.arrayPulication[sender.tag]
        let User = dict["userid"] as! String
        OtherUserId = User
        CallWebSetFollow(sender.tag)
    }
    
    @objc func OnUsers(_ sender : UIButton) {
        let dict = self.arrayPulication[sender.tag]
        let OtherId = dict["userid"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func OnPost(_ sender: UIButton) {
        let dict = self.arrayDraft[sender.tag]
        let PostId = dict["postid"] as! String
        let vc: ToPostVC = self.storyboard?.instantiateViewController(withIdentifier:"ToPostVC")as! ToPostVC
        vc.Postid = PostId
        vc.DraftStatus = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func CallWebservicePulication(){
        let Para =
            ["userid":"\(profileVCInstatnce.userId!)","limit":"0","offset":"50", "loggedin_userid": UserDefaults.standard.string(forKey: "ID")!] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.getUserPublicationsNew)"
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
                                self.arrayPulication = Data
                                print(self.arrayPulication)
                                self.tableviewPublication.reloadData()
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
    
    func CallWebSetFollow(_ index: Int){
        let Para =
            ["entityid":"\(OtherUserId!)","userid":"\(UserID!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.setUserFollowing)"
        let dict = arrayPulication[index] as [String: Any]
        if let Post = dict["post_followup"] as? String {
            if Post == "1"{
                NotificationCenter.default.post(name: .didChangePostByFollowUser, object: nil, userInfo: ["removeUserID": self.OtherUserId!])
            }else{
                NotificationCenter.default.post(name: .didChangePostByFollowUser, object: nil)
            }
        }
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        self.CallWebservicePulication()
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
extension PublicationViewController: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo.init(title: pageTitle ?? "Tab \(pageIndex)")
    }
}
