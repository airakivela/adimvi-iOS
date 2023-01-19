//  PostContentViewController.swift
//  Created by javed carear  on 11/11/19.

import UIKit
import Alamofire
import SDWebImage
import FittedSheets

class PostContentViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var UrlLink:String?
    var UserID:String?
    var LikeType:String?
    var LikeCount: String?
    var FollowStatus: String?
    var ShareLink:String?
    var PostID: String?
    var IntityID: String?
    var PostFav: String?
    var avatar: String?
    var CatID: String?
    
    var arrayPostDetail =  [String: Any]()
    var dictData: [String: Any] = [String: Any]()
    
    var isShowLikeUV: Bool = false
    
    @IBOutlet weak var WebViewPostContent: UIWebView!
    @IBOutlet weak var buttonlikeDisable: UIButton!
    @IBOutlet weak var buttonLike: DesignableButton!
    @IBOutlet weak var buttonSelectLike: DesignableButton!
    @IBOutlet weak var labelLikeCount: UILabel!
    @IBOutlet weak var buttonSelectDislike: UIButton!
    @IBOutlet weak var onDisLike: UIButton!
    @IBOutlet weak var buttonUnlikeDisable: UIButton!
    @IBOutlet weak var buttonFollow: UIButton!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var likeUV: UIView!
    @IBOutlet weak var thumbUB: UIButton!
    @IBOutlet weak var userUV: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.WebViewPostContent.scrollView.showsHorizontalScrollIndicator = false
        WebViewPostContent.loadRequest(URLRequest(url: URL(string: "\(UrlLink!)")!))
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.darkGray]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        userImg.sd_setImage(with: URL(string: avatar!), placeholderImage: UIImage(named: "Splaceicon"))
        initUIView()
        CallWebservicePostDetail()
        self.navigationItem.rightBarButtonItem = nil
        
        userUV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapFollowUB)))
        handleLikeUB(isShow: isShowLikeUV)
        
//        WebViewPostContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapWebView)))
        
        
    }
    @IBAction func onTapBackUB(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
//    @objc func onTapWebView() {
//        isShowLikeUV = !isShowLikeUV
//        handleLikeUB(isShow: isShowLikeUV)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        self.hidesBottomBarWhenPushed = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
        self.hidesBottomBarWhenPushed = true
    }
        
    func handleLikeUB(isShow: Bool) {
        likeUV.isHidden = !isShow
    }
    
    func CallWebservicePostDetail(){
        let Para =
            ["postid":"\(PostID!)","userid":"\(UserID!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.getPostDetail)"
        
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["postinfo"]as? [String:Any]{
                                self.arrayPostDetail = Data
                                self.PostDetails()
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
    
    @IBAction func didTapThumUB(_ sender: Any) {
        isShowLikeUV = !isShowLikeUV
        handleLikeUB(isShow: isShowLikeUV)
    }
    
    func PostDetails()  {
        
        if let CatId = self.arrayPostDetail["categoryid"]
            as? String{
            CatID = CatId
        }
        
        if let LikeType = self.arrayPostDetail["like_dislike_type"]
            as? String{
            print(LikeType)
            self.LikeType = LikeType
            buttonLike.isHidden = true
            onDisLike.isHidden = true
            buttonSelectLike.isHidden = true
            buttonlikeDisable.isHidden = true
            buttonUnlikeDisable.isHidden = true
            buttonSelectDislike.isHidden = true
            if LikeType == "0"{
                buttonSelectDislike.isHidden = false
                buttonlikeDisable.isHidden = false
                thumbUB.imageView!.tintColor = UIColor(named: "mainRed")
            }
            else if LikeType == "1"{
                buttonSelectLike.isHidden = false
                buttonUnlikeDisable.isHidden = false
                thumbUB.imageView!.tintColor = UIColor(named: "mainGreen")                
            }else{
                buttonLike.isHidden = false
                onDisLike.isHidden = false
                thumbUB.imageView!.tintColor = UIColor(named: "Dark grey (Dark mode)")
            }
        }
        
        if let FollowStatus = self.arrayPostDetail["post_followup"]
            as? String{
            self.FollowStatus = FollowStatus
            if FollowStatus == "1"{
                buttonFollow.isSelected = true
                buttonFollow.backgroundColor = UIColor(named: "AppColor")
            }else{
                buttonFollow.isSelected = false
                buttonFollow.backgroundColor = UIColor(named: "mainGreen")
            }
            
        }
        
    }
    
    @IBAction func OnCancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func initUIView() {
        labelLikeCount.text = self.LikeCount
    }
    
    @IBAction func onTapShareUB(_ sender: Any) {
        let shareText = "\(ShareLink!)"
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        DispatchQueue.main.async() { () -> Void in
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func OnLikes(_ sender: UIButton) {
        if sender.tag == 1 {
            LikeType = "1"
            buttonLike.isHidden = true
            onDisLike.isHidden = true
            buttonSelectLike.isHidden = false
            buttonUnlikeDisable.isHidden = false
            CallWebserviceLike()
        }
        
        if sender.tag == 2{
            LikeType = "1"
            buttonSelectLike.isHidden = true
            buttonLike.isHidden = false
            onDisLike.isHidden = false
            buttonUnlikeDisable.isHidden = true
            CallWebserviceLike()
        }
        
    }
    
    @IBAction func OnDislike(_ sender: UIButton) {
        if sender.tag == 1 {
            LikeType = "0"
            buttonLike.isHidden = true
            onDisLike.isHidden = true
            buttonSelectDislike.isHidden = false
            buttonlikeDisable.isHidden = false
            CallWebserviceLike()
        }
        
        if sender.tag == 2{
            LikeType = "0"
            buttonSelectDislike.isHidden = true
            buttonLike.isHidden = false
            onDisLike.isHidden = false
            buttonlikeDisable.isHidden = true
            CallWebserviceLike()
        }
        
    }
    
    @IBAction func didTapCommentUB(_ sender: Any) {
        let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier: "CommentBottomSheetVC") as! CommentBottomSheetVC
        vc.PostID = PostID
        vc.CatID = CatID
        vc.delegate = self
        let sheetVC = SheetViewController(controller: vc, sizes: [.fullscreen], options: SheetOptions(
                                            pullBarHeight: 0,
            shouldExtendBackground: true,
            setIntrinsicHeightOnNavigationControllers: true))
        sheetVC.autoAdjustToKeyboard = true
        sheetVC.treatPullBarAsClear = true
        sheetVC.gripSize = CGSize.zero
        sheetVC.hasBlurBackground = false
        sheetVC.pullBarBackgroundColor = .clear
        sheetVC.gripColor = .clear
        sheetVC.treatPullBarAsClear = true
        sheetVC.contentBackgroundColor = .clear
        sheetVC.cornerRadius = 0.0
        self.present(sheetVC, animated: false, completion: nil)
    }
    
    
    @objc func onTapFollowUB() {
        buttonFollow.isSelected = !buttonFollow.isSelected
        if buttonFollow.isSelected {
            buttonFollow.backgroundColor = UIColor(named: "AppColor")
        } else {
            buttonFollow.backgroundColor = UIColor(named: "mainGreen")
        }
        CallWebSetFollow()
    }
    
    func CallWebserviceLike(){
        let Para =
            ["postid":"\(PostID!)","userid":"\(UserID!)","like_dislike_type":"\(LikeType!)"] as [String : Any]
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.LikePost)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["postVotes"]as? [String:Any]{
                                if let netVote = Data["netvotes"] as? String{
                                    self.labelLikeCount.text = netVote
                                    self.CallWebservicePostDetail()
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
    
    func CallWebSetFollow(){
        let Para =
            ["entityid":"\(IntityID!)","userid":"\(UserID!)"] as [String : Any]
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.setUserFollowing)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["postVotes"]as? [String:Any]{
                                if let netVote = Data["netvotes"] as? String{
                                    self.labelLikeCount.text = netVote
                                    
                                }
                            }
                        }
                        if self.buttonFollow.isHidden == false {
                            NotificationCenter.default.post(name: .didChangePostByFollowUser, object: nil, userInfo: ["removeUserID": self.IntityID!])
                        } else {
                            NotificationCenter.default.post(name: .didChangePostByFollowUser, object: nil)
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
    @IBAction func didTapButton() {
          showAlert()
  }
  
  func showAlert() {
    let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
    SharedManager.sharedInstance.otherProfile = "1"
    vc.isFromPostDetail = true
    vc.orginalPostData = [
        "origin_post_id": PostID!,
        "orgin_post_image": self.arrayPostDetail["post_image"]!,
        "orgin_post_title": self.arrayPostDetail["post_title"]!,
        "origin_post_created": self.arrayPostDetail["post_date"]!
    ]
    self.tabBarController?.tabBar.isHidden = false
    self.navigationController?.setNavigationBarHidden(false, animated: false)
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  func actionSheet() {
      
  }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension PostContentViewController: CommentBottomSheeetVCDelegate {
    func didTapUserProfile(targetVC: ProfilerootViewController) {
        self.navigationController?.pushViewController(targetVC, animated: true)
    }
    
    func didTapEditComment(targetVC: EditCommentViewController) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.hidesBottomBarWhenPushed = false
        self.navigationController?.pushViewController(targetVC, animated: true)
    }
    
    func didTapResponder(targetVC: MoreCommentsViewController) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.hidesBottomBarWhenPushed = false
        self.navigationController?.pushViewController(targetVC, animated: true)
    }
    
    func didTapmentionUser(targetVC: ProfilerootViewController) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.pushViewController(targetVC, animated: true)
    }
      
}
