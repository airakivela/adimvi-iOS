
//  WallPostViewController.swift
//  adimvi
//  Created by javed carear  on 17/10/19.
//  Copyright © 2019 webdesky.com. All rights reserved.

import UIKit
import Alamofire
import SwiftyJSON
import XLPagerTabStrip
import WSTagsField
import IQKeyboardManagerSwift
import StoreKit
import GrowingTextView

var ISREWALL: Bool = false
var isFromOriginRemuro: Bool = false
var ORIGINWALLDATA: [String: Any] = [String: Any]()

class WallPostViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var textviewComments: GrowingTextView!
    @IBOutlet weak var uploadImage: UIImageView!
    @IBOutlet weak var htVideo: NSLayoutConstraint!
    @IBOutlet weak var htTag: NSLayoutConstraint!
    @IBOutlet weak var viewComments: UIView!
    @IBOutlet weak var tagField: WSTagsField!
    let defaults = UserDefaults.standard
    var arrayCommentsList =  [[String: Any]]()
    @IBOutlet weak var tableviewWall: UITableView!
    
    @IBOutlet weak var originPostContent: UIImageView!
    @IBOutlet weak var originPostTitle: UILabel!
    @IBOutlet weak var originPostTime: UILabel!
    @IBOutlet weak var originPostUV: UIView!
    @IBOutlet weak var originPostUVHeight: NSLayoutConstraint!
    @IBOutlet weak var originPostUVTopSpacing: NSLayoutConstraint!
    @IBOutlet weak var originWallUV: UIView!
    @IBOutlet weak var originWallUserAvatar: UIImageView!
    @IBOutlet weak var originWallUserName: UILabel!
    @IBOutlet weak var originWallCreatedTime: UILabel!
    @IBOutlet weak var originWallContent: UILabel!
    @IBOutlet weak var originWallUserVerified: UIImageView!
    @IBOutlet weak var originWallExtra: UIImageView!
    @IBOutlet weak var originWallExtraHeight: NSLayoutConstraint!
    @IBOutlet weak var tagHeight: NSLayoutConstraint!
    @IBOutlet weak var tagCloseHeight: NSLayoutConstraint!
    @IBOutlet weak var deniedMuroUV: UIView!
    @IBOutlet weak var parentSV: UIScrollView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var goingUp: Bool?
    var childScrollingDownDueToParent = false
    
    var productid = ["MD199"]
    var products: [SKProduct] = [SKProduct]()
    
    var isCloseHeight: Bool = false
    var imagePicker = UIImagePickerController()
    var touserid:String!
    var LoginId:String!
    var MessageId:String!
    var EditType:String!
    var ProfileType:String!
    var Imagename:UIImage!
    var ImageStatus = "0"
    var pageIndex: Int = 0
    var pageTitle: String?
    var isFromPostDetail: Bool = false
    var originalPostData: [String: Any] = [String: Any]()
    var purchsaseMessageID: String = ""
    var purchaseMessageIndex: Int!
    
    var onTappedRemuro: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SKPaymentQueue.default().add(self)
        if (SKPaymentQueue.canMakePayments()) {
            let productID:Set = Set(productid)
            let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID)
            productsRequest.delegate = self
            productsRequest.start()
            
        } else {
            print("can't make purchases")
        }
        
        tableViewHeight.constant = 0.0
        tableviewWall.estimatedRowHeight = UITableView.automaticDimension
        tableviewWall.rowHeight = UITableView.automaticDimension
        tableviewWall.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textviewComments.delegate = self
        
        self.tableviewWall.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        tagHeight.constant = 0.0
        tagCloseHeight.constant = 0.0
        tagField.layoutMargins = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        tagField.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tagField.spaceBetweenLines = 5.0
        tagField.spaceBetweenTags = 10.0
        tagField.font = .systemFont(ofSize: 14.0)
        tagField.backgroundColor = .white
        tagField.tintColor = UIColor(named: "Light grey (Dark mode)")
        tagField.selectedColor = .clear
        tagField.selectedTextColor = .lightGray
        tagField.textColor = .lightGray
        tagField.placeholderColor = .lightGray
        tagField.placeholderAlwaysVisible = true
        tagField.placeholder = "Etiquetas"
        tagField.returnKeyType = .next
        tagField.acceptTagOption = .space
        tagField.shouldTokenizeAfterResigningFirstResponder = true
        
        tagField.onValidateTag = {tag, tags in
            return !tags.contains(where: {$0.text.lowercased() == tag.text.lowercased()})
        }
        
        tagField.onDidChangeHeightTo = {_, height in
            if self.isCloseHeight {
                self.tagHeight.constant = 0.0
                return
            }
            self.tagHeight.constant = height
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let obj = object as? UITableView {
            if obj == self.tableviewWall && keyPath == "contentSize" {
                if let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize {
                    self.tableViewHeight.constant = newSize.height - self.view.frame.height + 30
                }
            }
        }
    }
    
    @IBAction func onTapCloseTag(_ sender: Any) {
        closeTag()
    }
    
    func closeTag() {
        tagHeight.constant = 0.0
        tagCloseHeight.constant = 0.0
        isCloseHeight = true
        tagField.text = ""
        tagField.removeTags()
    }
    
    @IBAction func onTapHashTag(_ sender: Any) {
        isCloseHeight = false
        tagHeight.constant = 30.0
        tagCloseHeight.constant = 30.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableviewWall.isScrollEnabled = false
        print("ISREWALL======>\(ISREWALL)")
        IQKeyboardManager.shared.enable = false
        NotificationCenter.default.addObserver(self, selector: #selector(didAppearKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDisappearKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        ProfileType = SharedManager.sharedInstance.otherProfile
        handleUV()
        LoginId = UserDefaults.standard.string(forKey: "ID")
        CallWebserviceCommentList()
    }
    
    @objc func didAppearKeyboard(notification: Notification) {
        if self.view.superview?.superview != nil {
            let view = self.view.superview?.superview?.superview
            if view!.isKind(of: UIScrollView.self) {
                print("123456")
                let scrollUV = view as? UIScrollView
                let topInset = CGPoint(x: 0, y: (scrollUV?.contentInset.top)! + profileVCInstatnce.view.frame.height)
                scrollUV?.setContentOffset(topInset, animated: true)
            }
        }
    }
    
    @objc func didDisappearKeyboard() {
        if self.view.superview?.superview != nil {
            let view = self.view.superview?.superview?.superview
            if view!.isKind(of: UIScrollView.self) {
                print("123456")
                let scrollUV = view as? UIScrollView
                let topInset = CGPoint(x: 0, y: 0)
                scrollUV?.setContentOffset(topInset, animated: true)
            }
        }
    }
    
    func handleUV() {
        if  ProfileType == "1"{
            originWallUV.isHidden = true
            if isFromPostDetail {
                touserid = UserDefaults.standard.string(forKey: "ID")
                originPostUV.isHidden = false
                originPostContent.sd_setImage(with: URL(string: self.originalPostData["orgin_post_image"] as! String))
                originPostTime.text = self.originalPostData["origin_post_created"] as? String
                originPostTitle.text = self.originalPostData["orgin_post_title"] as? String
                originPostUVHeight.constant = 50.0
                originPostUVTopSpacing.constant = 12.0
            } else {
                touserid = UserDefaults.standard.string(forKey: "OtherUserID")
                originPostUV.isHidden = true
                originPostUVHeight.constant = 0.0
                originPostUVTopSpacing.constant = 0.0
                if ISREWALL {
                    touserid = UserDefaults.standard.string(forKey: "ID")
                    originWallUV.isHidden = false
                    originPostUVTopSpacing.constant = 12.0
                    if !isFromOriginRemuro {
                        if  let profilePic = ORIGINWALLDATA["avatarblobid"] as? String{
                            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                            originWallUserAvatar.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
                        }
                        originWallUserName.text = ORIGINWALLDATA["username"] as? String
                        originWallContent.text = ORIGINWALLDATA["content"] as? String
                        originWallCreatedTime.text = ORIGINWALLDATA["created"] as? String
                        if let verify = ORIGINWALLDATA["verify"] as? String {
                            originWallUserVerified.isHidden = verify == "1" ? false : true
                        }
                        if let Image = ORIGINWALLDATA["imageUrl"] as?String{
                            originWallExtra.sd_setImage(with: URL(string:Image))
                            if originWallExtra.image != nil{
                                originWallExtraHeight.constant = 120
                                
                            }else{
                                originWallExtraHeight.constant = 0
                            }
                        }
                    } else {
                        if  let profilePic = ORIGINWALLDATA["origin_wall_useravatar"] as? String{
                            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                            originWallUserAvatar.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
                        }
                        originWallUserName.text = ORIGINWALLDATA["origin_wall_username"] as? String
                        originWallContent.text = ORIGINWALLDATA["origin_wall_content"] as? String
                        originWallCreatedTime.text = ORIGINWALLDATA["origin_wall_created"] as? String
                        if let verify = ORIGINWALLDATA["origin_wall_userverify"] as? String {
                            originWallUserVerified.isHidden = verify == "1" ? false : true
                        }
                        if let Image = ORIGINWALLDATA["origin_wall_imageUrl"] as?String{
                            originWallExtra.sd_setImage(with: URL(string:Image))
                            if originWallExtra.image != nil{
                                originWallExtraHeight.constant = 120
                                
                            }else{
                                originWallExtraHeight.constant = 0
                            }
                        }
                    }
                } else {
                    originWallUV.isHidden = true
                    originPostUVTopSpacing.constant = 0.0
                }
            }
        } else {
            touserid = UserDefaults.standard.string(forKey: "ID")
            originPostUV.isHidden = true
            originPostUVHeight.constant = 0.0
            if ISREWALL {
                originWallUV.isHidden = false
                originPostUVTopSpacing.constant = 12.0
                if !isFromOriginRemuro {
                    if  let profilePic = ORIGINWALLDATA["avatarblobid"] as? String{
                        let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                        originWallUserAvatar.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
                    }
                    originWallUserName.text = ORIGINWALLDATA["username"] as? String
                    originWallContent.text = ORIGINWALLDATA["content"] as? String
                    originWallCreatedTime.text = ORIGINWALLDATA["created"] as? String
                    if let verify = ORIGINWALLDATA["verify"] as? String {
                        originWallUserVerified.isHidden = verify == "1" ? false : true
                    }
                    if let Image = ORIGINWALLDATA["imageUrl"] as?String{
                        originWallExtra.sd_setImage(with: URL(string:Image))
                        if originWallExtra.image != nil{
                            originWallExtraHeight.constant = 120
                            
                        }else{
                            originWallExtraHeight.constant = 0
                        }
                    }
                } else {
                    if  let profilePic = ORIGINWALLDATA["origin_wall_useravatar"] as? String{
                        let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                        originWallUserAvatar.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
                    }
                    originWallUserName.text = ORIGINWALLDATA["origin_wall_username"] as? String
                    originWallContent.text = ORIGINWALLDATA["origin_wall_content"] as? String
                    originWallCreatedTime.text = ORIGINWALLDATA["origin_wall_created"] as? String
                    if let verify = ORIGINWALLDATA["origin_wall_userverify"] as? String {
                        originWallUserVerified.isHidden = verify == "1" ? false : true
                    }
                    if let Image = ORIGINWALLDATA["origin_wall_imageUrl"] as?String{
                        originWallExtra.sd_setImage(with: URL(string:Image))
                        if originWallExtra.image != nil{
                            originWallExtraHeight.constant = 120
                        }else{
                            originWallExtraHeight.constant = 0
                        }
                    }
                }
            } else {
                originWallUV.isHidden = true
                originPostUVTopSpacing.constant = 0.0
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        if onTappedRemuro {
            ISREWALL = true
        } else {
            ISREWALL = false
        }
    }
    
    @IBAction func OnTag(_ sender: Any) {
        htTag.constant = 30
    }
    
    @IBAction func OnVideo(_ sender: Any) {
        htVideo.constant = 30
    }
    
    @IBAction func OnConfirm(_ sender: Any) {
        webserviceDeleteComment()
    }
    
    @IBAction func OnCancel(_ sender: Any) {
        viewComments.isHidden = true
        
    }
    
    @IBAction func OnSeeComments(_ sender: Any) {
        let vc:WallViewController = self.storyboard?.instantiateViewController(withIdentifier: "WallViewController") as! WallViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onTapCancelRewall(_ sender: Any) {
        isFromPostDetail = false
        ISREWALL = false
        onTappedRemuro = false
        handleUV()
    }
    // add Comments
    func webserviceAddComment(){
        var tags: String = ""
        for i in 0..<tagField.tags.count {
            let tag = tagField.tags[i]
            if i == tagField.tags.count - 1 {
                if tag.text.hasPrefix("#") {
                    tags += tag.text
                } else {
                    tags += "#\(tag.text)"
                }
            } else {
                if tag.text.hasPrefix("#") {
                    tags += "\(tag.text),, "
                } else {
                    tags += "#\(tag.text),, "
                }
            }
        }
        var Para: [String: Any] = [String: Any]()
        if isFromPostDetail {
            Para =
                [
                    "fromuserid":"\(LoginId!)","touserid":"\(touserid!)",
                    "wall_message":"\(textviewComments.text!)",
                    "repost":self.originalPostData["origin_post_id"] as! String,
                    "tags":tags
                ] as [String : Any]
        } else if ISREWALL {
            Para =
                [
                    "fromuserid":"\(LoginId!)","touserid":"\(touserid!)",
                    "wall_message":"\(textviewComments.text!)",
                    "rewall":isFromOriginRemuro ? (ORIGINWALLDATA["origin_wall_messageID"] as! String) : (ORIGINWALLDATA["messageid"] as! String),
                    "tags":tags
                ] as [String : Any]
        } else {
            Para =
                ["fromuserid":"\(LoginId!)","touserid":"\(touserid!)",
                 "wall_message":"\(textviewComments.text!)","tags":tags] as [String : Any]
        }
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.addNewWall)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        self.CallWebserviceCommentList()
                        self.textviewComments.text = ""
                        self.showAlert(title: "Nuevo muro",strMessage: "Tu publicación ha sido añadida al muro")
                        self.onTappedRemuro = false
                        ISREWALL = false
                        self.closeTag()
                        self.isFromPostDetail = false
                        objActivity.stopActivity()
                        DispatchQueue.main.async {
                            self.handleUV()
                            self.tableviewWall.setContentOffset(.zero, animated: true)
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
    //Multipart Image
    func UploadingImage(){
        var tags: String = ""
        for i in 0..<tagField.tags.count {
            let tag = tagField.tags[i]
            if i == tagField.tags.count - 1 {
                if tag.text.hasPrefix("#") {
                    tags += tag.text
                } else {
                    tags += "#\(tag.text)"
                }
            } else {
                if tag.text.hasPrefix("#") {
                    tags += "\(tag.text),, "
                } else {
                    tags += "#\(tag.text),, "
                }
            }
        }
        objActivity.startActivityIndicator()
        let imageData: NSData = Imagename!.pngData()! as NSData
        var Para: [String: Any] = [String: Any]()
        if isFromPostDetail {
            Para =
                [
                    "fromuserid":"\(LoginId!)","touserid":"\(touserid!)",
                    "wall_message":"\(textviewComments.text!)",
                    "repost":self.originalPostData["origin_post_id"] as! String, "tags": tags
                ] as [String : Any]
        } else if ISREWALL {
            Para =
                [
                    "fromuserid":"\(LoginId!)","touserid":"\(touserid!)",
                    "wall_message":"\(textviewComments.text!)",
                    "rewall":isFromOriginRemuro ? (ORIGINWALLDATA["origin_wall_messageID"] as! String) : (ORIGINWALLDATA["messageid"] as! String), "tags": tags
                ] as [String : Any]
        } else {
            Para =
                ["fromuserid":"\(LoginId!)","touserid":"\(touserid!)",
                 "wall_message":"\(textviewComments.text!)", "tags": tags] as [String : Any]
        }
        requestWith(videoData: imageData as Data, parameters: Para, onCompletion: { (response) in
        }) { (error) in
        }
    }
    //Mark:- Upload images with multipart
    func requestWith(videoData: Data?, parameters: [String : Any], onCompletion: ((JSON?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
        let url = "\(WebURL.BaseUrl)\(WebURL.addNewWall)"
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if let data = videoData{
                multipartFormData.append(data,withName: "imageUrl", fileName: "Post.png", mimeType: "image/png")
            }
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: nil) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let err = response.error{
                        onError?(err)
                        return
                    }
                    debugPrint(response.result.value!)
                    onCompletion?(nil)
                    self.showAlert(strMessage: "Tu publicación se ha añadido al muro")
                    self.closeTag()
                    self.uploadImage.layer.cornerRadius = 0
                    self.textviewComments.text = ""
                    self.uploadImage.image = UIImage(named:"SCamera")
                    objActivity.stopActivity()
                    self.onTappedRemuro = false
                    ISREWALL = false
                    isFromOriginRemuro = false
                    self.CallWebserviceCommentList()
                    DispatchQueue.main.async {
                        self.tableviewWall.setContentOffset(.zero, animated: true)
                        self.handleUV()
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                onError?(error)
            }
        }
    }
    
    func showAlert(title: String = "Mensaje", strMessage:String) ->() {
        let actionSheetController: UIAlertController = UIAlertController(title: title, message: strMessage, preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func OnAddComment(_ sender: Any) {
        let Comments = textviewComments.text
        if (Comments!.isEmpty) {
            self.showAlert(strMessage: "Escribe algún comentario")
            return
        }
        if EditType == "1"{
            webserviceEditComment()
        } else if ImageStatus == "1"{
            UploadingImage()
        } else{
            webserviceAddComment()
        }
    }
    @objc func removeImage() {
        let imageView = (self.view.viewWithTag(100)! as! UIImageView)
        imageView.removeFromSuperview()
        navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = false
    }
    
    func addImageViewWithImage(image: UIImage) {
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.black
        imageView.image = image
        imageView.tag = 100
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(self.removeImage))
        dismissTap.numberOfTapsRequired = 1
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(dismissTap)
        self.view.addSubview(imageView)
        navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = true
        imageView.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2)
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
    }
    
    func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let count : Int = response.products.count
        self.products.removeAll()
        if (count>0) {
            let validProducts = response.products
            self.products = validProducts
            self.products.sort { (p0, p1) -> Bool in
                return p0.price.floatValue < p1.price.floatValue
            }
            for product in self.products {
                print(product.priceLocale)
                print(product.price)
                print(product.localizedPrice())
            }
        } else {
            print("nothing")
        }
    }
    
    private func request(request: SKRequest!, didFailWithError error: NSError!) {
        print("Error Fetching product information");
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])    {
        print("Received Payment Transaction Response from Apple")
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .purchased:
                    print("Product Purchased");
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    OnCallSetFeaturdWall()
                    break;
                case .failed:
                    print("Purchased Failed")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                case .restored:
                    print("Already Purchased");
                    SKPaymentQueue.default().restoreCompletedTransactions()
                default:
                    break;
                }
            }
        }
    }
    
    func buyProduct(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func OnCallSetFeaturdWall() {
        objActivity.startActivityIndicator()
        let Para =
            ["messageid":"\(purchsaseMessageID)","userid":"\(LoginId!)"] as [String : Any]
        print(Para)
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.SET_FEATURE_WALL)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { [self] response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        _ = response.result.value as! [String :Any]
                        
                        self.arrayCommentsList[purchaseMessageIndex]["paid"] = 1
                        self.tableviewWall.reloadData()
                        DispatchQueue.main.async {
                            //show success dialog.
                            let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier:  "SuccessFeatureMuroDialogVC") as! SuccessFeatureMuroDialogVC
                            self.present(vc, animated: true, completion: nil)
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
//MARK:- Extension TableView Delegate/DataSource Methods
extension WallPostViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayCommentsList.count == 0{
            tableviewWall.isHidden = true
            emptyLabel.isHidden = false
            return 0
        } else {
            emptyLabel.isHidden = true
            tableviewWall.isHidden = false
            return arrayCommentsList.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? WallTableViewCell {
            if cell.imgWallPost.image == nil {
                let alert = UIAlertController(title: "Attention", message: "Image not available", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier:  "FullImageVC") as! FullImageVC
            vc.image = cell.imgWallPost.image!
            present(vc, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idetifier = "WallTableViewCell"
        let cell:WallTableViewCell = tableviewWall.dequeueReusableCell(withIdentifier: idetifier)as! WallTableViewCell
        cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.height/2
        cell.imgProfile.clipsToBounds = true
        cell.originPostActionUB.tag = indexPath.row
        cell.originPostActionUB.addTarget(self, action: #selector(onTapOriginPost), for: .touchUpInside)
        cell.originWallComentUB.tag = indexPath.row
        cell.originWallComentUB.addTarget(self, action: #selector(onTapCommentOriginWall), for: .touchUpInside)
        cell.originWallRemuroUB.tag = indexPath.row
        cell.originWallRemuroUB.addTarget(self, action: #selector(onTapRemuroOriginWall), for: .touchUpInside)
        let dictData = self.arrayCommentsList[indexPath.row]
        if let tagData = dictData["tags"] as? [[String: Any]] {
            cell.initTag(tags: tagData)
        }
        cell.delegate = self
        
        if let answerCnt = dictData["cntAnswer"] as? Int {
            if answerCnt > 0 {
                cell.lastCommentUV.isHidden = false
                if  let profilePic = dictData["lastCommentUserAvatar"] as? String{
                    let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                    cell.lastCommentUserUIMG.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
                } else {
                    cell.lastCommentUserUIMG.image = UIImage(named: "Splaceicon")
                }
                cell.answerCntLB.setTitle(getThousandWithK(value: answerCnt) + " respuestas", for: .normal)
                cell.answerCntLB.tag = indexPath.row
                
            } else {
                cell.lastCommentUV.isHidden = true
            }
        } else {
            cell.lastCommentUV.isHidden = true
        }
        
        if let Comments = dictData["content"] as? String{
            cell.labelComments.text = Comments
        }
        if let verify = dictData["verify"] as? String {
            cell.verifiedMarker.isHidden = verify == "1" ? false : true
        }
        if let ToUser = dictData["touserid"] as? String{
            if ToUser == LoginId! {
                cell.buttonDelete.isHidden = false
            } else{
                cell.buttonDelete.isHidden = true
            }
        }
        if let viewsCnt = dictData["views"] as? String {
            cell.viewCntLB.text = viewsCnt + " views"
        }
        if let ToUser = dictData["fromuserid"] as? String{
            if ToUser == touserid! {
                cell.RedCorner.isHidden = false
                cell.viewCntUV.isHidden = false
                cell.viewCntLayout.constant = 30.0
            } else{
                cell.RedCorner.isHidden = true
                cell.viewCntUV.isHidden = true
                cell.viewCntLayout.constant = 0.0
                cell.remuroUB.isHidden = false
            }
            if ToUser == UserDefaults.standard.string(forKey: "ID") {
                cell.remuroUB.isHidden = true
            } else {
                cell.remuroUB.isHidden = false
            }
        }
        cell.remuroUB.tag = indexPath.row
        cell.remuroUB.addTarget(self, action: #selector(onTapCellRemuroUB), for: .touchUpInside)
        if let ToUser = dictData["fromuserid"] as? String{
            if ToUser == LoginId! {
                cell.buttonEdit.isHidden = false
                cell.buttonDelete.isHidden = false
                if let paid = dictData["paid"] as? Int, paid == 1 {
                    cell.destacarUB.isHidden = true
                } else {
                    cell.destacarUB.isHidden = false
                }
            }else{
                cell.buttonEdit.isHidden = true
                cell.destacarUB.isHidden = true
            }
        }
        if let username = dictData["username"] as? String{
            cell.labelUserName.text = username
        }
        if let Comments = dictData["created"] as? String{
            cell.labelTime.text = Comments
        }
        if let Favourite = dictData["total_favourite"] as? String{
            cell.labelfavouriteCount.text = Favourite
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
        if  let profilePic = dictData["avatarblobid"] as? String{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            cell.imgProfile.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        }
        if let hasRecentPost = dictData["hasRecentPost"] as? Int {
            if hasRecentPost == 1{
                if (dictData["fromuserid"] as! String) != LoginId {
                    cell.recentWallUV.layer.borderWidth = 2.0
                } else {
                    cell.recentWallUV.layer.borderWidth = 0.0
                }
            } else {
                cell.recentWallUV.layer.borderWidth = 0.0
            }
        }
        if let Image = dictData["imageUrl"] as?String{
            cell.imgWallPost.sd_setImage(with: URL(string:Image))
            if cell.imgWallPost.image != nil{
                cell.htImages.constant = 180
            }else{
                cell.htImages.constant = 0
            }
        }
        cell.buttonDelete.tag = indexPath.row
        cell.buttonDelete.addTarget(self, action: #selector(self.OnDelete(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonEdit.tag = indexPath.row
        cell.buttonEdit.addTarget(self, action: #selector(self.OnEdit(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonComments.tag = indexPath.row
        cell.buttonComments.addTarget(self, action: #selector(self.OnComments(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonFavourite.tag = indexPath.row
        cell.buttonFavourite.addTarget(self, action: #selector(self.Onfavourite(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonUnFavourite.tag = indexPath.row
        cell.buttonUnFavourite.addTarget(self, action: #selector(self.Onfavourite(_:)), for: UIControl.Event.touchUpInside)
        cell.buttonProfile.tag = indexPath.row
        cell.buttonProfile.addTarget(self, action: #selector(self.OnUsers(_:)), for: UIControl.Event.touchUpInside)
        cell.destacarUB.tag = indexPath.row
        cell.destacarUB.addTarget(self, action: #selector(OnDestacar(_:)), for: .touchUpInside)
        cell.answerCntLB.addTarget(self, action: #selector(self.OnComments(_:)), for: UIControl.Event.touchUpInside)
        if  SharedManager.sharedInstance.ScrollStatus == "0"{
            let containerViewHight = self.tableviewWall.contentSize.height
            NotificationCenter.default.post(name: Notification.Name("reloadTable"), object: nil, userInfo: ["hight": containerViewHight])
        }
        if let repost = dictData["repost"] as? [String: Any] {
            cell.originWallUV.isHidden = true
            cell.originPostUV.isHidden = false
            cell.originPostUVHeight.constant = 50.0
            if  let profilePic = repost["origin_post_content"] as? String{
                cell.originPostUserAvatar.sd_setImage(with: URL(string: profilePic), placeholderImage: UIImage(named: "Splaceicon"))
            }
            if let title = repost["origin_post_title"] as? String {
                cell.originPostTitle.text = title
            }
            if let created = repost["origin_post_created"] as? String {
                cell.originPostTime.text = created
            }
        } else {
            cell.originPostUV.isHidden = true
            cell.originPostUVHeight.constant = 0.0
            if let rewall = dictData["rewall"] as? [String: Any] {
                cell.originWallUV.isHidden = false
                if  let profilePic = rewall["origin_wall_useravatar"] as? String{
                    let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                    cell.originWallUserAvatar.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
                }
                cell.originWallUserName.text = rewall["origin_wall_username"] as? String
                cell.originWallContent.text = rewall["origin_wall_content"] as? String
                cell.originWallCreatedTime.text = rewall["origin_wall_created"] as? String
                if let verify = rewall["origin_wall_userverify"] as? String {
                    cell.originWallUserVerified.isHidden = verify == "1" ? false : true
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
            }
        }
        return cell
        
        
    }
    
    @objc func OnDestacar(_ sender: UIButton) {
        let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier:  "SetFeatureMuroDialogVC") as! SetFeatureMuroDialogVC
        vc.callback = { [self] in
            purchsaseMessageID = arrayCommentsList[sender.tag]["messageid"] as! String
            purchaseMessageIndex = sender.tag
            buyProduct(product: products[0])
            //            OnCallSetFeaturdWall()
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func onTapOriginWallExtra(sender: UIButton) {
        let cell = tableviewWall.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as? WallTableViewCell
        let image: UIImage = cell!.originWallExtra.image!
        let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier:  "FullImageVC") as! FullImageVC
        vc.image = image
        present(vc, animated: true, completion: nil)
    }
    
    @objc func OnUsers(_ sender : UIButton) {
        let dict = self.arrayCommentsList[sender.tag]
        let OtherId = dict["fromuserid"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func Onfavourite(_ sender : UIButton) {
        let dict = self.arrayCommentsList[sender.tag]
        let Mid = dict["messageid"] as! String
        MessageId = Mid
        webserviceWallFavourite()
    }
    
    @objc func OnDelete(_ sender : UIButton) {
        let dict = self.arrayCommentsList[sender.tag]
        let Messageid = dict["messageid"] as! String
        MessageId = Messageid
        self.ProfileType = SharedManager.sharedInstance.otherProfile
        if  self.ProfileType == "1" {
            self.touserid = UserDefaults.standard.string(forKey: "OtherUserID")
        }else{
            self.touserid = UserDefaults.standard.string(forKey:"ID")
        }
        viewComments.isHidden = false
    }
    
    @objc func onTapCellRemuroUB(sender: UIButton) {
        ORIGINWALLDATA = self.arrayCommentsList[sender.tag]
        isFromOriginRemuro = false
        if ProfileType == "1" {
            print("123456")
            onTappedRemuro = true
            SharedManager.sharedInstance.otherProfile = "0"
            ISREWALL = true
            self.tabBarController?.selectedIndex = 4
            self.navigationController?.popViewController(animated: false)
        } else {
            onTappedRemuro = true
            ISREWALL = true
            handleUV()
            self.tabBarController?.selectedIndex = 4
        }
    }
    
    @objc func onTapCommentOriginWall(sender: UIButton) {
        let dict = self.arrayCommentsList[sender.tag]["rewall"] as! [String: Any]
        let Mid = dict["origin_wall_messageID"] as! String
        let vc:WallCommentsViewController = self.storyboard?.instantiateViewController(withIdentifier: "WallCommentsViewController") as! WallCommentsViewController
        vc.MessageId = Mid
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onTapRemuroOriginWall(sender: UIButton) {
        isFromOriginRemuro = true
        ORIGINWALLDATA = self.arrayCommentsList[sender.tag]["rewall"] as! [String : Any]
        if ProfileType == "1" {
            print("123456")
            onTappedRemuro = true
            SharedManager.sharedInstance.otherProfile = "0"
            ISREWALL = true
            self.tabBarController?.selectedIndex = 4
            self.navigationController?.popViewController(animated: false)
        } else {
            onTappedRemuro = true
            ISREWALL = true
            handleUV()
            self.tabBarController?.selectedIndex = 4
        }
    }
    
    @objc func OnEdit(_ sender : UIButton) {
        let dict = self.arrayCommentsList[sender.tag]
        let Messageid = dict["messageid"] as! String
        MessageId = Messageid
        let Comments = dict["content"] as! String
        self.textviewComments.text = Comments
        EditType = "1"
    }
    
    @objc func OnComments(_ sender : UIButton) {
        let dict = self.arrayCommentsList[sender.tag]
        let Mid = dict["messageid"] as! String
        let vc:WallCommentsViewController = self.storyboard?.instantiateViewController(withIdentifier: "WallCommentsViewController") as! WallCommentsViewController
        vc.MessageId = Mid
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onTapOriginPost(sender: UIButton) {
        let dictData = self.arrayCommentsList[sender.tag]
        let originPost = dictData["repost"] as! [String: Any]
        let postID = originPost["origin_post_id"] as! String
        let vc: PostDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier:"PostDetailsViewController")as! PostDetailsViewController
        vc.hidesBottomBarWhenPushed = true
        vc.PostID = postID
        SharedManager.sharedInstance.PostId = postID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func CallWebserviceCommentList(){
        let Para =
            ["touserid":"\(profileVCInstatnce.userId!)","login_userId":"\(LoginId!)"] as [String : Any]
        print(Para)
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.wallPostList)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["wallPost"]as? [[String:Any]]{
                                self.arrayCommentsList = Data
                                self.tableviewWall.reloadData()
                                self.EditType = "0"
                            }
                        }
                        if self.arrayCommentsList.isEmpty {
                            self.emptyLabel.isHidden = false
                            self.tableviewWall.isHidden = true
                        } else {
                            self.emptyLabel.isHidden = true
                            self.tableviewWall.isHidden = false
                        }
                        DispatchQueue.main.async {
                            let flags = profileVCInstatnce.flags
                            if self.ProfileType == "1" {
                                let userId = profileVCInstatnce.userId!
                                let LoginUser = UserDefaults.standard.string(forKey: "ID")
                                if LoginUser! == userId {
                                    self.deniedMuroUV.isHidden = false
                                } else {
                                    if flags == "4" || flags == "20" || flags == "0" || flags == "16" || flags == "5" || flags == "21"{
                                        self.deniedMuroUV.isHidden = false
                                    } else {
                                        self.deniedMuroUV.isHidden = true
                                    }
                                }
                            } else {
                                self.deniedMuroUV.isHidden = false
                            }
//                            self.wrapTableView()
                        }
                    }
                    break
                case .failure(_):
                    self.emptyLabel.isHidden = false
                    self.tableviewWall.isHidden = true
                    print(response.result.error as Any)
                    break
                }
            }
    }
    
    func wrapTableView() {
        self.tableviewWall.invalidateIntrinsicContentSize()
        self.tableviewWall.layoutIfNeeded()
        self.tableViewHeight.constant = self.tableviewWall.contentSize.height
        self.view.layoutIfNeeded()
        print("tableviewcontentsize\(self.tableviewWall.contentSize.height)")
    }
    
    //Delete Comments
    func webserviceDeleteComment(){
        let Para =
            ["messageid":"\(MessageId!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.deleteWall)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        self.viewComments.isHidden = true
                        self.CallWebserviceCommentList()
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
    
    //Edit Comments
    func webserviceEditComment(){
        let Para =
            ["messageid":"\(MessageId!)","wall_message":"\(textviewComments.text!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.editWall)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        self.textviewComments.text = ""
                        self.CallWebserviceCommentList()
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
    //Wall Favourite
    func webserviceWallFavourite(){
        let Para =
            ["messageid":"\(MessageId!)","userid":"\(touserid!)","login_userId":"\(LoginId!)"] as [String : Any]
        print(Para)
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.setWallfavourite)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        _ = response.result.value as! [String :Any]
                        self.CallWebserviceCommentList()
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
    
    @IBAction func btnChooseImageOnClick(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Open the camera
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            //If you dont want to edit the photo then you can set allowsEditing to false
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        } else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Choose image from camera roll
    
    func openGallary(){
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
}

//MARK: - UIImagePickerControllerDelegate

extension WallPostViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            Imagename = editedImage
            uploadImage.image = editedImage
            ImageStatus = "1"
            uploadImage.layer.masksToBounds = true
            uploadImage.layer.cornerRadius = uploadImage.bounds.width / 2
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.isNavigationBarHidden = false
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension WallPostViewController: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo.init(title: pageTitle ?? "Tab \(pageIndex)")
    }
}

extension WallPostViewController: WallTableViewCellDelegate {
    func onTapTag(tag: TagModel) {
        let vc: PopularTagPostViewController = self.storyboard?.instantiateViewController(withIdentifier:"PopularTagPostViewController")as! PopularTagPostViewController
        vc.TagPostrId = tag.tagID
        vc.titleTags.title = tag.tags
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension WallPostViewController: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        print("height:\(height)")
    }
}
