
//  CommentListViewController.swift
//  adimvi
//  Created by javed carear  on 03/09/19.
//  Copyright © 2019 webdesky.com. All rights reserved.


import UIKit
import Alamofire
import SDWebImage
import SwiftSoup

class CommentListViewController: UIViewController {
    var arrayComments =  [[String: Any]]()
    let defaults = UserDefaults.standard
    var PostID:String!
    var DeletePostid:String!
    var CommentUserId:String!
    var LoginUserID:String!
    var CommentType:String!
    var Comments:String!
    var HideComments:String!
    var SelectLike:String!
    var LikeType:String!
    var LikePostID:String!
    var CheckLikeStatus:String!
    var LikeDislikeType:String!
    var Likeid:String!
    var CheckType:String!
    var PostOnwerId:String!
    
    var isFromNotification: Bool = false
    var selectedPostID: String?
    
    @IBOutlet weak var postUV: UIView!
    @IBOutlet weak var postUVHeight: NSLayoutConstraint!
    @IBOutlet weak var viewComments: UIView!
    @IBOutlet weak var tableviewCommentList: UITableView!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var topSpacePostUV: NSLayoutConstraint!
    @IBOutlet weak var bottomSpacePostUV: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableviewCommentList.estimatedRowHeight = 100
        tableviewCommentList.register(UINib(nibName: "CommentListCell", bundle: nil), forCellReuseIdentifier: "CommentListCell")
        LoginUserID = UserDefaults.standard.string(forKey: "ID")
        CallWebserviceCommentList()
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.darkGray]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        postUVHeight.constant = 0.0
        self.topSpacePostUV.constant = 0.0
        self.bottomSpacePostUV.constant = 0.0
        postUV.isHidden = true
        
        print(selectedPostID ?? "123456")
    }
    
    @IBAction func OnCancel(_ sender: Any) {
        viewComments.isHidden = true
    }
    
    @IBAction func OnConfirm(_ sender: Any) {
        DeleteComments()
    }
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapPost(_ sender: Any) {
        let vc: PostDetailsViewController =
            self.storyboard?.instantiateViewController(withIdentifier: "PostDetailsViewController")as! PostDetailsViewController
        vc.PostID = PostID
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CallWebserviceCommentList()
        
    }
    
    
}
//MARK:- Extension TableView Delegate/DataSource Methods
extension CommentListViewController : UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayComments.count
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
        let idetifier = "CommentListCell"
        let cell: CommentListCell = tableviewCommentList.dequeueReusableCell(withIdentifier: idetifier)as!  CommentListCell
        let dictData = self.arrayComments[indexPath.row]
        
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
        
        if let username = dictData["username"] as? String{
            cell.labelUserName.text = username
        }
        
        
        
        if let PostOnwerid = dictData["owner_userid"] as? String{
            PostOnwerId = PostOnwerid
        }
        
        if let verify = dictData["verify"] as? String {
            cell.verifiedMarkerWidth.constant = verify == "1" ? 16.0 : 0.0
            cell.verifiedMarker.isHidden = verify == "1" ? false : true
        }
        
        if let CommentOnwer = dictData["userid"] as? String{
            CommentUserId = CommentOnwer
        }
        
        if LoginUserID == CommentUserId {
            cell.buttonDelete.isHidden = false
            cell.buttonEdit.isHidden = false
        }
        
        else if LoginUserID == PostOnwerId {
            cell.buttonDelete.isHidden = false
        }else{
            cell.buttonDelete.isHidden = true
            cell.buttonEdit.isHidden = true
        }
        
        if let Comments = dictData["comment"] as? String{
            let parsedStr: String = Comments.htmlToAttributedString!.string
            
            Comments.parseHtml { [self] (mentionUserInfo) in
                if mentionUserInfo.isEmpty {
                    cell.labelComments.attributedText = NSAttributedString(string: parsedStr, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)])
                    cell.labelComments.isUserInteractionEnabled = false
                } else {
                    print("unempty")
                    let attributdString = NSMutableAttributedString(string: parsedStr, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)])
                    for item in mentionUserInfo {
                        let range = (parsedStr as NSString).range(of: item.key)
                        attributdString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: "AppColor")!, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)], range: range)
                    }
                    cell.labelComments.attributedText = attributdString
                    
                    cell.handleMention(mentionInfo: mentionUserInfo)
                    cell.delegate = self
                }
            }
        }
        if let UserScorePoint = dictData["total_points"] as? String{
            cell.labelUserPoint.text = UserScorePoint
        }
        if let CommentTime = dictData["created"] as? String{
            cell.labelCommentTime.text = CommentTime
        }
        if let Comments = dictData["comment_type"] as? String{
            HideComments = Comments
        }
        if let neteVote = dictData["netvotes"] as? String{
            cell.labelNetVote.text = neteVote
        }
        
        if let LikeType = dictData["like_dislike_type"] as? String{
            cell.ButtonLike.isHidden = true
            cell.DisLike.isHidden = true
            cell.buttonSelectDislike.isHidden = true
            cell.buttonlikeDisable.isHidden = true
            cell.buttonUnlikeDisable.isHidden = true
            cell.buttonSelectLike.isHidden = true
            if LikeType == "0"{
                cell.ButtonLike.isHidden = true
                cell.DisLike.isHidden = true
                cell.buttonSelectDislike.isHidden = false
                cell.buttonlikeDisable.isHidden = false
            } else if LikeType == "1"{
                cell.ButtonLike.isHidden = true
                cell.DisLike.isHidden = true
                cell.buttonSelectLike.isHidden = false
                cell.buttonUnlikeDisable.isHidden = false
                
            } else{
                cell.buttonSelectLike.isHidden = true
                cell.ButtonLike.isHidden = false
                cell.DisLike.isHidden = false
                cell.buttonUnlikeDisable.isHidden = true
            }
        }
        
        if let CheckPost = dictData["postid"] as? String{
            if CheckType == "2"{
                if CheckPost == Likeid && CheckLikeStatus == "1" && LikeDislikeType == "0" {
                    cell.ButtonLike.isHidden = true
                    cell.DisLike.isHidden = true
                    cell.buttonSelectDislike.isHidden = false
                    cell.buttonlikeDisable.isHidden = false
                }else{
                    cell.ButtonLike.isHidden = false
                    cell.DisLike.isHidden = false
                    cell.buttonSelectDislike.isHidden = true
                    cell.buttonlikeDisable.isHidden = true
                }
            }
        }
        
        if  let profilePic = dictData["avatarblobid"] as? String{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            cell.imgProfilePic.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        } else {
            cell.imgProfilePic.image = UIImage(named: "Splaceicon")
        }
        
        if let hasRecentPost = dictData["hasRecentPost"] as? Int {
            if hasRecentPost == 1{
                if (dictData["userid"] as! String) != LoginUserID {
                    cell.recentWallUV.layer.borderWidth = 2.0
                } else {
                    cell.recentWallUV.layer.borderWidth = 0.0
                }
            } else {
                cell.recentWallUV.layer.borderWidth = 0.0
            }
        }
        
        cell.buttonComment.tag = indexPath.row
        cell.buttonComment.addTarget(self, action: #selector(self.OnDetail(_:)), for: UIControl.Event.touchUpInside)
        cell.answerCntLB.addTarget(self, action: #selector(self.OnDetail(_:)), for: UIControl.Event.touchUpInside)
        
        cell.buttonEdit.tag = indexPath.row
        cell.buttonEdit.addTarget(self, action: #selector(self.OnEdit(_:)), for: UIControl.Event.touchUpInside)
        
        cell.buttonDelete.tag = indexPath.row
        cell.buttonDelete.addTarget(self, action: #selector(self.OnDelete(_:)), for: UIControl.Event.touchUpInside)
        
        cell.ButtonLike.tag = indexPath.row
        cell.ButtonLike.addTarget(self, action: #selector(self.OnLikes(_:)), for: UIControl.Event.touchUpInside)
        
        cell.buttonSelectLike.tag = indexPath.row
        cell.buttonSelectLike.addTarget(self, action: #selector(self.OnLikes(_:)), for: UIControl.Event.touchUpInside)
        
        cell.DisLike.tag = indexPath.row
        cell.DisLike.addTarget(self, action: #selector(self.OnDislike(_:)), for: UIControl.Event.touchUpInside)
        
        cell.buttonSelectDislike.tag = indexPath.row
        cell.buttonSelectDislike.addTarget(self, action: #selector(self.OnDislike(_:)), for: UIControl.Event.touchUpInside)
        
        cell.buttonProfile.tag = indexPath.row
        cell.buttonProfile.addTarget(self, action: #selector(self.OnProfile(_:)), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    
    @objc func OnDelete(_ sender: UIButton) {
        let dict = self.arrayComments[sender.tag]
        let Post = dict["postid"] as! String
        DeletePostid = Post
        viewComments.isHidden = false
    }
    
    @objc func OnProfile(_ sender : UIButton) {
        let dict = self.arrayComments[sender.tag]
        let OtherId = dict["userid"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func OnLikes(_ sender: UIButton) {
        let dict = self.arrayComments[sender.tag]
        let likePost = dict["postid"] as! String
        LikePostID = likePost
        LikeType = "1"
        CheckType = "1"
        CallWebserviceLike()
    }
    
    @objc func OnDislike(_ sender: UIButton) {
        let dict = self.arrayComments[sender.tag]
        let likePost = dict["postid"] as! String
        LikePostID = likePost
        LikeType = "0"
        CheckType = "2"
        CallWebserviceLike()
    }
    
    @objc func OnDetail(_ sender: UIButton) {
        let dict = self.arrayComments[sender.tag]
        let PostId = dict["postid"] as! String
        let CatId = dict["categoryid"] as! String
        let PostUserName = dict["username"] as! String
        let PostPoint = dict["total_points"] as! String
        let PostDate = dict["created"] as! String
        let verify = dict["verify"] as! String
        var PostUserImageURL = ""
        if let profilePic = dict["avatarblobid"] as? String {
            PostUserImageURL = "\(WebURL.ImageUrl)\(profilePic)"
        } else {
            PostUserImageURL = ""
        }
        let vc: MoreCommentsViewController = self.storyboard?.instantiateViewController(withIdentifier:"MoreCommentsViewController")as! MoreCommentsViewController
//        vc.PostComment = NSAttributedString(string: (dict["origin_comment"] as? String)!, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)])
        vc.PostID = PostId
        vc.CategoryId = CatId
        vc.PostUserName = PostUserName
        let cell = tableviewCommentList.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as? CommentListCell
        vc.PostComment = cell?.labelComments.attributedText
        vc.PostPoint = PostPoint
        vc.PostDate = PostDate
        vc.PostUserImageUrl = PostUserImageURL
        vc.PostUserVeify = verify
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func OnEdit(_ sender: UIButton) {
        let dict = self.arrayComments[sender.tag]
        let postid = dict["postid"] as! String
        let vc: EditCommentViewController = self.storyboard?.instantiateViewController(withIdentifier:"EditCommentViewController")as! EditCommentViewController
        let cell = tableviewCommentList.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as? CommentListCell
        vc.EditComment = cell?.labelComments.attributedText
        vc.PostID = postid
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func CallWebserviceLike(){
        let Para = ["postid":"\(LikePostID!)","userid":"\(LoginUserID!)","like_dislike_type":"\(LikeType!)","postComment":"qw"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.LikePost)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["postVotes"]as? [String:Any]{
                                if let Post = Data["postid"] as? String{
                                    self.Likeid = Post
                                }
                                if let Poststatus = Data["likeType"] as? String{
                                    self.CheckLikeStatus = Poststatus
                                    
                                }
                                if let type = Data["like_dislike_type"] as? String{
                                    self.LikeDislikeType = type
                                    
                                }
                                self.CallWebserviceCommentList()
                            }
                        }
                    }
                case .failure(_):
                    print(response.result.error as Any)
                    break
                }
            }
    }
    
    func CallWebserviceCommentList(){
        let Para = ["postid":"\(PostID!)","userid":"\(LoginUserID!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.postCommentList)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if (myData["response"] as? [String:Any]) != nil {
                            let code = myData["code"] as! String
                            if code == "200"{
                                self.tableviewCommentList.isHidden = false
                                self.emptyLabel.isHidden = true
                                if let arr = myData["response"] as? [String:Any] {
                                    if let Data = arr["postComment"]as? [[String:Any]]{
                                        if Data.count > 0 {
                                            self.emptyLabel.isHidden = true
                                            self.tableviewCommentList.isHidden = false
                                        } else {
                                            self.emptyLabel.isHidden = false
                                            self.tableviewCommentList.isHidden = true
                                        }
                                        self.arrayComments = Data
                                        self.arrayComments.sort { (item0, item1) -> Bool in
                                            return ((item0["votCnt"] as! Int) > item1["votCnt"] as! Int)
                                        }
                                        self.tableviewCommentList.reloadData()
                                    }
                                    if let post = arr["postData"] as? [String: Any] {
                                        self.postTitle.text = post["post_title"] as? String
                                        if let imageURl = post["post_image"] as? String {
                                            self.postImg.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
                                        }
                                    }
                                    if self.isFromNotification {
                                        self.postUV.isHidden = false
                                        self.postUVHeight.constant = 90.0
                                        self.topSpacePostUV.constant = 10.0
                                        self.bottomSpacePostUV.constant = 10.0
                                    } else {
                                        self.postUVHeight.constant = 0.0
                                        self.topSpacePostUV.constant = 0.0
                                        self.bottomSpacePostUV.constant = 0.0
                                        self.postUV.isHidden = true
                                    }
                                }
                            }else{
                                self.tableviewCommentList.isHidden = true
                                self.emptyLabel.isHidden = false
                            }
                        }
                        DispatchQueue.main.async {
                            if let isShowSelectedRow = self.selectedPostID {
                                var i: Int = 0
                                for item in self.arrayComments {
                                    if item["postid"] as? String == isShowSelectedRow {
                                        self.tableviewCommentList.scrollToRow(at: IndexPath(item: i, section: 0), at: .top, animated: true)
                                    }
                                    i += 1
                                }
                            } else {
                                return
                            }
                        }
                    }
                    break
                case .failure(_):
                    print(response.result.error as Any)
                    break
                }
            }
    }
    
    func DeleteComments(){
        let Para = ["postid":"\(DeletePostid!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.commentDelete)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        self.CallWebserviceCommentList()
                        self.viewComments.isHidden = true
                        objActivity.stopActivity()
                    }
                    break
                case .failure(_):
                    print(response.result.error as Any)
                    break
                }
            }
    }
    
    func CallWebEdit(){
        let Para = ["postid":"\(PostID!)","comment":"\(Comments!)","type":"\(CommentType!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.editHideShowpostComment)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        
                        let ParentId = myData["parentid"] as! String
                        self.PostID = ParentId
                        self.CallWebserviceCommentList()
                        objActivity.stopActivity()
                    }
                    break
                case .failure(_):
                    print(response.result.error as Any)
                    break
                }
            }
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    func parseHtml(mentionsUserInfo: @escaping([String: String])-> Void) {
        do {
            let doc: Document = try SwiftSoup.parse(self)
            let elementsIDs: Elements = try doc.getElementsByTag("b")
            let elementsUsers: Elements = try doc.getElementsByTag("font")
            var userinfo = [String: String]()
            for i in 0..<elementsUsers.count {
                print(elementsUsers[i].ownText())
                print(elementsIDs[i].id())
                userinfo[elementsUsers[i].ownText()] = elementsIDs[i].id()
            }
            mentionsUserInfo(userinfo)
        } catch Exception.Error( _, let message) {
            print(message)
        } catch {
            print("error")
        }
    }
}

extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}

extension UILabel {
    func getRect(range: NSRange) -> CGRect {
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        textContainer.lineFragmentPadding = 0.0
        let pointer = UnsafeMutablePointer<NSRange>.allocate(capacity: 1)
        layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: pointer)
        return layoutManager.boundingRect(forGlyphRange: pointer.move(), in: textContainer)
    }
}

extension CommentListViewController: CommentListCellDelegate {
    func didTapMentionsUser(userID: String) {
        self.defaults.set(userID, forKey: "OtherUserID")
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
