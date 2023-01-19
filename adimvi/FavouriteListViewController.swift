
//  FavouriteListViewController.swift
//  adimvi
//  Created by javed carear  on 15/07/19.
//  Copyright © 2019 webdesky.com. All rights reserved.

import UIKit
import Alamofire
import SDWebImage
class FavouriteListViewController: UIViewController {
    @IBOutlet weak var tabelviewFavourite: UITableView!
    let defaults = UserDefaults.standard
    var arrayfavourite =  [[String: Any]]()
    var UserID:String!
    var OtherUserId:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserID = UserDefaults.standard.string(forKey: "ID")
        CallWebserviceGetFavourite()
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.darkGray]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserID = UserDefaults.standard.string(forKey: "ID")
        CallWebserviceGetFavourite()
    }
    
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func OnFavourite(_ sender: Any) {
        let vc:FavouriteListViewController = self.storyboard?.instantiateViewController(withIdentifier: "FavouriteListViewController") as! FavouriteListViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    func CallWebserviceGetFavourite() {
        objActivity.startActivityIndicator()
        let params = ["userid":"\(UserID!)"] as Dictionary<String, String>
        var request = URLRequest(url: URL(string:"\(WebURL.BaseUrl)\(WebURL.getfavourite)")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json",forHTTPHeaderField:"Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                let code =  json["code"] as! String
                if let responce = json["response"] as? NSDictionary {
                    if code == "200"{
                        objActivity.stopActivity()
                        if let Result = responce.object(forKey:"favourite") as? [[String: Any]]{
                            self.arrayfavourite = Result
                            print( self.arrayfavourite)
                            DispatchQueue.main.async {
                                self.tabelviewFavourite.reloadData()
                                self.tabelviewFavourite.isHidden = false
                            }
                        }
                    }else{
                        objActivity.stopActivity()
                        self.tabelviewFavourite.isHidden = true
                    }
                }
                
            } catch {
                objActivity.stopActivity()
                print("error")
            }
        })
        task.resume()
    }
    
}
//MARK:- Extension TableView Delegate/DataSource Methods
extension FavouriteListViewController : UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayfavourite.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 505
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 505
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idetifier = "FavouriteViewCell"
        let cell: FavouriteViewCell = tabelviewFavourite.dequeueReusableCell(withIdentifier: idetifier)as!  FavouriteViewCell
        let dictData = self.arrayfavourite[indexPath.row] as AnyObject
        if let verify = dictData["verify"] as? String {
            cell.verifiedMarker.isHidden = verify == "1" ? false : true
        }
        if let Title = dictData["post_title"] as? String{
            cell.labelTitle.text = Title
        }
        if let Post = dictData["post_followup"] as? String {
            if Post == "1"{
                cell.buttonFollow.isHidden = true
                cell.buttonUnFollow.isHidden = false
            }else{
                cell.buttonFollow.isHidden = false
                cell.buttonUnFollow.isHidden = true
            }
            if let Rating = dictData["avgRating"] as? Double {
                cell.RatingView.rating = Rating
            }
            if let Votas = dictData["ratingVotes"] as? String {
                cell.labelVotes.text = Votas
            }
        }
        if let Username = dictData["username"] as? String{
            cell.labelUserName.text = Username
        }
        if let Views = dictData["views"] as? String{
            cell.ButtonViewCount.setTitle(Views, for: .normal)
        }
        if let Views = dictData["post_created"] as? String{
            cell.buttonTime.setTitle(Views, for: .normal)
        }
        if let Views = dictData["netvotes"] as? String{
            cell.buttonLike.setTitle(Views, for: .normal)
        }
        if let comment = dictData["comments"] as? String {
            cell.buttonMessage.setTitle( comment, for: .normal)
        }
        if let Categoriesname = dictData["categoyname"] as? String{
            cell.buttonCategoriesName.setTitle( Categoriesname, for: .normal)
        }
        if let Pricer = dictData["pricer"] as? String{
            let Buy = dictData["post_buy"] as! String
            let Postuser = dictData["userid"]as! String
            if Pricer == "1"{
                cell.labelPrice.isHidden = false
                let price = dictData["price"] as! String
                if Buy == "1"&&UserID != Postuser{
                    cell.labelPrice.isHidden = false
                    cell.labelPrice.text = "Libre"
                    cell.labelPrice.textColor = UIColor(named: "labelBuy")
                } else {
                    cell.labelPrice.textColor = UIColor(named: "labelPrice")
                    cell.labelPrice.text = price
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
        if let Image = dictData["post_image"] as? String{
            cell.imgFavourite.sd_setImage(with: URL(string: Image), placeholderImage: UIImage(named: "bgGrid.png"))
        }
        if  let profilePic = dictData["avatarblobid"] as? String{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            cell.imgProfilePic.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
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
        cell.buttonUserTab.tag = indexPath.row
        cell.buttonUserTab.addTarget(self, action: #selector(self.tapAction(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonPostDetail.tag = indexPath.row
        cell.buttonPostDetail.addTarget(self, action: #selector(self.OnDetail(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonShare.tag = indexPath.row
        cell.buttonShare.addTarget(self, action: #selector(self.OnShare(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonCategoriesName.addTarget(self, action: #selector(self.OnCategories(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonFollow.tag = indexPath.row
        cell.buttonFollow.addTarget(self, action: #selector(self.OnFollow(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonUnFollow.tag = indexPath.row
        cell.buttonUnFollow.addTarget(self, action: #selector(self.OnFollow(_:)), for: UIControl.Event.touchUpInside)
        cell.remuroUB.tag = indexPath.row
        cell.remuroUB.addTarget(self, action: #selector(onTapRemuroUB), for: .touchUpInside)
        return cell
    }
    
    @objc func onTapRemuroUB(sender: UIButton) {
        let dict = self.arrayfavourite[sender.tag]
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
        let dict = self.arrayfavourite[sender.tag] as AnyObject
        let User = dict["userid"] as! String
        OtherUserId = User
        CallWebSetFollow(sender.tag)
    }
    
    @objc func OnShare(_ sender : UIButton) {
        let dict = self.arrayfavourite[sender.tag] as AnyObject
        let ShareLink = dict["share_link"] as! String
        let shareText = "\(ShareLink)"
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        DispatchQueue.main.async() { () -> Void in
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @objc func OnCategories(_ sender : UIButton){
        let dict = self.arrayfavourite[sender.tag] as AnyObject
        let Title = dict["categoyname"] as! String
        let ID = dict["categoryid"] as! String
        let vc: CategoriesDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "CategoriesDetailViewController")as! CategoriesDetailViewController
        vc.hidesBottomBarWhenPushed = true
        vc.CategoriesID = ID
        vc.titleCategories.title = Title
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func tapAction(_ sender : UIButton) {
        let dict = self.arrayfavourite[sender.tag] as AnyObject
        let OtherId = dict["userid"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func OnDetail(_ sender: UIButton) {
        let dict = self.arrayfavourite[sender.tag] as AnyObject
        let PostId = dict["postid"] as! String
        let vc: PostDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier:"PostDetailsViewController")as! PostDetailsViewController
        vc.hidesBottomBarWhenPushed = true
        vc.PostID = PostId
        SharedManager.sharedInstance.PostId = PostId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func CallWebSetFollow(_ index: Int){
        let Para =
            ["entityid":"\(OtherUserId!)","userid":"\(UserID!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.setUserFollowing)"
        let dict = arrayfavourite[index] as [String: Any]
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
                        self.CallWebserviceGetFavourite()
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
