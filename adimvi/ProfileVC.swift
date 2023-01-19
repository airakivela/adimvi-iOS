
//  ProfileVC.swift
//  adimvi
//  Created by javed carear  on 20/06/19.
//  Copyright © 2019 webdesky.com. All rights reserved.

import UIKit
import Alamofire
import SDWebImage


var profileVCInstatnce = ProfileVC()

protocol ProfileVCDelegate {
    func didFinishUserName(name: String, verify: String)
}

class ProfileVC: BaseViewController{
    @IBOutlet weak var viewFollow: UIView!
    @IBOutlet weak var buttonPrivateMassage: UIButton!
    @IBOutlet weak var htUserStack: NSLayoutConstraint!
    @IBOutlet weak var buttonSatting: UIButton!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var ViewRightmenu: UIView!
    @IBOutlet weak var buttonFollow: UIButton!
    @IBOutlet weak var buttonNotFollow: UIButton!
    @IBOutlet weak var imgbackgroundimage: UIImageView!
    @IBOutlet weak var labelPosts: UILabel!
    @IBOutlet weak var labelPositiveVote: UILabel!
    @IBOutlet weak var labelReply: UILabel!
    @IBOutlet weak var labelFollowers: UILabel!
    @IBOutlet weak var labelFollowing: UILabel!
    var ProfileType:String!
    var UserName:String!
    var UserImage:String!
    var userId:String!
    var LoginUsers:String!
    var OtherUsers:String!
    var WallType:String!
    @IBOutlet weak var covermageView: UIView!
    var arrayProfile = [[String: Any]]()
    @IBOutlet weak var viewSettingbutton: UIView!
    var lastProgress: CGFloat = .zero
    var lastMinHeaderHeight: CGFloat = .zero
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    private var animator: UIViewPropertyAnimator?
    var titleInitialCenterY: CGFloat!
    var covernitialCenterY: CGFloat!
    var covernitialHeight: CGFloat!
    var stickyCover = true
    var isFromPostDetail: Bool = false
    var flags: String!
    @IBOutlet weak var coverImageHeightConstraint: NSLayoutConstraint!
    var viewDidLayoutOnce = false
    
    var delegate: ProfileVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator = blurAnimator()
        imgProfile.layer.zPosition = 0.1
        visualEffectView.layer.zPosition = imgProfile.layer.zPosition + 0.1
        LoginUsers = UserDefaults.standard.string(forKey: "ID")
        ProfileType = SharedManager.sharedInstance.otherProfile
        if  ProfileType == "1"{
            if isFromPostDetail || ISREWALL {
                userId = UserDefaults.standard.string(forKey: "ID")
            } else {
                userId = UserDefaults.standard.string(forKey: "OtherUserID")
            }
            buttonFollow.isHidden = false
            viewFollow.isHidden = false
            viewSettingbutton.isHidden = true
            if LoginUsers! == userId! {
                buttonFollow.isHidden = true
                viewSettingbutton.isHidden = false
                viewFollow.isHidden = true
            }
        }else{
            userId = UserDefaults.standard.string(forKey: "ID")
            buttonFollow.isHidden = true
            viewSettingbutton.isHidden = false
            viewFollow.isHidden = true
        }
        OtherUsers = UserDefaults.standard.string(forKey: "OtherUserID")
        CallWebserviceGetProfile()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        
        imgProfile.layer.cornerRadius = imgProfile.frame.height/2
        imgProfile.clipsToBounds = true
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.darkGray]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        profileVCInstatnce = self
        addBlurAnimation()
        update(with: lastProgress, minHeaderHeight: lastMinHeaderHeight)
        CallWebserviceGetProfile()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetAnimator()
    }
    
    @IBAction func onTapTest(_ sender: Any) {
        print("123456")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !viewDidLayoutOnce{
            viewDidLayoutOnce = true
            covernitialCenterY = covermageView.center.y
            covernitialHeight = covermageView.frame.height
        }
    }
    
    private func blurAnimator() -> UIViewPropertyAnimator{
        visualEffectView.effect = nil
        return UIViewPropertyAnimator(duration: 0.5, curve: .linear)
    }
    
    private func addBlurAnimation(){
        animator?.addAnimations {[weak visualEffectView] in
            visualEffectView?.effect = UIBlurEffect(style: .regular)
        }
        animator?.stopAnimation(true)
    }
    
    private func resetAnimator(){
        if animator?.state == .active {
            animator?.stopAnimation(false)
        }
        if animator?.state == .stopped {
            animator?.finishAnimation(at: .current)
        }
        visualEffectView.effect = nil
    }
    
    @objc func appWillEnterForeground(){
        addBlurAnimation()
        update(with: lastProgress, minHeaderHeight: lastMinHeaderHeight)
    }
    
    @objc func appDidEnterBackground(){
        resetAnimator()
    }
    
    @IBAction func OnTags(_ sender: Any) {
        let vc: MostPopularTagViewController = self.storyboard?.instantiateViewController(withIdentifier:"MostPopularTagViewController")as!MostPopularTagViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func OnFollow(_ sender: UIButton) {
        if sender.tag == 1{
            buttonFollow.isHidden = true
            buttonNotFollow.isHidden = false
            CallWebSetFollow()
        }
        if sender.tag == 2{
            buttonFollow.isHidden = false
            buttonNotFollow.isHidden = true
            CallWebSetFollow()
        }
    }
    
    @IBAction func OnPrivateMassage(_ sender: Any) {
        let vc: PrivateMassageListViewController = self.storyboard?.instantiateViewController(withIdentifier:"PrivateMassageListViewController")as!PrivateMassageListViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func OnWriteMenu(with tag: Int){
        if(tag == 1){
            visualEffectView.effect = nil
            ViewRightmenu.isHidden = false
        } else {
            visualEffectView.effect = nil
            ViewRightmenu.isHidden = true
        }
    }
    
    @IBAction func OnLogout(_ sender: Any) {
        SharedManager.sharedInstance.resetAllData()
        let vc: LoginVC = self.storyboard?.instantiateViewController(withIdentifier:"LoginVC")as!LoginVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func OnSatting(_ sender: Any) {
        let vc: AccountViewController = self.storyboard?.instantiateViewController(withIdentifier:"AccountViewController")as!AccountViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        ViewRightmenu.isHidden = true
    }
    
    func CallWebserviceGetProfile(){
        objActivity.startActivityIndicator()
        let Para =
            ["userid":"\(userId!)","login_userid":"\(LoginUsers!)"
            ] as [String : Any]
        print(Para)
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
                            self.delegate?.didFinishUserName(name: data["username"] as! String, verify: data["isVerify"] as! String)
                            if let Post = data["totalPost"]as? String{
                                self.labelPosts.text = Post
                            }
                            if let Votes = data["positiveVotes"]as? String{
                                self.labelPositiveVote.text = Votes
                            }
                            if let Replies = data["totalReply"]as? String{
                                self.labelReply.text = Replies
                            }
                            if let Followers = data["totalFollowers"]as? String{
                                self.labelFollowers.text = Followers
                            }
                            if let Following = data["totalFollowing"]as? String{
                                self.labelFollowing.text = Following
                            }
                            if  let profilePic = data["avatarblobid"] as? String{
                                let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                                self.imgProfile.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
                            } else {
                                self.imgProfile.image = UIImage(named: "Splaceicon")
                            }
                            if  let profilePic = data["coverblobid"] as? String{
                                let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                                self.imgbackgroundimage.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "ProBackground.png"))
                            }
                            if self.ProfileType == "1" {
                                if let FavouriteStatus = data["followup"]
                                    as? String{
                                    if FavouriteStatus == "1" {
                                        self.buttonFollow.isHidden = true
                                        self.buttonNotFollow.isHidden = false
                                    }else{
                                        self.buttonFollow.isHidden = false
                                        self.buttonNotFollow.isHidden = true
                                    }
                                }
                            }
                            if let flags = data["flags"] as? String {
                                self.flags = flags
                            } else {
                                self.flags = ""
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
    
    func CallWebSetFollow(){
        let Para =
            ["entityid":"\(OtherUsers!)","userid":"\(LoginUsers!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.setUserFollowing)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["postVotes"]as? [String:Any]{
                                if (Data["netvotes"] as? String) != nil{
                                }
                            }
                        }
                        if self.buttonFollow.isHidden == false {
                            NotificationCenter.default.post(name: .didChangePostByFollowUser, object: nil, userInfo: ["removeUserID": self.OtherUsers!])
                        } else {
                            NotificationCenter.default.post(name: .didChangePostByFollowUser, object: nil)
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
    
    func update(with progress: CGFloat, minHeaderHeight: CGFloat){
        lastProgress = progress
        lastMinHeaderHeight = minHeaderHeight
        let y = progress * (view.frame.height - minHeaderHeight)
        guard covernitialHeight != nil else {
            return
        }
        coverImageHeightConstraint.constant = max(covernitialHeight, covernitialHeight - y)
        if progress < 0 {
            animator?.fractionComplete = abs(min(0, progress))
        }else{
            
        }
        
        let topLimit = covernitialHeight - minHeaderHeight
        if y > topLimit{
            covermageView.center.y = covernitialCenterY + y - topLimit
            if stickyCover{
                self.stickyCover = false
            }
        }else{
            covermageView.center.y = covernitialCenterY
            let scale = min(1, (1-progress*1.3))
            _ = CGAffineTransform(scaleX: scale, y: scale)
            if !stickyCover{
                self.stickyCover = true
            }
        }
        visualEffectView.center.y = covermageView.center.y
    }
    
}

