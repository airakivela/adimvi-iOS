
//  CategoriesDetailViewController.swift
//  adimvi
//  Created by javed carear  on 20/07/19.
//  Copyright © 2019 webdesky.com. All rights reserved.

import UIKit
import Alamofire
class CategoriesDetailViewController: UIViewController {
    
    @IBOutlet weak var titleCategories: UINavigationItem!
    @IBOutlet weak var tableviewCategoriesDetail: UITableView!
    @IBOutlet weak var titleLB: UILabel!
    
    var arrayCategories =  [[String: Any]]()
    var CategoriesID:String!
    let defaults = UserDefaults.standard
    var UserID:String!
    var OtherUserId:String!
    var strTitle: String!
    
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.darkGray]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableviewCategoriesDetail.refreshControl = refreshControl
        } else {
            tableviewCategoriesDetail.addSubview(refreshControl)
        }
        titleLB.text = strTitle
    }
    
    @objc func refreshData() {
        CallWebserviceCategories()
    }
    
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTpaBackUB(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UserID = UserDefaults.standard.string(forKey: "ID")
        self.tabBarController?.tabBar.isHidden = true
        CallWebserviceCategories()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func CallWebserviceCategories(){
        let Para =
            ["userid":"\(UserID!)","limit":"0","offset":"200",     "categoryid":"\(CategoriesID!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.getCategoryByPost)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                self.refreshControl.endRefreshing()
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["posts"]as? [[String:Any]]{
                                self.arrayCategories = Data
                                self.tableviewCategoriesDetail.reloadData()
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
extension CategoriesDetailViewController : UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCategories.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idetifier = "CategoriesDatailViewCell"
        let cell:CategoriesDatailViewCell = tableviewCategoriesDetail.dequeueReusableCell(withIdentifier: idetifier)as! CategoriesDatailViewCell
        let dictData = self.arrayCategories[indexPath.row] as AnyObject
        if let Title = dictData["title"] as? String {
            cell.labelTitle.text = Title
        }
        if let verify = dictData["verify"] as? String {
            cell.verifiedMarker.isHidden = verify == "1" ? false : true
        }
        if let CategotiesName = dictData["category_name"] as? String {
            cell.buttonCategoriesname.setTitle(CategotiesName, for: .normal)
        }
        if let Rating = dictData["avgRating"] as? Double {
            cell.RatingView.rating = Rating
        }
        if let Votas = dictData["ratingVotes"] as? String {
            cell.labelVotes.text = Votas
        }
        if let Pricer = dictData["pricer"] as? String{
            let Buy = dictData["post_buy"] as! String
            let Postuser = dictData["userid"]
                as! String
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
            } else {
                cell.labelPrice.isHidden = true
            }
        }
        if let Post = dictData["post_followup"] as? String {
            if Post == "1"{
                cell.buttonFollow.isHidden = true
                cell.buttonUnFollow.isHidden = false
            } else {
                cell.buttonFollow.isHidden = false
                cell.buttonUnFollow.isHidden = true
            }
        }
        if let PostContent = dictData["shortPostLink"] as? String {
            cell.webviewContent.backgroundColor = .clear
            cell.webviewContent.isOpaque = false
            cell.webviewContent.loadRequest(URLRequest(url: URL(string: "\(PostContent)")!))
        }
        if let userName = dictData["handle"] as? String {
            cell.labelUserName.text = userName
        }
        if let CategoriesName = dictData["category_name"] as? String {
            cell.buttonCategoriesname.setTitle( CategoriesName, for: .normal)
        }
        if let Like = dictData["netVotes"] as? String {
            cell.buttonLike.setTitle( Like, for: .normal)
        }
        if let View = dictData["views"] as? String {
            cell.buttonSeen.setTitle( View, for: .normal)
        }
        if let Time = dictData["post_created"] as? String {
            cell.buttonSeenTime.setTitle(Time, for: .normal)
        }
        if let comment = dictData["comments"] as? String {
            cell.buttonMessage.setTitle( comment, for: .normal)
        }
        if  let Image = dictData["post_image"] as? String{
            cell.imageCategories.sd_setImage(with: URL(string: Image), placeholderImage: UIImage(named: "Place.png"))
        }
        if  let profilePic = dictData["avatarblobid"] as? String{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            cell.ProfilePic.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        } else {
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
        cell.buttonUser.tag = indexPath.row
        cell.buttonUser.addTarget(self, action: #selector(self.tapAction(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonShare.tag = indexPath.row
        cell.buttonShare.addTarget(self, action: #selector(self.OnShare(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonPostDetail.tag = indexPath.row
        cell.buttonPostDetail.addTarget(self, action: #selector(self.OnDetail(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonFollow.tag = indexPath.row
        cell.buttonFollow.addTarget(self, action: #selector(self.OnFollow(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonUnFollow.tag = indexPath.row
        cell.buttonUnFollow.addTarget(self, action: #selector(self.OnFollow(_:)), for: UIControl.Event.touchUpInside)
        cell.remuroUB.tag = indexPath.row
        cell.remuroUB.addTarget(self, action: #selector(onTapRemuroUB), for: .touchUpInside)
        return cell
    }
    
    @objc func onTapRemuroUB(sender: UIButton) {
        let dict = self.arrayCategories[sender.tag]
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        vc.isFromPostDetail = true
        vc.orginalPostData = [
            "origin_post_id": dict["postid"]!,
            "orgin_post_image": dict["post_image"]!,
            "orgin_post_title": dict["title"]!,
            "origin_post_created": dict["post_date"]!
        ]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func OnFollow(_ sender: UIButton) {
        let dict = self.arrayCategories[sender.tag]
        let User = dict["userid"] as! String
        OtherUserId = User
        CallWebSetFollow(sender.tag)
    }
    
    @objc func OnShare(_ sender : UIButton) {
        let dict = self.arrayCategories[sender.tag]
        let ShareLink = dict["share_link"] as! String
        let shareText = "\(ShareLink)"
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        DispatchQueue.main.async() { () -> Void in
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @objc func tapAction(_ sender : UIButton) {
        let dict = self.arrayCategories[sender.tag]
        let OtherId = dict["userid"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func OnDetail(_ sender: UIButton) {
        let dict = self.arrayCategories[sender.tag]
        let PostId = dict["postid"] as! String
        let vc: PostDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier:"PostDetailsViewController")as! PostDetailsViewController
        vc.hidesBottomBarWhenPushed = true
        vc.PostID = PostId
        SharedManager.sharedInstance.PostId = PostId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func CallWebSetFollow(_ index: Int){
        let Para = ["entityid":"\(OtherUserId!)","userid":"\(UserID!)"] as [String : Any]
        let dict = arrayCategories[index] as [String: Any]
        if let Post = dict["post_followup"] as? String {
            if Post == "1"{
                NotificationCenter.default.post(name: .didChangePostByFollowUser, object: nil, userInfo: ["removeUserID": self.OtherUserId!])
            } else {
                NotificationCenter.default.post(name: .didChangePostByFollowUser, object: nil)
            }
        }
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.setUserFollowing)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        self.CallWebserviceCategories()
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
