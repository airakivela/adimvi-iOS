//
//  CommentBottomSheetVC.swift
//  adimvi
//
//  Created by Aira on 4.01.2022.
//  Copyright © 2022 webdesky.com. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import SwiftSoup
import DPTagTextView
import DropDown

protocol CommentBottomSheeetVCDelegate {
    func didTapUserProfile(targetVC: ProfilerootViewController)
    func didTapEditComment(targetVC: EditCommentViewController)
    func didTapResponder(targetVC: MoreCommentsViewController)
    func didTapmentionUser(targetVC: ProfilerootViewController)
}

class CommentBottomSheetVC: UIViewController {
    
    @IBOutlet weak var containerUV: UIView!
    @IBOutlet weak var commentCountLB: UILabel!
    @IBOutlet weak var commentTV: UITableView!
    @IBOutlet weak var viewComments: UIView!
    @IBOutlet weak var textViewComment: DPTagTextView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var PostID: String?
    var CatID: String?
    
    var arrayComments =  [[String: Any]]()
    let defaults = UserDefaults.standard
    var LoginUserID:String!
    var DeletePostid:String!
    var CommentUserId:String!
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
    
    var delegate: CommentBottomSheeetVCDelegate?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        containerUV.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        commentTV.register(UINib(nibName: "CommentListCell", bundle: nil), forCellReuseIdentifier: "CommentListCell")
        viewComments.isHidden = true
        commentTV.delegate = self
        commentTV.dataSource = self
        
        self.sheetViewController!.handleScrollView(self.commentTV)
        LoginUserID = UserDefaults.standard.string(forKey: "ID")
        CallWebserviceCommentList()
        
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
        textViewComment.setText("Escribir comentario...", arrTags: taggedList)
        textViewComment.textColor = .lightGray
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func OnCancel(_ sender: Any) {
        viewComments.isHidden = true
    }
    
    @IBAction func OnConfirm(_ sender: Any) {
        DeleteComments()
    }
    
    func DeleteComments(){
        objActivity.startActivityIndicator()
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
    
    func CallWebserviceCommentList(){
        objActivity.startActivityIndicator()
        let Para = ["postid":"\(PostID!)","userid":"\(LoginUserID!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.postCommentList)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                objActivity.stopActivity()
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if (myData["response"] as? [String:Any]) != nil {
                            let code = myData["code"] as! String
                            if code == "200"{
                                self.commentTV.isHidden = false
                                self.emptyLabel.isHidden = true
                                if let arr = myData["response"] as? [String:Any] {
                                    if let Data = arr["postComment"]as? [[String:Any]]{
                                        if Data.count > 0 {
                                            self.emptyLabel.isHidden = true
                                            self.commentCountLB.text = "\(Data.count) comentarios"
                                            self.commentTV.isHidden = false
                                        } else {
                                            self.emptyLabel.isHidden = false
                                            self.commentCountLB.text = "0 comentarios"
                                            self.commentTV.isHidden = true
                                        }
                                        self.arrayComments = Data
                                        self.arrayComments.sort { (item0, item1) -> Bool in
                                            return ((item0["votCnt"] as! Int) > item1["votCnt"] as! Int)
                                        }
                                        self.commentTV.reloadData()
                                    }
                                }
                            }else{
                                self.commentCountLB.text = "0 comentarios"
                                self.commentTV.isHidden = true
                                self.emptyLabel.isHidden = false
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
    
    func CallWebserviceLike(){
        objActivity.startActivityIndicator()
        let Para = ["postid":"\(LikePostID!)","userid":"\(LoginUserID!)","like_dislike_type":"\(LikeType!)","postComment":"qw"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.LikePost)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                objActivity.stopActivity()
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
    
    @IBAction func OnAddComment(_ sender: Any) {
        let Comments = textViewComment.text
        
        if (Comments!.isEmpty) {
            self.showAlert(strMessage:
                            "Por favor, escribe un comentario.")
            return
        }
        CallWebAddComment()
    }
    
    func CallWebAddComment(){
        var mentionedUsr: [String] = [String]()
        taggedList.forEach { (tag) in
            mentionedUsr.append(tag.name)
        }
        print(mentionedUsr.joined(separator: ","))
        let Para =
            ["postid":"\(PostID!)","userid":"\(LoginUserID!)","categoryid":"\(CatID!)","comment":"\(textViewComment.text!)","type":"A", "mentions": mentionedUsr.joined(separator: ",")] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.postComment)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        _ = response.result.value as! [String :Any]
                        self.CallWebserviceCommentList()
                        let actionSheetController: UIAlertController = UIAlertController(title: "Nuevo comentario", message: "¡Tu comentario ha sido añadido!", preferredStyle: .alert)
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) { action -> Void in
                        }
                        actionSheetController.addAction(cancelAction)
                        self.present(actionSheetController, animated: true, completion: nil)
                        objActivity.stopActivity()
                        self.taggedList.removeAll()
                        self.initTagMention()
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

extension CommentBottomSheetVC: UITableViewDelegate, UITableViewDataSource {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentListCell")as!  CommentListCell
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
        self.dismiss(animated: true) {
            self.delegate?.didTapUserProfile(targetVC: vc)
        }
        
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
        vc.PostID = PostId
        vc.CategoryId = CatId
        vc.PostUserName = PostUserName
        let cell = commentTV.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as? CommentListCell
        vc.PostComment = cell?.labelComments.attributedText
        vc.PostPoint = PostPoint
        vc.PostDate = PostDate
        vc.PostUserImageUrl = PostUserImageURL
        vc.PostUserVeify = verify
        self.dismiss(animated: true) {
            self.delegate?.didTapResponder(targetVC: vc)
        }
    }
    
    @objc func OnEdit(_ sender: UIButton) {
        let dict = self.arrayComments[sender.tag]
        let postid = dict["postid"] as! String
        let vc: EditCommentViewController = self.storyboard?.instantiateViewController(withIdentifier:"EditCommentViewController")as! EditCommentViewController
        let cell = commentTV.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as? CommentListCell
        vc.EditComment = cell?.labelComments.attributedText
        vc.PostID = postid
        self.dismiss(animated: true) {
            self.delegate?.didTapEditComment(targetVC: vc)
        }
    }
    
}

extension CommentBottomSheetVC: CommentListCellDelegate {
    func didTapMentionsUser(userID: String) {
        self.defaults.set(userID, forKey: "OtherUserID")
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.dismiss(animated: true) {
            self.delegate?.didTapmentionUser(targetVC: vc)
        }
    }
}

extension CommentBottomSheetVC: DPTagTextViewDelegate {
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
    
    func textView(_ textView: DPTagTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText: NSString = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with:text)

        if updatedText.isEmpty {
            textView.setText("Escribir comentario...", arrTags: taggedList)
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            return false
        } else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.init(named: "Dark grey (Dark mode)")
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: DPTagTextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    func textViewDidChange(_ textView: DPTagTextView) {
        let size = CGSize(width: textViewComment.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
}
