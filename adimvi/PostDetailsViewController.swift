
//  PostDetailsViewController.swift

//  adimvi//  Created by javed carear  on 28/08/19.
//  Copyright © 2019 webdesky.com. All rights reserved.


import UIKit
import Alamofire
import SDWebImage
import GoogleMobileAds
import AVKit
import AVFoundation
import WebKit
import DropDown
import DPTagTextView

var viewedPostIDS: [String] = [String]()

let INTERSTIAL_AD = "ca-app-pub-6706097279662517/6807671419" //real
//let INTERSTIAL_AD = "ca-app-pub-3940256099942544/4411468910" //test

let NATIVE_AD = "ca-app-pub-6706097279662517/5715803797" //real
//let NATIVE_AD = "ca-app-pub-3940256099942544/3986624511" //test

class PostDetailsViewController: UIViewController {
    
    @IBOutlet weak var Scrollview: UIScrollView!
    @IBOutlet weak var labelVotas: UILabel!
    @IBOutlet weak var ViewMain: UIView!
    @IBOutlet weak var ApostTitle: UILabel!
    @IBOutlet weak var ImageAfterPurchase: UIImageView!
    @IBOutlet weak var APostPrice: UILabel!
    @IBOutlet weak var ACreditBlance: UILabel!
    @IBOutlet weak var topComment: NSLayoutConstraint!
    @IBOutlet weak var viewComments: UIView!
    @IBOutlet weak var buttonDeletePost: DesignableButton!
    @IBOutlet weak var buttonEditPost: UIButton!
    @IBOutlet weak var buttonOnReply: UIButton!
    @IBOutlet weak var buttonOffReply: UIButton!
    @IBOutlet weak var htbuttonCheck: NSLayoutConstraint!
    @IBOutlet weak var htbuttonComment: NSLayoutConstraint!
    @IBOutlet weak var htmail: NSLayoutConstraint!
    @IBOutlet weak var PriceView: UIView!
    @IBOutlet weak var Top: NSLayoutConstraint!
    @IBOutlet var MainView: UIView!
    @IBOutlet weak var collectionviewRelatedPost: UICollectionView!
    @IBOutlet weak var buttonSelectDislike: UIButton!
    @IBOutlet weak var buttonCheck: UIButton!
    @IBOutlet weak var buttonUncheck: UIButton!
    @IBOutlet weak var buttonNotFollow: UIButton!
    @IBOutlet weak var buttonFollow: UIButton!
    @IBOutlet weak var UnFavourite: UIButton!
    @IBOutlet weak var buttonFavourite: UIButton!
    @IBOutlet weak var buttonSelectLike: UIButton!
    @IBOutlet weak var buttonUnlikeDisable: UIButton!
    @IBOutlet weak var buttonlikeDisable: UIButton!
    @IBOutlet weak var ButtonLike: UIButton!
    @IBOutlet weak var OnDisLike: UIButton!
    @IBOutlet weak var PostImage: UIImageView!
    @IBOutlet weak var ProfieImage: UIImageView!
    @IBOutlet weak var labelViews: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelPostTitle: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var labelLikeCount: UILabel!
    @IBOutlet weak var UserPoints: UILabel!
    @IBOutlet weak var verifiedMarker: UIImageView!
    @IBOutlet weak var ViewShowPost: UIView!
    @IBOutlet weak var ButtonOnReport: UIButton!
    @IBOutlet weak var buttonOffReport: UIButton!
    @IBOutlet weak var htCommentView: NSLayoutConstraint!
    @IBOutlet weak var recentWallUV: UIView!
    @IBOutlet weak var postTitleAfterPurchase: UILabel!
    @IBOutlet weak var imagesAferPurchase: UIImageView!
    @IBOutlet weak var UpArrow: DesignableButton!
    @IBOutlet weak var DownArrow: DesignableButton!
    @IBOutlet weak var WebViewContent: UIWebView!
    @IBOutlet weak var labelMassageCount: UILabel!
    @IBOutlet var floatRatingView: FloatRatingView!
    @IBOutlet weak var destacarUB: UIButton!
    @IBOutlet weak var adViewHeight: NSLayoutConstraint!
    @IBOutlet weak var adPlaceholderUV: UIView!
    @IBOutlet weak var adPartUV: UIView!
    @IBOutlet weak var labelHeihgt: NSLayoutConstraint!
    @IBOutlet weak var userADIMG: UIImageView!
    @IBOutlet weak var videoPlayUB: UIButton!
    @IBOutlet weak var lightDarkUV: UIView!
    @IBOutlet weak var textViewComment: DPTagTextView!
    @IBOutlet weak var radiusUV: UIView!
    @IBOutlet weak var likeUV: UIView!
    
    var isShowLikeUV: Bool = false
    
    var selectMentionDropDown: DropDown = {
        let dropMenu = DropDown()
        dropMenu.backgroundColor = UIColor(named: "Posts")
        dropMenu.textColor = .label
        return dropMenu
    }()
    
    private var matchedList: [UserModel] = [] {
        didSet {
            handleDropDown()
        }
    }
    private var taggedList: [DPTag] = []
    
    @IBOutlet weak var thumbUB: UIButton!
    var PostStatus = "0"
    var CatID:String!
    var Balance:String!
    var UserID:String!
    var TitleCount = 0
    var DescriptionCount = 0
    var LikeType:String!
    var PostID:String!
    var IntityID:String!
    var arrayPostDetail =  [String: Any]()
    var arrayRelatedPost =  [[String: Any]]()
    let defaults = UserDefaults.standard
    var ShareLink:String!
    var UrlLink:String!
    var Rating:String!
    var LikeCount: String!
    var FollowStatus: String!
    var UserADLink: String?
    var videoUrl: String?
    var PostFav: String!
    var avatar: String!
    
    var ISENABLEAD: String?
    var ISENABLEDUSERAD: String?
    
    private var interstitialAD: GADInterstitialAd?
    private var nativeAdView: GADNativeAdView!
    var adLoader: GADAdLoader!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        floatRatingView.type = .halfRatings
        floatRatingView.delegate = self
        destacarUB.isHidden = true
        likeUV.isHidden = true
        radiusUV.layer.cornerRadius = 20.0
        radiusUV.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        UserID = UserDefaults.standard.string(forKey: "ID")
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.darkGray]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationItem.rightBarButtonItem = nil
        
        
        videoPlayUB.isHidden = !isShowLikeUV
        
        loadnterstialAD()
        guard
            let nibObjects = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil),
            let adView = nibObjects.first as? GADNativeAdView
        else {
            return
        }
        setAdView(adView)
        userADIMG.isUserInteractionEnabled = true
        userADIMG.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapUSERAD)))
        lightDarkUV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onShowFullImage)))
        
        initTagMention()
        
        selectMentionDropDown.cellNib = UINib(nibName: "MentionUserCell", bundle: nil)
        selectMentionDropDown.customCellConfiguration = { (index: Int, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? MentionUserCell else { return }
            if !self.matchedList[index].imageAvatar.isEmpty {
                let imageURl = "\(WebURL.ImageUrl)\(self.matchedList[index].imageAvatar)"
                cell.userImage.contentMode = .scaleAspectFill
                cell.userImage.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
            } else {
                cell.userImage.image = UIImage(named: "Splaceicon")
            }
        }
        selectMentionDropDown.selectionAction = {[unowned self] (index: Int, item: String) in
            textViewComment.addTag(tagText: item)
        }
    }
    
    func initTagMention() {
        textViewComment.dpTagDelegate = self
        textViewComment.setTagDetection(false)
        textViewComment.mentionSymbol = "@"
        textViewComment.allowsHashTagUsingSpace = true
        textViewComment.textViewAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)]
        textViewComment.mentionTagTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "AppColor")!, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14.0)]
    }
    
    func handleDropDown() {
        selectMentionDropDown.dismissMode = .onTap
        selectMentionDropDown.direction = .top
        selectMentionDropDown.width = 200
        selectMentionDropDown.dataSource = matchedList.map({ (user) -> String in
            user.name
        })
        selectMentionDropDown.anchorView = textViewComment
        selectMentionDropDown.topOffset = CGPoint(x: 0, y: -(selectMentionDropDown.anchorView?.plainView.bounds.height)!)
        if matchedList.count == 0 {
            selectMentionDropDown.hide()
        } else {
            selectMentionDropDown.show()
        }
        
    }
    
    @objc func onShowFullImage() {
        let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier:  "FullImageVC") as! FullImageVC
        vc.image = PostImage.image!
        present(vc, animated: true, completion: nil)
    }
    
    @objc func onTapUSERAD() {
        if var url = UserADLink {
            if !url.starts(with: "https://") || !url.starts(with: "http://")  {
                url = "http://\(url)"
            }
            guard let adurl = URL(string: url) else {
                return
            }
            UIApplication.shared.open(adurl)
        }
    }
    
    func loadNativeAD() {
        adLoader = GADAdLoader(
            adUnitID: NATIVE_AD, rootViewController: self,
            adTypes: [.native], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    func setAdView(_ view: GADNativeAdView) {
        // Remove the previous ad view.
        nativeAdView = view
        adPlaceholderUV.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout constraints for positioning the native ad view to stretch the entire width and height
        // of the nativeAdPlaceholder.
        let viewDictionary = ["_nativeAdView": nativeAdView!]
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
    }
    
    func loadnterstialAD() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID:INTERSTIAL_AD,
                               request: request,
                               completionHandler: { [self] ad, error in
                                if let error = error {
                                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                    return
                                }
                                interstitialAD = ad
                                interstitialAD!.fullScreenContentDelegate = self
                               }
        )
    }
    
    @IBAction func OnWallet(_ sender: Any) {
        let vc: WalletViewController = self.storyboard?.instantiateViewController(withIdentifier:"WalletViewController")as!  WalletViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func OnProfile(_ sender: Any) {
        self.defaults.set(IntityID, forKey: "OtherUserID")
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
//        vc.hidesBottomBarWhenPushed = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func OnCancel(_ sender: Any) {
        viewComments.isHidden = true
    }
    
    @IBAction func OnConfirm(_ sender: Any) {
        CallWebserviceDeletePost()
    }
    
    
    
    @IBAction func OnUpdate(_ sender: Any) {
        let popUpVC :ToPostVC = storyboard!.instantiateViewController(withIdentifier: "ToPostVC") as! ToPostVC
        popUpVC.Postid = PostID
        popUpVC.DraftPostId = PostID
        popUpVC.UpdatePost = "1"
        self.navigationController?.pushViewController(popUpVC, animated: true)
    }
    
    @IBAction func OnDelete(_ sender: Any) {
        viewComments.isHidden = false
        
    }
    
    @IBAction func OnReply(_ sender: UIButton) {
        if sender.tag == 1{
            buttonOnReply.isHidden = false
            buttonOffReply.isHidden = true
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.htCommentView.constant = 0
                self.htmail.constant = 0
                self.htbuttonComment.constant = 0
                self.htbuttonCheck.constant = 0
                self.view.layoutIfNeeded()
            })
        }
        if sender.tag == 2{
            buttonOnReply.isHidden = true
            buttonOffReply.isHidden = false
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.htCommentView.constant = 100
                self.htmail.constant = 30
                self.htbuttonComment.constant = 40
                self.htbuttonCheck.constant = 25
                self.view.layoutIfNeeded()
            })
            
        }
        
    }
    
    @IBAction func OnFlage(_ sender: UIButton) {
        if sender.tag == 1{
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                
                self.ButtonOnReport.isHidden = false
                self.buttonOffReport.isHidden = true
            })
        }
        if sender.tag == 2{
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.ButtonOnReport.isHidden = true
                self.buttonOffReport.isHidden = false
            })
        }
        
        CallWebserviceReports()
    }
    
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func OnShareFacebook(_ sender: Any) {
        let shareText = "\(ShareLink!)"
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        DispatchQueue.main.async() { () -> Void in
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func OnSeePost(_ sender: Any) {
        ViewShowPost.isHidden = true
        PriceView.isHidden = true
        Scrollview.isScrollEnabled = true
        UIView.animate(withDuration: 0.8, animations: { () -> Void in
            self.Top.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        CallWebservicePostDetail()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let now = df.string(from: Date())
        if let viewedDate = UserDefaults.standard.string(forKey: "viewDate") {
            if now == viewedDate {
                if viewedPostIDS.contains(PostID) {
                    return
                } else {
                    CallWebservicepostViewed()
                    viewedPostIDS.append(PostID)
                    UserDefaults.standard.setValue(now, forKey: "viewDate")
                }
            } else {
                viewedPostIDS.removeAll()
                CallWebservicepostViewed()
                viewedPostIDS.append(PostID)
                UserDefaults.standard.setValue(now, forKey: "viewDate")
            }
        } else {
            CallWebservicepostViewed()
            viewedPostIDS.append(PostID)
            UserDefaults.standard.setValue(now, forKey: "viewDate")
        }
        //loadNativeAD()
    }
    
    @IBAction func OnBuyPost(_ sender: Any) {
        if PostStatus == "0"{
            self.showAlert(strMessage:"\(Balance!)")
        }else{
            CallWebserviceBuyPost()
            ViewShowPost.isHidden = false
        }
        
    }
    
    @IBAction func OnDislike(_ sender: UIButton) {
        if sender.tag == 1 {
            LikeType = "0"
            ButtonLike.isHidden = true
            OnDisLike.isHidden = true
            buttonSelectDislike.isHidden = false
            buttonlikeDisable.isHidden = false
            CallWebserviceLike()
        }
        
        if sender.tag == 2{
            LikeType = "0"
            buttonSelectDislike.isHidden = true
            ButtonLike.isHidden = false
            OnDisLike.isHidden = false
            buttonlikeDisable.isHidden = true
            CallWebserviceLike()
        }
        
    }
    @IBAction func OnLikes(_ sender: UIButton) {
        if sender.tag == 1 {
            LikeType = "1"
            ButtonLike.isHidden = true
            OnDisLike.isHidden = true
            buttonSelectLike.isHidden = false
            buttonUnlikeDisable.isHidden = false
            CallWebserviceLike()
        }
        
        if sender.tag == 2{
            LikeType = "1"
            buttonSelectLike.isHidden = true
            ButtonLike.isHidden = false
            OnDisLike.isHidden = false
            buttonUnlikeDisable.isHidden = true
            CallWebserviceLike()
        }
        
    }
    
    @IBAction func OnFavourite(_ sender: UIButton) {
        if sender.tag == 1 {
            buttonFavourite.isHidden = false
            UnFavourite.isHidden = true
            CallWebserviceSetFavourite()
        }
        if sender.tag == 2 {
            buttonFavourite.isHidden = true
            UnFavourite.isHidden = false
            CallWebserviceSetFavourite()
        }
    }
    
    @IBAction func didTapThumbUB(_ sender: Any) {
        isShowLikeUV = !isShowLikeUV
        likeUV.isHidden = !isShowLikeUV
    }
    
    @IBAction func OnMoreButton(_ sender: UIButton) {
        if ISENABLEAD == "1" {
            showPostContentViewController()
        } else {
            if interstitialAD != nil {
                interstitialAD!.present(fromRootViewController: self)
            } else {
                print("AD was not ready")
                loadnterstialAD()
            }
        }
//        showPostContentViewController()
        
    }
    
    func showPostContentViewController() {
        let vc: PostContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostContentViewController")as!PostContentViewController
        vc.UrlLink = UrlLink
        vc.LikeCount = LikeCount
        vc.UserID = UserID
        vc.FollowStatus = FollowStatus
        vc.ShareLink = ShareLink
        vc.PostID = PostID
        vc.IntityID = IntityID
        vc.PostFav = PostFav
        vc.avatar = avatar
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    @IBAction func OnCheckMail(_ sender: UIButton) {
        if sender.tag == 1 {
            buttonCheck.isHidden = false
            buttonUncheck.isHidden = true
        }
        if sender.tag == 2 {
            buttonCheck.isHidden = true
            buttonUncheck.isHidden = false
        }
    }
    func CallWebserviceDeletePost(){
        let Para =
            ["postid":"\(PostID!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.postDelete)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        self.viewComments.isHidden = true
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
    
    func CallWebserviceSetFavourite() {
        objActivity.startActivityIndicator()
        let params = ["userid":"\(UserID!)","postid":"\(PostID!)"] as [String: Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.setfavourite)"
        Alamofire.request(Api, method: .post,parameters:params)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["code"] as? String{
                            print(arr)
                        }
                        
                        
                        objActivity.stopActivity()
                        
                        let actionSheetController: UIAlertController = UIAlertController(title: "Guardado", message: "Este post se ha guardado en tus favoritos.", preferredStyle: .alert)
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) { action -> Void in
                        }
                        actionSheetController.addAction(cancelAction)
                        self.present(actionSheetController, animated: true, completion: nil)
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
                                self.CallWebserviceRelatedPost()
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
    func PostDetails()  {
        if let extra = self.arrayPostDetail["post_extra_image"] as? NSArray {
            if extra.count == 0 {
                videoPlayUB.isHidden = true
            } else {
                if let Url = extra[0] as? [String: Any] {
                    if let vUrl = Url["url0"] as? String {
                        if vUrl.hasSuffix(".jpg") || vUrl.hasSuffix(".png") || vUrl.hasSuffix(".jpeg") {
                            videoPlayUB.isHidden = true
                        } else {
                            videoUrl = vUrl
                            videoPlayUB.isHidden = false
                        }
                        
                    } else {
                        videoPlayUB.isHidden = true
                    }
                } else {
                    videoPlayUB.isHidden = true
                }
            }
        } else {
            videoPlayUB.isHidden = true
        }
        if let isenableAd = self.arrayPostDetail["adimvi_promotions"] as? String {
            ISENABLEAD = isenableAd
        }
        
        if let isuserad = self.arrayPostDetail["promotional_image"] as? String {
            ISENABLEDUSERAD = isuserad
        }
        
        if let adLink = self.arrayPostDetail["uadimglink"] as? String {
            self.UserADLink = adLink
        }
        
        if let verify = self.arrayPostDetail["verify"] as? String {
            verifiedMarker.isHidden = verify == "1" ? false : true
        }
        if let PostTitle = self.arrayPostDetail["post_title"]
            as? String{
            TitleCount = PostTitle.count
            self.labelPostTitle.text = PostTitle
            
            self.ApostTitle.text = PostTitle
            self.postTitleAfterPurchase.text = PostTitle
            
        }
        
        if let Rating = arrayPostDetail["userRating"] as? Double {
            self.floatRatingView.rating = Rating
        }
        
        if let Votas = arrayPostDetail["ratingVotes"] as? String {
            self.labelVotas.text = Votas
        }
        
        if let Pricer = arrayPostDetail["pricer"] as? String {
            let Postuser = self.arrayPostDetail["userid"]
                as! String
            if Pricer == "1"&&UserID != Postuser{
                self.PriceView.isHidden = false
                Scrollview.isScrollEnabled = false
            }else{
                self.PriceView.isHidden = true
                Scrollview.isScrollEnabled = true
                Top.constant = 0
                print(TitleCount)
            }
        }
        
        if let Pricer = arrayPostDetail["pricer"] as? String {
            let Buy = arrayPostDetail["post_buy"] as! String
            if Pricer == "1"&&Buy == "1" {
                self.PriceView.isHidden = true
                Top.constant = 0
                Scrollview.isScrollEnabled = true
            }
        }
        if ISENABLEAD == "1" {
            if ISENABLEDUSERAD == "0" {
                labelHeihgt.constant = 0.0
                adPartUV.isHidden = true
                adPlaceholderUV.isHidden = true
                userADIMG.isHidden = true
            } else {
                adPartUV.isHidden = false
                labelHeihgt.constant = 40.0
                adPlaceholderUV.isHidden = true
                userADIMG.isHidden = false
                loadNativeAD()
            }
        } else {
            adPartUV.isHidden = false
            labelHeihgt.constant = 40.0
            if ISENABLEDUSERAD == "0" {
                adPlaceholderUV.isHidden = false
                userADIMG.isHidden = true
                loadNativeAD()
            } else {
                adPlaceholderUV.isHidden = true
                userADIMG.isHidden = false
                loadNativeAD()
            }
        }
        
        if let userAD = arrayPostDetail["uadblobid"] as? String {
            let imageURl = "\(WebURL.ImageUrl)\(userAD)"
            userADIMG.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        } else {
            userADIMG.image = UIImage(named: "Splaceicon")
        }
        
        if let username = self.arrayPostDetail["username"]
            as? String{
            self.labelUserName.text = username
        }
        if let PostTitle = self.arrayPostDetail["price"]
            as? String{
            // self.labelPostPrice.text = PostTitle
            self.APostPrice.text = PostTitle
            
        }
        if let PostTitle = self.arrayPostDetail["credit"]
            as? String{
            // self.labelCurrentbalance.text = PostTitle
            self.ACreditBlance.text = PostTitle
        }
        
        if let Post = self.arrayPostDetail["post_purchase"]
            as? String{
            PostStatus = Post
            
        }
        if let Link = self.arrayPostDetail["webViewLink"]
            as? String{
            WebViewContent.loadRequest(URLRequest(url: URL(string: "\(Link)")!))
        }
        
        if let PostLink = self.arrayPostDetail["postLink"]
            as? String{
            UrlLink = PostLink
        }
        
        if  let profilePic = arrayPostDetail["avatarblobid"] as? String{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            avatar = imageURl
            ProfieImage.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        } else {
            ProfieImage.image = UIImage(named: "Splaceicon")
        }
        if let hasRecentPost = arrayPostDetail["hasRecentPost"] as? Int {
            if hasRecentPost == 1{
                if (arrayPostDetail["userid"] as! String) != UserID {
                    recentWallUV.backgroundColor = UIColor(named: "AppColor")!
                } else {
                    recentWallUV.backgroundColor = UIColor(named: "White (dark mode)")!
                }
            } else {
                recentWallUV.backgroundColor = UIColor(named: "White (dark mode)")!
            }
        }
        
        if let postimg = self.arrayPostDetail["post_image"]
            as? String{
            PostImage.sd_setImage(with: URL(string: postimg), placeholderImage: UIImage(named: "Place.png"))
            
            imagesAferPurchase.sd_setImage(with: URL(string: postimg), placeholderImage: UIImage(named: "Place.png"))
            
            ImageAfterPurchase.sd_setImage(with: URL(string: postimg), placeholderImage: UIImage(named: "Place.png"))
        }
        
        if let Date = self.arrayPostDetail["post_date"]
            as? String{
            self.labelDate.text = Date
        }
        if let Time = self.arrayPostDetail["post_created"]
            as? String{
            self.labelTime.text = Time
        }
        
        if let Link = self.arrayPostDetail["share_link"]
            as? String{
            ShareLink = Link
        }
        
        if let Amt = self.arrayPostDetail["credit_msg"]
            as? String{
            Balance = Amt
        }
        if let Massage = self.arrayPostDetail["total_comment"]
            as? String{
            labelMassageCount.text = "\(Massage) comentarios"
        }
        if let PostTime = self.arrayPostDetail["views"]
            as? String{
            self.labelViews.text = "\(PostTime) Visitas"
        }
        
        if let CatId = self.arrayPostDetail["categoryid"]
            as? String{
            CatID = CatId
        }
        if let UId = self.arrayPostDetail["userid"]
            as? String{
            IntityID = UId
        }
        if IntityID == UserID {
            buttonEditPost.isHidden = false
            buttonDeletePost.isHidden = false
        }else{
            buttonEditPost.isHidden = true
            buttonDeletePost.isHidden = true
        }
        
        if let PostLikeCount = self.arrayPostDetail["netvotes"]
            as? String{
            self.LikeCount = PostLikeCount
            self.labelLikeCount.text = PostLikeCount
        }
        
        if let FavouriteStatus = self.arrayPostDetail["post_favourite"]
            as? String{
            PostFav = FavouriteStatus
            if FavouriteStatus == "1"{
                buttonFavourite.isHidden = false
                UnFavourite.isHidden = true
            }else{
                buttonFavourite.isHidden = true
                UnFavourite.isHidden = false
            }
        }
        
        if let LikeType = self.arrayPostDetail["like_dislike_type"]
            as? String{
            print(LikeType)
            self.LikeType = LikeType
            ButtonLike.isHidden = true
            OnDisLike.isHidden = true
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
                ButtonLike.isHidden = false
                OnDisLike.isHidden = false
                thumbUB.imageView!.tintColor = UIColor(named: "Dark grey (Dark mode)")
            }
        }
        
        if let FollowStatus = self.arrayPostDetail["post_followup"]
            as? String{
            self.FollowStatus = FollowStatus
            if FollowStatus == "1"{
                buttonNotFollow.isHidden = false
                buttonFollow.isHidden = true
            }else{
                buttonNotFollow.isHidden = true
                buttonFollow.isHidden = false
            }
            
        }
        
        if arrayPostDetail["userid"] as? String == UserID {
            destacarUB.isHidden = false
            buttonFollow.isHidden = true
            buttonNotFollow.isHidden = true
            
        } else {
            if let FollowStatus = self.arrayPostDetail["post_followup"]
                as? String{
                self.FollowStatus = FollowStatus
                if FollowStatus == "1"{
                    buttonNotFollow.isHidden = false
                    buttonFollow.isHidden = true
                }else if FollowStatus == "0"{
                    buttonNotFollow.isHidden = true
                    buttonFollow.isHidden = false
                }
            }
            destacarUB.isHidden = true
        }
        
    }
    
    @IBAction func OnAddComment(_ sender: Any) {
        let Comments = textViewComment.text
        
        if (Comments!.isEmpty) {
            self.showAlert(strMessage:
                            "Por favor, escribe un comentario.")
            return
        }
        CallWebAddComment()
    }
    
    @IBAction func onTapDestacarUB(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddFeaturePostVC") as! AddFeaturePostVC
        self.navigationItem.backButtonTitle = ""
        vc.postInfo = arrayPostDetail
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func OnSeeComment(_ sender: Any) {
        let vc:CommentListViewController = self.storyboard?.instantiateViewController(withIdentifier: "CommentListViewController") as!CommentListViewController
        vc.PostID = PostID
        self.navigationController?.pushViewController(vc, animated: true)
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
                                    self.LikeCount = netVote
                                    self.CallWebservicePostDetail()
                                }
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
    
    func CallWebserviceReports(){
        let Para =
            ["postid":"\(PostID!)","userid":"\(UserID!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.setPostReport)"
        Alamofire.request(Api, method: .post,parameters:Para)
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
    
    func showAlert(strMessage:String) ->() {
        let actionSheetController: UIAlertController = UIAlertController(title: "Mensaje", message: strMessage, preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
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
    
    func CallWebAddComment(){
        var mentionedUsr: [String] = [String]()
        taggedList.forEach { (tag) in
            mentionedUsr.append(tag.name)
        }
        print(mentionedUsr.joined(separator: ","))
        let Para =
            ["postid":"\(PostID!)","userid":"\(UserID!)","categoryid":"\(CatID!)","comment":"\(textViewComment.text!)","type":"A", "mentions": mentionedUsr.joined(separator: ",")] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.postComment)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        _ = response.result.value as! [String :Any]
                        self.CallWebservicePostDetail()
                        let actionSheetController: UIAlertController = UIAlertController(title: "Nuevo comentario", message: "¡Tu comentario ha sido añadido!", preferredStyle: .alert)
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) { action -> Void in
                        }
                        actionSheetController.addAction(cancelAction)
                        self.present(actionSheetController, animated: true, completion: nil)
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
    
    @IBAction func onTapVideoPlayerUB(_ sender: Any) {
        if let url = videoUrl {
            let webView = WKWebView()
            webView.load(URLRequest(url: URL(string: url)!))
            
            let vc = UIViewController()
            vc.view.addSubview(webView)
            webView.frame = CGRect(x: 0.0, y: 0.0, width: vc.view.frame.width, height: vc.view.frame.height)
            self.present(vc, animated: true, completion: nil)
        } else {
            return
        }
    }
    
}
// Mark:- Collection view data source and layout menthods
extension PostDetailsViewController:UICollectionViewDataSource,UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayRelatedPost.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionviewRelatedPost.dequeueReusableCell(withReuseIdentifier: "RelatedPostViewCell", for: indexPath) as! RelatedPostViewCell
        let dictData = self.arrayRelatedPost[indexPath.row]
        if indexPath.row == arrayRelatedPost.count - 1 {
            cell.trailingSize.constant = 8.0
        } else {
            cell.trailingSize.constant = 0.0
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
        if let profilePic = dictData["avatarblobid"] as? String{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            cell.userImage.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        } else {
            cell.userImage.image = UIImage(named: "Splaceicon")
        }
        if let Title = dictData["post_title"] as? String{
            cell.labelpostTitle.text = Title
        }
        if let Views = dictData["total_message"] as? String{
            cell.buttonMassage.setTitle(Views, for: .normal)
        }
        if let Views = dictData["post_time"] as? String{
            cell.buttonTime.setTitle(Views, for: .normal)
        }
        if let Views = dictData["netvotes"] as? String{
            cell.buttonLike.setTitle(Views, for: .normal)
        }
        if let PostContent = dictData["shortPostLink"] as? String {
            cell.webviewContent.backgroundColor = .clear
            cell.webviewContent.isOpaque = false
            cell.webviewContent.loadRequest(URLRequest(url: URL(string: "\(PostContent)")!))            
        }
        if let Image = dictData["post_image"] as? String{
            cell.postImage.sd_setImage(with: URL(string: Image), placeholderImage: UIImage(named: "Place.png"))
        }
        cell.buttonTap.tag = indexPath.row
        cell.buttonTap.addTarget(self, action: #selector(self.OnPost(_:)), for: UIControl.Event.touchUpInside)
        return cell
    }
    
    @objc func OnPost(_ sender : UIButton) {
        let dict = self.arrayRelatedPost[sender.tag]
        let post = dict["postid"] as! String
        PostID = post
        SharedManager.sharedInstance.PostId = post
        NotificationCenter.default.post(name: Notification.Name("reloadTag"), object: nil, userInfo: dict)
        CallWebservicePostDetail()
    }
    
    func CallWebserviceRelatedPost(){
        let Para =
            ["userid":"\(UserID!)","postid":"\(PostID!)",
             "categoryid":"\(CatID!)"
            ] as [String : Any]
        let myService:String = "\(WebURL.BaseUrl)\(WebURL.relatedPostByCategory)"
        objActivity.startActivityIndicator()
        Alamofire.request(myService, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["posts"]as? [[String:Any]]{
                                self.arrayRelatedPost = Data
                                self.collectionviewRelatedPost.reloadData()
                            }
                        }
                        objActivity.stopActivity()
                    }
                    objActivity.stopActivity()
                    break
                case .failure(_):
                    print(response.result.error as Any)
                    break
                }
            }
    }
    
    func CallWebserviceBuyPost(){
        let Para =
            ["buyer":"\(UserID!)","postid":"\(PostID!)",
             "seller":"\(IntityID!)","price":"\(APostPrice.text!)"
            ] as [String : Any]
        let myService:String = "\(WebURL.BaseUrl)\(WebURL.buyPost)"
        objActivity.startActivityIndicator()
        Alamofire.request(myService, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        self.PriceView.isHidden = true
                        self.Top.constant = -1850
                        objActivity.stopActivity()
                    }
                    objActivity.stopActivity()
                    break
                case .failure(_):
                    print(response.result.error as Any)
                    break
                }
            }
    }
    
    func CallWebservicepostViewed(){
        let Para =
            ["postid":"\(PostID!)"
            ] as [String : Any]
        let myService:String = "\(WebURL.BaseUrl)\(WebURL.postViewed)"
        Alamofire.request(myService, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        
                    }
                    break
                case .failure(_):
                    print(response.result.error as Any)
                    break
                }
            }
    }
}

extension PostDetailsViewController: FloatRatingViewDelegate {
    
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating: Double) {
        Rating = String(format: "%.1f", self.floatRatingView.rating)
        CallWebserviceRating()
    }
    
    func CallWebserviceRating(){
        let Para =
            ["postid":"\(PostID!)","userid":"\(UserID!)","rating":"\(Rating!)"] as [String : Any]
        let myService:String = "\(WebURL.BaseUrl)\(WebURL.addRating)"
        Alamofire.request(myService, method:.post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        let alert = self.storyboard?.instantiateViewController(withIdentifier: "SetVotePostVC") as! SetVotePostVC
                        self.present(alert, animated: true, completion: nil)
                        debugPrint(response.result)
                        self.CallWebservicePostDetail()
                    }
                    break
                case .failure(_):
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
        vc.hidesBottomBarWhenPushed = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PostDetailsViewController: GADFullScreenContentDelegate{
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        loadnterstialAD()
    }
    
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        loadnterstialAD()
        showPostContentViewController()
    }
}

extension PostDetailsViewController: GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        _ = nativeAd.mediaContent
        if let mediaView = nativeAdView.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
            adViewHeight = NSLayoutConstraint(
                item: mediaView,
                attribute: .height,
                relatedBy: .equal,
                toItem: mediaView,
                attribute: .width,
                multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
                constant: 0)
            adViewHeight?.isActive = true
        }
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil
        nativeAdView.starRatingView?.isHidden = true
        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        nativeAdView.storeView?.isHidden = nativeAd.store == nil
        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        nativeAdView.priceView?.isHidden = nativeAd.price == nil
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        nativeAdView.nativeAd = nativeAd
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("failed")
        
    }
}

extension PostDetailsViewController: DPTagTextViewDelegate {
    func dpTagTextView(_ textView: DPTagTextView, didChangedTagSearchString strSearch: String, isHashTag: Bool) {
        matchedList = allMentionUsers.filter({ (user) -> Bool in
            return user.name.lowercased().contains(strSearch.lowercased())
        })
    }
    
    func dpTagTextView(_ textView: DPTagTextView, didInsertTag tag: DPTag) {
        taggedList.append(tag)
    }
    
    func dpTagTextView(_ textView: DPTagTextView, didRemoveTag tag: DPTag) {
        if let index = taggedList.firstIndex(where: { (item) -> Bool in
            return item.id == tag.id
        }) {
            taggedList.remove(at: index)
        }
    }
}
