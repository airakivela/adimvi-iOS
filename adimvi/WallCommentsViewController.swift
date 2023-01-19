
//  WallCommentsViewController.swift
//  adimvi
//  Created by javed carear  on 26/09/19.
//  Copyright © 2019 webdesky.com. All rights reserved.


import UIKit
import Alamofire
import SDWebImage
import GrowingTextView

class WallCommentsViewController: UIViewController {
    
    
    
    @IBOutlet weak var ViewComments: UIView!
    @IBOutlet weak var htTableview: NSLayoutConstraint!
    @IBOutlet weak var tableviewComments: UITableView!
    @IBOutlet weak var textviewComment: GrowingTextView!
    
    //message information//
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var imgUserVerify: UIImageView!
    @IBOutlet weak var createdLB: UILabel!
    @IBOutlet weak var userNameLB: UILabel!
    @IBOutlet weak var messageContentLB: UILabel!
    @IBOutlet weak var imgMessage: UIImageView!
    @IBOutlet weak var imgMessageHeight: NSLayoutConstraint!
    @IBOutlet weak var rewallUV: DesignableView!
    @IBOutlet weak var imgRewallUser: UIImageView!
    @IBOutlet weak var imgRewallUserVerify: UIImageView!
    @IBOutlet weak var rewallCreatedLB: UILabel!
    @IBOutlet weak var rewallUserNameLB: UILabel!
    @IBOutlet weak var rewallContentLB: UILabel!
    @IBOutlet weak var imgRewall: UIImageView!
    @IBOutlet weak var imgRwallHeight: NSLayoutConstraint!
    @IBOutlet weak var repostUV: UIView!
    @IBOutlet weak var repostTitleLB: UILabel!
    @IBOutlet weak var repostCreatedLB: UILabel!
    @IBOutlet weak var imgRepost: UIImageView!
    @IBOutlet weak var parentScrollView: UIScrollView!
    var goingUp: Bool?
    var childScrollingDownDueToParent = false
    
    var arrayCommentsList =  [[String: Any]]()
    let defaults = UserDefaults.standard
    var touserid:String!
    var Fromuserid:String!
    var MessageId:String!
    var EditMessageId:String!
    var ProfileType:String!
    var EditType:String = "0"
    
    var CommentUserId:String!
    var LoginUserID:String!
    var PostOnwerId:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoginUserID = UserDefaults.standard.string(forKey: "ID")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableviewComments.estimatedRowHeight = 100
        ProfileType = SharedManager.sharedInstance.otherProfile
        if  ProfileType == "1" {
            touserid = UserDefaults.standard.string(forKey: "OtherUserID")
        }else{
            touserid = UserDefaults.standard.string(forKey: "ID")
        }
        
        Fromuserid = UserDefaults.standard.string(forKey: "ID")
        webserviceCommentlist()
        rewallUV.isHidden = true
        repostUV.isHidden = true
        parentScrollView.delegate = self
        
//        textviewComment.text = "Escribir respuesta..."
//        textviewComment.textColor = UIColor.lightGray
//        textviewComment.selectedTextRange = textviewComment.textRange(from: textviewComment.beginningOfDocument, to: textviewComment.beginningOfDocument)
//        textviewComment.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }
    
    @IBAction func OnAddComments(_ sender: Any) {
        let Comments = textviewComment.text
        if (Comments!.isEmpty) {
            self.showAlert(strMessage: "Escribe un comentario")
            return
        }
        if EditType == "1"{
            webserviceEditComment()
        }else{
            webserviceAddComment()
            
        }
    }
    
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
//MARK:- Extension TableView Delegate/DataSource Methods
extension WallCommentsViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCommentsList.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idetifier = "WallCommentsViewCell"
        let cell:WallCommentsViewCell = tableviewComments.dequeueReusableCell(withIdentifier: idetifier)as! WallCommentsViewCell
        
        let dictData = self.arrayCommentsList[indexPath.row]
        
        if let Comments = dictData["content"] as? String{
            cell.labelComments.text = Comments
        }
        
        
        if let username = dictData["username"] as? String{
            cell.labelUserName.text = username
        }
        
        if  let profilePic = dictData["avatarblobid"] as? String{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            
            cell.imgProfile.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        }
        
        if let hasRecentPost = dictData["hasRecentPost"] as? Int {
            if hasRecentPost == 1{
                if (dictData["owner_userid"] as! String) != LoginUserID {
                    cell.recentWallUV.layer.borderWidth = 2.0
                } else {
                    cell.recentWallUV.layer.borderWidth = 0.0
                }
            } else {
                cell.recentWallUV.layer.borderWidth = 0.0
            }
        }
        
        if let verify = dictData["verify"] as? String {
            cell.verifiedMarker.isHidden = verify == "1" ? false : true
        }
        
        if let PostOnwerid = dictData["owner_userid"] as? String{
            PostOnwerId = PostOnwerid
        }
        
        if let Time = dictData["created"] as? String{
            cell.labelTime.text = Time
        }
        
        if let CommentOnwer = dictData["userid"] as? String{
            CommentUserId = CommentOnwer
        }
        
        if Fromuserid == CommentUserId {
            cell.buttonDelete.isHidden = false
            cell.buttonEdit.isHidden = false
        }
        
        else if Fromuserid == PostOnwerId {
            cell.buttonDelete.isHidden = false
            cell.buttonEdit.isHidden = true
        }else{
            cell.buttonDelete.isHidden = true
            cell.buttonEdit.isHidden = true
            
        }
        
        cell.buttonProfile.tag = indexPath.row
        cell.buttonProfile.addTarget(self, action: #selector(self.OnProfile(_:)), for: UIControl.Event.touchUpInside)
        
        cell.buttonEdit.tag = indexPath.row
        cell.buttonEdit.addTarget(self, action: #selector(self.OnEdit(_:)), for: UIControl.Event.touchUpInside)
        
        cell.buttonDelete.tag = indexPath.row
        cell.buttonDelete.addTarget(self, action: #selector(self.OnDelete(_:)), for: UIControl.Event.touchUpInside)
        // htTableview.constant = tableviewComments.contentSize.height
        return cell
    }
    
    
    @objc func OnProfile(_ sender : UIButton) {
        let dict = self.arrayCommentsList[sender.tag]
        let OtherId = dict["userid"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func OnEdit(_ sender : UIButton) {
        let dict = self.arrayCommentsList[sender.tag]
        let Messageid = dict["messageid"] as! String
        EditMessageId = Messageid
        let Comments = dict["content"] as! String
        self.textviewComment.text = Comments
        EditType = "1"
    }
    
    @IBAction func OnCencel(_ sender: Any) {
        ViewComments.isHidden = true
    }
    @IBAction func OnDeleteM(_ sender: Any) {
        webserviceDeleteComment()
    }
    
    @objc func OnDelete(_ sender : UIButton) {
        ViewComments.isHidden = false
        let dict = self.arrayCommentsList[sender.tag]
        let Messageid = dict["messageid"] as! String
        EditMessageId = Messageid
    }
    
    func webserviceAddComment(){
        let Para =
            ["fromuserid":"\(Fromuserid!)","touserid":"\(touserid!)","messageid":"\(MessageId!)",
             "wall_comment":"\(textviewComment.text!)"] as [String : Any]
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.replyWallComments)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        
                        self.textviewComment.text = ""
//                        self.textviewComment.delegate = self
                        self.textviewComment.text = ""
//                        self.textViewDidChange(self.textviewComment)
//                        self.textviewComment.textColor = UIColor.lightGray
//                        self.textviewComment.selectedTextRange = self.textviewComment.textRange(from: self.textviewComment.beginningOfDocument, to: self.textviewComment.beginningOfDocument)
                        self.webserviceCommentlist()
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
    
    func webserviceCommentlist(){
        let Para =
            ["messageid":"\(MessageId!)", "login_userid":"\(LoginUserID!)"
            ] as [String : Any]
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.wallCommentList)"
        
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["wallComments"]as? [[String:Any]]{
                                self.arrayCommentsList = Data
                                self.tableviewComments.reloadData()
                            }
                            if let messageInfo = arr["msgInfo"] as? [String: Any] {
                                self.handleUV(messageInfo)
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
    
    func handleUV(_ messageInfo: [String: Any]) {
        if let imgURL = messageInfo["avatarblobid"] as? String {
            let imageURl = "\(WebURL.ImageUrl)\(imgURL)"
            imgUser.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        }
        if let userName = messageInfo["username"] as? String {
            userNameLB.text = userName
        }
        if let veryfied = messageInfo["verify"] as? String {
            imgUserVerify.isHidden = veryfied == "1" ? false : true
        }
        if let created = messageInfo["created"] as? String {
            createdLB.text = created
        }
        if let content = messageInfo["content"] as? String {
            messageContentLB.text = content
        }
        if let imgURL = messageInfo["imageUrl"] as? String {
            imgMessage.sd_setImage(with: URL(string:imgURL))
            
            if imgMessage.image != nil{
                imgMessageHeight.constant = 180
                
            }else{
                imgMessageHeight.constant = 0
            }
        }
        if let rewall = messageInfo["rewall"] as? [String: Any] {
            rewallUV.isHidden = false
            repostUV.isHidden = true
            if let profilePic = rewall["origin_wall_useravatar"] as? String{
                let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                imgRewallUser.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
            }
            rewallUserNameLB.text = rewall["origin_wall_username"] as? String
            rewallContentLB.text = rewall["origin_wall_content"] as? String
            rewallCreatedLB.text = rewall["origin_wall_created"] as? String
            if let verify = rewall["origin_wall_userverify"] as? String {
                imgRewallUserVerify.isHidden = verify == "1" ? false : true
            }
            if let Image = rewall["origin_wall_imageUrl"] as?String{
                imgRewall.sd_setImage(with: URL(string:Image))
                
                if imgRewall.image != nil{
                    imgRwallHeight.constant = 120
                    
                }else{
                    imgRwallHeight.constant = 0
                }
            }
        } else {
            rewallUV.isHidden = true
            if let repost = messageInfo["repost"] as? [String: Any] {
                repostUV.isHidden = false
                if  let profilePic = repost["origin_post_content"] as? String{
                    imgRepost.sd_setImage(with: URL(string: profilePic), placeholderImage: UIImage(named: "Splaceicon"))
                }
                if let title = repost["origin_post_title"] as? String {
                    repostTitleLB.text = title
                }
                if let created = repost["origin_post_created"] as? String {
                    repostCreatedLB.text = created
                }
            } else {
                repostUV.isHidden = true
            }
        }
        
    }
    
    //Edit Comments
    func webserviceEditComment(){
        let Para =
            ["messageid":"\(EditMessageId!)","wall_message":"\(textviewComment.text!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.editWall)"
        
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        
                        self.textviewComment.text = ""
                        self.webserviceCommentlist()
                        objActivity.stopActivity()
                        self.EditType = "0"
//                        self.textviewComment.delegate = self
                        self.textviewComment.text = ""
//                        self.textViewDidChange(self.textviewComment)
//                        self.textviewComment.textColor = UIColor.lightGray
//                        self.textviewComment.selectedTextRange = self.textviewComment.textRange(from: self.textviewComment.beginningOfDocument, to: self.textviewComment.beginningOfDocument)
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
    
    // Delete Comments
    func webserviceDeleteComment(){
        let Para =
            ["messageid":"\(EditMessageId!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.deleteWall)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        self.webserviceCommentlist()
                        self.ViewComments.isHidden = true
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
    
    
    func showAlert(strMessage:String) ->() {
        let actionSheetController: UIAlertController = UIAlertController(title: "Mensaje", message: strMessage, preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
}

extension WallCommentsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        goingUp = scrollView.panGestureRecognizer.translation(in: scrollView).y < 0
        let parentViewMaxContentYOffset = parentScrollView.contentSize.height - parentScrollView.frame.height
        
        if goingUp! {
            if scrollView == tableviewComments {
                if parentScrollView.contentOffset.y < parentViewMaxContentYOffset && !childScrollingDownDueToParent {
                    parentScrollView.contentOffset.y = min(parentScrollView.contentOffset.y + tableviewComments.contentOffset.y, parentViewMaxContentYOffset)
                    tableviewComments.contentOffset.y = 0
                }
            }
        } else {
            if scrollView == tableviewComments {
                if tableviewComments.contentOffset.y < 0 && parentScrollView.contentOffset.y > 0 {
                    parentScrollView.contentOffset.y = max(parentScrollView.contentOffset.y - abs(tableviewComments.contentOffset.y), 0)
                }
            }
            
            if scrollView == parentScrollView {
                if tableviewComments.contentOffset.y > 0 && tableviewComments.contentOffset.y < parentViewMaxContentYOffset {
                    childScrollingDownDueToParent = true
                    tableviewComments.contentOffset.y = max(tableviewComments.contentOffset.y - (parentViewMaxContentYOffset - parentScrollView.contentOffset.y), 0)
                    parentScrollView.contentOffset.y = parentViewMaxContentYOffset
                    childScrollingDownDueToParent = false
                }
            }
        }
    }
}

//extension WallCommentsViewController: UITextViewDelegate {
//
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        let currentText: NSString = textView.text as NSString
//        let updatedText = currentText.replacingCharacters(in: range, with:text)
//
//        if updatedText.isEmpty {
//            textView.text = "Escribir respuesta..."
//            textView.textColor = UIColor.lightGray
//            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
//            return false
//        } else if textView.textColor == UIColor.lightGray && !text.isEmpty {
//            textView.text = nil
//            textView.textColor = UIColor.init(named: "Dark grey (Dark mode)")
//        }
//        return true
//    }
//
//    func textViewDidChangeSelection(_ textView: UITextView) {
//        if self.view.window != nil {
//            if textView.textColor == UIColor.lightGray {
//                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
//            }
//        }
//    }
//
//    func textViewDidChange(_ textView: UITextView) {
//        let size = CGSize(width: textviewComment.frame.width, height: .infinity)
//        let estimatedSize = textView.sizeThatFits(size)
//        textView.constraints.forEach { (constraint) in
//            if constraint.firstAttribute == .height {
//                constraint.constant = estimatedSize.height
//            }
//        }
//    }
//
//}
