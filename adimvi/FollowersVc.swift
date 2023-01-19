
//  FollowersVc.swift
//  adimvi
//  Created by javed carear  on 10/07/19.
//  Copyright © 2019 webdesky.com. All rights reserved.

import UIKit
import Alamofire

protocol FollowersVCDelegate {
    func onShowRefreshController(isShowing: Bool)
}

class FollowersVc: UIViewController {
    @IBOutlet weak var tableviewFollowers: UITableView!
    var arrayFollowing =  [[String: Any]]()
    var UserID:String!
    var OtherUserId:String!
    let defaults = UserDefaults.standard
    
    var startPoint: Int = 0
    var step: Int = 50
    var isPageable: Bool = true
    var isPaginating: Bool = false
    
    var delegate: FollowersVCDelegate?
    var isShowingRefreshController: Bool = false
    
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserID = UserDefaults.standard.string(forKey: "ID")
        CallWebserviceFollowers(startPoint: startPoint, step: step)
        tableviewFollowers.isPagingEnabled = true
        tableviewFollowers.showsVerticalScrollIndicator = false
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableviewFollowers.refreshControl = refreshControl
        } else {
            tableviewFollowers.addSubview(refreshControl)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeUserSetFollow), name: Notification.Name.didChangePostByFollowUser, object: nil)
    }
    
    @objc func refreshData() {
        delegate?.onShowRefreshController(isShowing: true)
        self.startPoint = 0
        self.arrayFollowing.removeAll()
        CallWebserviceFollowers(startPoint: startPoint, step: step)
    }
    
    @objc func didChangeUserSetFollow(_ notification: Notification) {
        if arrayFollowing.isEmpty {
            return
        }
        if let notificationData = notification.userInfo as? [String: String] {
            if let removeUserID = notificationData["removeUserID"] {
                let counter = self.arrayFollowing.filter({($0["userid"] as! String) == removeUserID }).count
                self.startPoint = self.arrayFollowing.count - counter
                self.arrayFollowing.removeAll(where: {($0["userid"] as! String) == removeUserID})
                self.tableviewFollowers.reloadData()
            } else {
                arrayFollowing.removeAll()
                tableviewFollowers.reloadData()
                startPoint = 0
                CallWebserviceFollowers(startPoint: startPoint, step: step)
            }
        } else {
            arrayFollowing.removeAll()
            tableviewFollowers.reloadData()
            startPoint = 0
            CallWebserviceFollowers(startPoint: startPoint, step: step)
        }
    }
    
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50.0))
        footerView.backgroundColor = .clear
        let loadingLB = UILabel()
        loadingLB.text = "Mostrar más..."
        loadingLB.textAlignment = .center
        loadingLB.textColor = UIColor(named: "AppColor")
        loadingLB.font = .systemFont(ofSize: 14.0)
        loadingLB.center = footerView.center
        loadingLB.frame = footerView.frame
        footerView.addSubview(loadingLB)
        return footerView
    }
}
//MARK:- Extension TableView Delegate/DataSource Methods
extension FollowersVc : UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayFollowing.count
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        guard !self.isPaginating else {
            return
        }
        if self.arrayFollowing.isEmpty {
            return
        }
        if position > tableviewFollowers.contentSize.height - 50 - scrollView.frame.height && isPageable {
            self.startPoint += step
            self.tableviewFollowers.tableFooterView = createSpinnerFooter()
            CallWebserviceFollowers(startPoint: (startPoint), step: step)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idetifier = "FollowersViewCell"
        let cell:FollowersViewCell = tableviewFollowers.dequeueReusableCell(withIdentifier: idetifier)as! FollowersViewCell
        let dictData = self.arrayFollowing[indexPath.row]
        if let Title = dictData["post_title"] as? String {
            cell.labelTitle.text = Title
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
        if let Rating = dictData["avgRating"] as? Double {
            cell.RatingView.rating = Rating
        }
        if let Votas = dictData["ratingVotes"] as? String {
            cell.labelVotes.text = Votas
        }
        if let Username = dictData["username"] as? String {
            cell.labelusName.text = Username
        }
        if let CategoriesName = dictData["category_name"] as? String {
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
        if let CategoriesName = dictData["post_created"] as? String {
            cell.buttonTime.setTitle( CategoriesName, for: .normal)
        }
        let Image = dictData["post_image"] as! String
        cell.imageFollowers.sd_setImage(with: URL(string: Image), placeholderImage: UIImage(named: "Place.png"))
        if  let profilePic = dictData["avatarblobid"] as? String{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            cell.imgProfilePic.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        }  else {
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
//        if let Pricer = dictData["pricer"] as? String {
//            if Pricer == "1"{
//                let price = dictData["price"] as! String
//                cell.labelPrice.text = price
//            }else{
//                cell.labelPrice.isHidden = true
//            }
//        }
        if let PostContent = dictData["shortPostLink"] as? String {
            cell.webviewContent.backgroundColor = .clear
            cell.webviewContent.isOpaque = false
            cell.webviewContent.loadRequest(URLRequest(url: URL(string: "\(PostContent)")!))
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
        cell.remuroUB.addTarget(self, action: #selector(onTapRemuroUB), for: .touchUpInside)
        return cell
    }
    
    @objc func onTapRemuroUB(sender: UIButton) {
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
    
    @objc func OnShare(_ sender : UIButton) {
        let dict = self.arrayFollowing[sender.tag]
        let ShareLink = dict["share_link"] as! String
        let shareText = "\(ShareLink)"
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        DispatchQueue.main.async() { () -> Void in
            self.present(activityViewController, animated: true, completion: nil)
        }
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
    
    func CallWebserviceFollowers(startPoint: Int, step: Int){
        let Para =
            ["userid":"\(UserID!)","limit":"\(startPoint)","offset":"\(step)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.getPostFollowingTest)"
        if self.isPageable {
            self.isPaginating = true
        }
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                self.refreshControl.endRefreshing()
                self.delegate?.onShowRefreshController(isShowing: false)
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["postFollowing"]as? [[String:Any]]{
                                if Data.count < self.step {
                                    self.isPageable = false
                                }
                                self.arrayFollowing.append(contentsOf: Data)
                                if self.isPageable {
                                    self.isPaginating = false
                                }
                                DispatchQueue.main.async{
                                    self.tableviewFollowers.reloadData()
                                    self.tableviewFollowers.tableFooterView = nil
                                    objActivity.stopActivity()
                                }
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
    
    func CallWebSetFollow(_ index: Int){
        let Para =
            ["entityid":"\(OtherUserId!)","userid":"\(UserID!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.setUserFollowing)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    objActivity.stopActivity()
                    if response.result.value != nil{
                        let data = self.arrayFollowing[index]
                        let userID = data["userid"] as! String
                        NotificationCenter.default.post(name: .didChangePostByFollowUser, object: nil, userInfo: ["removeUserID": userID])
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






