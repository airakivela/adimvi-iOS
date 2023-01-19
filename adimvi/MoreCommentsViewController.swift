//
//  MoreCommentsViewController.swift
//  adimvi
//
//  Created by javed carear  on 11/09/19.
//  Copyright © 2019 webdesky.com. All rights reserved.
//
//postid:10487
//userid:12551
import UIKit
import Alamofire
import SDWebImage
import IQKeyboardManagerSwift
import GrowingTextView
class MoreCommentsViewController: UIViewController {
    @IBOutlet weak var buttonSubmit: UIButton!
    @IBOutlet weak var textviewComment: GrowingTextView!
    let defaults = UserDefaults.standard
    @IBOutlet weak var ViewComments: UIView!
    @IBOutlet weak var verifiedMarker: UIImageView!
    var PostID:String!
    var LoginUserid:String!
    var CommentUserid:String!
    var PostOnwerid:String!
    var CategoryId:String!
    var CommentsType:String!
    var HideComments:String!
    var DeletePostid:String!
    
    
    var PostUserName: String!
    var PostUserImageUrl: String?
    var PostComment: NSAttributedString!
    var PostPoint: String!
    var PostDate: String!
    var PostUserVeify: String!
    
    @IBOutlet weak var userNameLB: UILabel!
    @IBOutlet weak var commentLB: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var pointLB: UILabel!
    @IBOutlet weak var postTimeLB: UILabel!
    @IBOutlet weak var userImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tableviewCommentList: UITableView!
    @IBOutlet weak var parentScrollView: UIScrollView!
    var goingUp: Bool?
    var childScrollingDownDueToParent = false
    
    var arrayComments =  [[String: Any]]()
    let count = 10
    @IBOutlet weak var htTableview: NSLayoutConstraint!
    var buttontag:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        LoginUserid = UserDefaults.standard.string(forKey:"ID")
        
        CallWebserviceCommentList()
        initUIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hidesBottomBarWhenPushed = false
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    var isEdit: Bool = false
    
    func initUIView() {
        postTimeLB.text = PostDate
        pointLB.isHidden = true
        userNameLB.text = PostUserName
        postTimeLB.text = PostDate
        verifiedMarker.isHidden = PostUserVeify == "1" ? false : true
        if  let profilePic = PostUserImageUrl{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            
            userImg.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        }  else {
            userImg.image = UIImage(named: "Splaceicon")
        }
        commentLB.attributedText = PostComment
        parentScrollView.delegate = self
        tableviewCommentList.delegate = self
    }
    
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func OnOkay(_ sender: Any) {
        DeleteComments()
    }
    @IBAction func OnCancel(_ sender: Any) {
        ViewComments.isHidden = true
    }
    
    
    @IBAction func OnSubmit(_ sender: Any) {
        let Comments = textviewComment.text
        
        if (Comments!.isEmpty) {
            self.showAlert(strMessage: "Introduce un comentario.")
            return
        }
        if isEdit {
            CallWebEdit()
        } else {
            CallWebAddComment()
        }
        
    }
    
    func CallWebAddComment(){
        let Para =
            ["postid":"\(PostID!)","userid":"\(LoginUserid!)","categoryid":"\(CategoryId!)","comment":"\(textviewComment.text!)","type":"C"] as [String : Any]
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.postComment)"
        
        //objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        
//                        self.textviewComment.delegate = self
                        self.textviewComment.text = "Escribir respuesta..."
//                        self.textViewDidChange(self.textviewComment)
//                        self.textviewComment.textColor = UIColor.lightGray
//                        self.textviewComment.selectedTextRange = self.textviewComment.textRange(from: self.textviewComment.beginningOfDocument, to: self.textviewComment.beginningOfDocument)
                        self.CallWebserviceCommentList()
                        objActivity.stopActivity()
                        DispatchQueue.main.async {
                            
                        }
                    }
                    objActivity.stopActivity()
                    break
                case .failure(_):
                    // objActivity.stopActivity()
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
    
    func CallWebEdit(){
        let Para =
            ["postid":"\(PostID!)","comment":"\(textviewComment.text!)","type":"\(CommentsType!)"] as [String : Any]
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.editHideShowpostComment)"
        
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        let ParentId = myData["parentid"] as! String
                        self.PostID = ParentId
//                        self.textviewComment.delegate = self
                        self.textviewComment.text = ""
//                        self.textViewDidChange(self.textviewComment)
//                        self.textviewComment.textColor = UIColor.lightGray
//                        self.textviewComment.selectedTextRange = self.textviewComment.textRange(from: self.textviewComment.beginningOfDocument, to: self.textviewComment.beginningOfDocument)
                        self.isEdit = false
                        objActivity.stopActivity()
                        DispatchQueue.main.async {
                            self.tableviewCommentList.reloadData()
                            self.CallWebserviceCommentList()
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
extension MoreCommentsViewController : UITableViewDelegate,UITableViewDataSource {
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
        let idetifier = "MoreCommentsViewCell"
        let cell: MoreCommentsViewCell = tableviewCommentList.dequeueReusableCell(withIdentifier: idetifier) as! MoreCommentsViewCell
        
        let dictData = self.arrayComments[indexPath.row]
        //        //
        if let username = dictData["username"] as? String{
            cell.labelUserName.text = username
        }
        if let Comments = dictData["comment"] as? String{
            let parsedStr: String = Comments.htmlToAttributedString!.string
            
            Comments.parseHtml { [self] (mentionUserInfo) in
                if mentionUserInfo.isEmpty {
                    cell.labelComments.font = .systemFont(ofSize: 14.0)
                    cell.labelComments.text = parsedStr
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
                    cell.delegatee = self
                }
            }
        }
        
        if let verify = dictData["verify"] as? String {
            cell.verifiedMarker.isHidden = verify == "1" ? false : true
            cell.verifiedMarkerWidth.constant = verify == "1" ? 16.0 : 0.0
        }
        
        if let PostOnwer = dictData["post_owner_userid"] as? String{
            PostOnwerid = PostOnwer
        }
        
        if let CommentOnwer = dictData["userid"] as? String{
            CommentUserid = CommentOnwer
        }
        
        
        if LoginUserid == PostOnwerid {
            cell.buttonDelete.isHidden = false
        }else{
            cell.buttonDelete.isHidden = true
        }
        
        if LoginUserid == CommentUserid {
            cell.buttonDelete.isHidden = false
            cell.buttonEdit.isHidden = false
        }else{
            cell.buttonDelete.isHidden = true
            cell.buttonEdit.isHidden = true
        }
        
        if let Comments = dictData["comment_type"] as? String{
            HideComments = Comments
        }
        if let UserScorePoint = dictData["total_points"] as? String{
            cell.labelUserPoint.text = UserScorePoint
        }
        if let CommentTime = dictData["created"] as? String{
            cell.labelCommentTime.text = CommentTime
        }
        
        
        if  let profilePic = dictData["avatarblobid"] as? String{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            
            
            cell.imgProfilePic.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        } else {
            cell.imgProfilePic.image = UIImage(named: "Splaceicon")
        }
         
        if let hasRecentPost = dictData["hasRecentPost"] as? Int {
            if hasRecentPost == 1{
                if (dictData["userid"] as! String) != LoginUserid {
                    cell.recentWallUV.layer.borderWidth = 2.0
                } else {
                    cell.recentWallUV.layer.borderWidth = 0.0
                }
            } else {
                cell.recentWallUV.layer.borderWidth = 0.0
            }
        }
        
        cell.buttonEdit.tag = indexPath.row
        cell.buttonEdit.addTarget(self, action: #selector(self.OnDetail(_:)), for: UIControl.Event.touchUpInside)
        
        cell.buttonDelete.tag = indexPath.row
        cell.buttonDelete.addTarget(self, action: #selector(self.OnDelete(_:)), for: UIControl.Event.touchUpInside)
        
        cell.buttonProfile.tag = indexPath.row
        cell.buttonProfile.addTarget(self, action: #selector(self.OnProfile(_:)), for: UIControl.Event.touchUpInside)
        
        // self.htTableview.constant = self.tableviewCommentList.contentSize.height
        
        return cell
    }
    
    @objc func OnProfile(_ sender : UIButton) {
        let dict = self.arrayComments[sender.tag]
        let OtherId = dict["userid"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func OnDetail(_ sender: UIButton) {
        let dict = self.arrayComments[sender.tag]
        let Comments = dict["comment"] as! String
        let postid = dict["postid"] as! String
        PostID = postid
        CommentsType = "C"
        textviewComment.text! = Comments
        isEdit = true
    }
    
    
    @objc func OnDelete(_ sender: UIButton) {
        let dict = self.arrayComments[sender.tag]
        let Post = dict["postid"] as! String
        DeletePostid = Post
        ViewComments.isHidden = false
        
    }
    
    func DeleteComments(){
        let Para =
            ["postid":"\(DeletePostid!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.commentDelete)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        self.CallWebserviceCommentList()
                        self.ViewComments.isHidden = true
                        objActivity.stopActivity()
                        DispatchQueue.main.async {
                            
                        }
                    }
                    
                    break
                case .failure(_):
                    //objActivity.stopActivity()
                    print(response.result.error as Any)
                    break
                }
            }
    }
    
    func CallWebserviceCommentList(){
        let Para =
            ["postid":"\(PostID!)","userid":"\(LoginUserid!)"] as [String : Any]
        print(Para)
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.CommentCommentList)"
        
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["CommentComment"]as? [[String:Any]]{
                                self.arrayComments = Data
                                if self.arrayComments.count < 3 {
                                    self.parentScrollView.isScrollEnabled = false
                                } else {
                                    self.parentScrollView.isScrollEnabled = true
                                }
                                self.tableviewCommentList.reloadData()
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


extension MoreCommentsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        goingUp = scrollView.panGestureRecognizer.translation(in: scrollView).y < 0
        let parentViewMaxContentYOffset = parentScrollView.contentSize.height - parentScrollView.frame.height
        
        if goingUp! {
            if scrollView == tableviewCommentList {
                if parentScrollView.contentOffset.y < parentViewMaxContentYOffset && !childScrollingDownDueToParent {
                    parentScrollView.contentOffset.y = min(parentScrollView.contentOffset.y + tableviewCommentList.contentOffset.y, parentViewMaxContentYOffset)
                    tableviewCommentList.contentOffset.y = 0
                } 
            }
        } else {
            if scrollView == tableviewCommentList {
                if tableviewCommentList.contentOffset.y < 0 && parentScrollView.contentOffset.y > 0 {
                    parentScrollView.contentOffset.y = max(parentScrollView.contentOffset.y - abs(tableviewCommentList.contentOffset.y), 0)
                }
            }
            
            if scrollView == parentScrollView {
                if tableviewCommentList.contentOffset.y > 0 && tableviewCommentList.contentOffset.y < parentViewMaxContentYOffset {
                    childScrollingDownDueToParent = true
                    tableviewCommentList.contentOffset.y = max(tableviewCommentList.contentOffset.y - (parentViewMaxContentYOffset - parentScrollView.contentOffset.y), 0)
                    parentScrollView.contentOffset.y = parentViewMaxContentYOffset
                    childScrollingDownDueToParent = false
                }
            }
        }
    }
}

extension MoreCommentsViewController: MoreCommentsViewCellDelegate {
    func didTapMentionsUser(userID: String) {
        self.defaults.set(userID, forKey: "OtherUserID")
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

//extension MoreCommentsViewController: UITextViewDelegate {
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

