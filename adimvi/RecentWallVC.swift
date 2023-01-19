//
//  RecentWallVC.swift
//  adimvi
//
//  Created by Aira on 23.09.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit
import TagListView
import Alamofire

class RecentWallVC: UIViewController {
    
    var dictData = [[String: Any]]()
    var UserID:String!
    
    var lastContentOffSet = CGFloat()
    
    @IBOutlet weak var closeUIMG: UIImageView!
    @IBOutlet weak var recentCollectionUV: UICollectionView!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recentCollectionUV.delegate = self
        recentCollectionUV.dataSource = self
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLastCell))
        swipeGesture.direction = .left
        swipeGesture.delegate = self
        recentCollectionUV.addGestureRecognizer(swipeGesture)
        let closeGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCloseUB))
        closeUIMG.addGestureRecognizer(closeGesture)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        self.extendedLayoutIncludesOpaqueBars = true
        UserID = UserDefaults.standard.string(forKey: "ID")
    }
    
    @objc func didTapCloseUB() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn) {
            self.recentCollectionUV.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        } completion: { (_) in
            self.navigationController?.popViewController(animated: false)
        }

    }
    
    @objc func didSwipeLastCell() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn) {
            self.recentCollectionUV.transform = CGAffineTransform(scaleX: 0.00001, y: 0.00001)
        } completion: { (_) in
            self.navigationController?.popViewController(animated: false)
        }
    }
}

extension RecentWallVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let indexPath = recentCollectionUV?.indexPathsForVisibleItems[0]
        return indexPath!.row == dictData.count - 1
    }
}

extension RecentWallVC: UICollectionViewDelegate {
    
}

extension RecentWallVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}

extension RecentWallVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dictData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = dictData[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentWallCell", for: indexPath) as! RecentWallCell
        cell.delegate = self
        cell.configureCell(data: data)
        cell.userAvatarActionUB.tag = indexPath.row
        cell.userFollowActionUB.tag = indexPath.row
        cell.extraActionUB.tag = indexPath.row
        cell.originWallExtraActionUB.tag = indexPath.row
        cell.LikedUB.tag = indexPath.row
        cell.unLikedUB.tag = indexPath.row
        cell.remuroUB.tag = indexPath.row
        cell.commentUB.tag = indexPath.row
        cell.originWallRemuro.tag = indexPath.row
        cell.originWallCommentUB.tag = indexPath.row
        cell.originPostActionUB.tag = indexPath.row
        cell.messageUB.tag = indexPath.row
        cell.userAvatarActionUB.addTarget(self, action: #selector(didTapUserAvatar), for: .touchUpInside)
        cell.userFollowActionUB.addTarget(self, action: #selector(didTapUserFollow), for: .touchUpInside)
        cell.extraActionUB.addTarget(self, action: #selector(didTapExtra), for: .touchUpInside)
        cell.originWallExtraActionUB.addTarget(self, action: #selector(didTapOriginExtra), for: .touchUpInside)
        cell.LikedUB.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        cell.unLikedUB.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        cell.remuroUB.addTarget(self, action: #selector(didTapRemuro), for: .touchUpInside)
        cell.commentUB.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        cell.originWallRemuro.addTarget(self, action: #selector(didTapOriginRemuro), for: .touchUpInside)
        cell.originWallCommentUB.addTarget(self, action: #selector(didTapOriginComment), for: .touchUpInside)
        cell.originPostActionUB.addTarget(self, action: #selector(didTapOriginPost), for: .touchUpInside)
        cell.messageUB.addTarget(self, action: #selector(didTapmessageUB), for: .touchUpInside)
        cell.answerCntLB.tag = indexPath.row
        cell.answerCntLB.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        return cell
    }
    
}

extension RecentWallVC: RecenWallCellDelegate {
    func onTapTag(tag: TagModel) {
        let vc: PopularTagPostViewController = self.storyboard?.instantiateViewController(withIdentifier:"PopularTagPostViewController")as! PopularTagPostViewController
        vc.TagPostrId = tag.tagID
        vc.titleTags.title = tag.tags
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - RecentWallCell Button Actions
extension RecentWallVC {
    @objc func didTapmessageUB(sender: UIButton) {
        let dict = self.dictData[sender.tag]
        let OtherId = dict["fromuserid"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        let vc: PrivateMessageViewController = self.storyboard?.instantiateViewController(withIdentifier:"PrivateMessageViewController") as! PrivateMessageViewController
        vc.targetUserName = dict["username"] as? String
        vc.targetUserAvatar = dict["avatarblobid"] as? String
        if let verifyStr = dict["verify"] as? String {
            if verifyStr == "1" {
                vc.targetUserVerify = true
            } else {
                vc.targetUserVerify = false
            }
        } else {
            vc.targetUserVerify = false
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapUserAvatar(sender: UIButton) {
        let dict = self.dictData[sender.tag]
        let OtherId = dict["fromuserid"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController") as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapUserFollow(sender: UIButton) {
        let dict = dictData[sender.tag]
        let OtherUserId = dict["fromuserid"] as! String
        let Para = ["entityid":"\(OtherUserId)","userid":"\(UserID!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.setUserFollowing)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    objActivity.stopActivity()
                    DispatchQueue.main.async {
                        let status = dict["postFollow"] as? String
                        if status == "0" {
                            self.dictData[sender.tag].updateValue("1", forKey: "postFollow")
                        } else {
                            self.dictData[sender.tag].updateValue("0", forKey: "postFollow")
                        }
                        self.recentCollectionUV.reloadData()
                    }
                    break
                case .failure(_):
                    objActivity.stopActivity()
                    print(response.result.error as Any)
                    break
                }
            }
    }
    
    @objc func didTapExtra(sender: UIButton) {
        let cell = recentCollectionUV.cellForItem(at: IndexPath(item: sender.tag, section: 0)) as? RecentWallCell
        let image: UIImage = cell!.extraUIMG.image!
        let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier:  "FullImageVC") as! FullImageVC
        vc.image = image
        present(vc, animated: true, completion: nil)
    }
    
    @objc func didTapOriginExtra(sender: UIButton) {
        let cell = recentCollectionUV.cellForItem(at: IndexPath(item: sender.tag, section: 0)) as? RecentWallCell
        let image: UIImage = cell!.originWallExtraUIMG.image!
        let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier:  "FullImageVC") as! FullImageVC
        vc.image = image
        present(vc, animated: true, completion: nil)
    }
    
    @objc func didTapLike(sender: UIButton) {
        let dict = self.dictData[sender.tag]
        let messageID = dict["messageid"] as! String
        let para = ["messageid":"\(messageID)","userid":"\(UserID!)","login_userId":"\(UserID!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.setWallfavourite)"
        Alamofire.request(Api, method: .post,parameters:para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        _ = response.result.value as! [String :Any]
                        
                        DispatchQueue.main.async {
                            let status = dict["favourite"] as? String
                            let favCount = Int((dict["total_favourite"] as? String)!)
                            if status == "0" {
                                self.dictData[sender.tag].updateValue("1", forKey: "favourite")
                                self.dictData[sender.tag].updateValue("\(favCount! + 1)", forKey: "total_favourite")
                            } else {
                                self.dictData[sender.tag].updateValue("0", forKey: "favourite")
                                self.dictData[sender.tag].updateValue("\(favCount! - 1)", forKey: "total_favourite")
                            }
                            self.recentCollectionUV.reloadData()
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
    
    @objc func didTapRemuro(sender: UIButton) {
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController") as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        ISREWALL = true
        ORIGINWALLDATA = self.dictData[sender.tag]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapComment(sender: UIButton) {
        let dict = self.dictData[sender.tag]
        let Mid = dict["messageid"] as! String
        let vc:WallCommentsViewController = self.storyboard?.instantiateViewController(withIdentifier: "WallCommentsViewController") as! WallCommentsViewController
        vc.MessageId = Mid
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapOriginRemuro(sender: UIButton) {
        let dict = self.dictData[sender.tag]
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController") as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        isFromOriginRemuro = true
        ISREWALL = true
        ORIGINWALLDATA = dict["rewall"] as! [String: Any]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapOriginComment(sender: UIButton) {
        let dict = self.dictData[sender.tag]["rewall"] as! [String: Any]
        let Mid = dict["origin_wall_messageID"] as! String
        let vc:WallCommentsViewController = self.storyboard?.instantiateViewController(withIdentifier: "WallCommentsViewController") as! WallCommentsViewController
        vc.MessageId = Mid
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapOriginPost(sender: UIButton) {
        let dictData = self.dictData[sender.tag]
        let originPost = dictData["repost"] as! [String: Any]
        let postID = originPost["origin_post_id"] as! String
        let vc: PostDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier:"PostDetailsViewController") as! PostDetailsViewController
        vc.hidesBottomBarWhenPushed = true
        vc.PostID = postID
        SharedManager.sharedInstance.PostId = postID
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - RecentWallCellPart

protocol RecenWallCellDelegate {
    func onTapTag(tag: TagModel)
}

class RecentWallCell: UICollectionViewCell {
    
    @IBOutlet weak var bacgroundUIMG: UIImageView!
    @IBOutlet weak var sendMessageUB: UIButton!
    @IBOutlet weak var avatarUIMG: UIImageView!
    @IBOutlet weak var userFollowUV: UIView!
    @IBOutlet weak var userFollowUIMG: UIImageView!
    @IBOutlet weak var userNameLB: UILabel!
    @IBOutlet weak var verifyUIMG: UIImageView!
    @IBOutlet weak var createdLB: UILabel!
    @IBOutlet weak var extraUIMG: UIImageView!
    @IBOutlet weak var extraUIMGHeight: NSLayoutConstraint!
    @IBOutlet weak var contentLB: UILabel!
    @IBOutlet weak var tagListUV: TagListView!
    @IBOutlet weak var originWallUV: UIView!
    @IBOutlet weak var originWallUserUIMG: UIImageView!
    @IBOutlet weak var originWallUserNameLB: UILabel!
    @IBOutlet weak var originPostUV: UIView!
    @IBOutlet weak var originWallUserVerifyUIMG: UIImageView!
    @IBOutlet weak var originWallCreatedLB: UILabel!
    @IBOutlet weak var originWallContentLB: UILabel!
    @IBOutlet weak var originWallExtraUIMG: UIImageView!
    @IBOutlet weak var originPostxtra: UIImageView!
    @IBOutlet weak var originPostTitleLB: UILabel!
    @IBOutlet weak var originPostCreated: UILabel!
    @IBOutlet weak var likeCountLB: UILabel!
    
    @IBOutlet weak var originWallExtraActionUB: UIButton!
    @IBOutlet weak var originWallRemuro: UIButton!
    @IBOutlet weak var originWallCommentUB: UIButton!
    @IBOutlet weak var userAvatarActionUB: UIButton!
    @IBOutlet weak var userFollowActionUB: UIButton!
    @IBOutlet weak var extraActionUB: UIButton!
    @IBOutlet weak var originPostActionUB: UIButton!
    @IBOutlet weak var LikedUB: UIButton!
    @IBOutlet weak var unLikedUB: UIButton!
    @IBOutlet weak var commentUB: DesignableButton!
    @IBOutlet weak var remuroUB: DesignableButton!
    @IBOutlet weak var htOriginWallExtra: NSLayoutConstraint!
    
    @IBOutlet weak var messageUB: UIButton!
    
    @IBOutlet weak var lastCommentUV: UIView!
    @IBOutlet weak var lastCommentUserUIMG: UIImageView!
    @IBOutlet weak var answerCntLB: UIButton!
    
    
    var cellData: [String: Any]!
    var tagArr: [TagModel] = [TagModel]()
    var delegate: RecenWallCellDelegate?
    
    let UserId = UserDefaults.standard.string(forKey: "ID")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tagListUV.textFont = .systemFont(ofSize: 14.0)
        tagListUV.tagBackgroundColor = .clear
        tagListUV.textColor = UIColor(named: "lighter_gray")!
        tagListUV.delegate = self
    }
    
    func configureCell (data: [String: Any]) {
        self.cellData = data
        
        if let answerCnt = data["cntAnswer"] as? Int {
            if answerCnt > 0 {
                lastCommentUV.isHidden = false
                if  let profilePic = data["lastCommentUserAvatar"] as? String{
                    let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                    lastCommentUserUIMG.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
                } else {
                    lastCommentUserUIMG.image = UIImage(named: "Splaceicon")
                }
                answerCntLB.setTitle(getThousandWithK(value: answerCnt) + " respuestas", for: .normal)
                
            } else {
                lastCommentUV.isHidden = true
            }
        } else {
            lastCommentUV.isHidden = true
        }
        
        if  let profilePic = data["avatarblobid"] as? String{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            self.bacgroundUIMG.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
            self.avatarUIMG.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        } else {
            self.bacgroundUIMG.image = UIImage(named: "Splaceicon")
            self.avatarUIMG.image = UIImage(named: "Splaceicon")
        }
        
        if let verify = data["verify"] as? String {
            if verify == "1" {
                verifyUIMG.isHidden = false
            } else {
                verifyUIMG.isHidden = true
            }
        } else {
            verifyUIMG.isHidden = true
        }
        
        if let name = data["username"] as? String {
            userNameLB.text = name
        } else {
            userNameLB.text = ""
        }
        
        if let followStatus = data["postFollow"] as? String {
            if followStatus == "1" {
                userFollowUV.backgroundColor = UIColor.white
                userFollowUIMG.image = UIImage(named: "unfollow20x20")
            } else {
                userFollowUV.backgroundColor = UIColor(named: "darkBlack")
                userFollowUIMG.image = UIImage(named: "follow_white")
            }
        }
        
        if let created = data["created"] as? String {
            createdLB.text = created
        }
        
        if let content = data["content"] as? String {
            contentLB.text = content
        }
        
        if let extra = data["imageUrl"] as? String {
            if !extra.isEmpty {
                extraUIMG.isHidden = false
                extraUIMGHeight.constant = 150.0
                self.extraUIMG.sd_setImage(with: URL(string: extra), placeholderImage: UIImage(named: "Splaceicon"))
            } else {
                extraUIMG.isHidden = true
                extraUIMGHeight.constant = 0.0
            }
        } else {
            extraUIMG.isHidden = true
            extraUIMGHeight.constant = 0.0
        }
        
        if let tags = data["tags"] as? [[String: Any]] , !tags.isEmpty{
            tagListUV.isHidden = false
            initTag(tags: tags)
        } else {
            tagListUV.isHidden = true
        }
        
        if let likeCnt = data["total_favourite"] as? String {
            likeCountLB.text = likeCnt
        }
        
        if let likeStatus = data["favourite"] as? String , likeStatus == "1"{
            LikedUB.isHidden = false
            unLikedUB.isHidden = true
        } else {
            unLikedUB.isHidden = false
            LikedUB.isHidden = true
        }
        
        if let orginWall = data["rewall"] as? [String: Any], !orginWall.isEmpty {
            originWallUV.isHidden = false
            
            if let originWallUserAvatar = orginWall["origin_wall_useravatar"] as? String, !originWallUserAvatar.isEmpty {
                self.originWallUserUIMG.sd_setImage(with: URL(string: "\(WebURL.ImageUrl)\(originWallUserAvatar)"), placeholderImage: UIImage(named: "Splaceicon"))
            } else {
                self.originWallUserUIMG.image = UIImage(named: "Splaceicon")
            }
            
            if let originWallUserName = orginWall["origin_wall_username"] as? String {
                self.originWallUserNameLB.text = originWallUserName
            }
            
            if let originWallCreated = orginWall["origin_wall_created"] as? String {
                self.originWallCreatedLB.text = originWallCreated
            }
            
            if let originWallContent = orginWall["origin_wall_content"] as? String {
                self.originWallContentLB.text = originWallContent
            }
            
            if let originWallExtra = orginWall["origin_wall_imageUrl"] as? String {
                if originWallExtra.isEmpty {
                    originWallExtraUIMG.isHidden = true
                    htOriginWallExtra.constant = 0.0
                } else {
                    originWallExtraUIMG.isHidden = false
                    htOriginWallExtra.constant = 120.0
                    self.originWallExtraUIMG.sd_setImage(with: URL(string: originWallExtra), placeholderImage: UIImage(named: "Splaceicon"))
                }
                
            } else {
                htOriginWallExtra.constant = 0.0
                originWallExtraUIMG.isHidden = true
            }
            
            if let originWallUserVerify = orginWall["origin_wall_userverify"] as? String, originWallUserVerify == "1" {
                originWallUserVerifyUIMG.isHidden = false
            } else {
                originWallUserVerifyUIMG.isHidden = true
            }
            
        } else {
            originWallUV.isHidden = true
        }
        
        if let originPost = data["repost"] as? [String: Any], !originPost.isEmpty {
            
            if let originPostExtra = originPost["origin_post_content"] as? String, !originPostExtra.isEmpty {
                self.originPostxtra.sd_setImage(with: URL(string: "\(originPostExtra)"), placeholderImage: UIImage(named: "Splaceicon"))
            } else {
                self.originPostxtra.image = UIImage(named: "Splaceicon")
            }
            
            if let originPostTitle = originPost["origin_post_title"] as? String {
                self.originPostTitleLB.text = originPostTitle
            }
            
            if let originPostCreated = originPost["origin_post_created"] as? String {
                self.originPostCreated.text = originPostCreated
            }
            
        } else {
            originPostUV.isHidden = true
        }
        callProfileVisit()
        callViewWallUpdate()
    }
    
    func callViewWallUpdate() {
        let entityID = cellData["fromuserid"] as! String
        if UserId == entityID {
            return
        }
        let messageID = cellData["messageid"] as! String
        let param = ["messageID": messageID]
        let myService:String = "\(WebURL.BaseUrl)\(WebURL.UPDATE_WALL_COUNT)"
        Alamofire.request(myService, method: .post,parameters:param)
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
    
    func callProfileVisit() {
        let entityID = cellData["fromuserid"] as! String
        let Para =
            ["entityID":"\(entityID)","userID":"\(UserId!)"
            ] as [String : Any]
        let myService:String = "\(WebURL.BaseUrl)\(WebURL.UPDATE_USER_PROFILE_VISIT)"
        Alamofire.request(myService, method: .post,parameters:Para)
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
    
    func initTag(tags: [[String: Any]]) {
        tagArr.removeAll()
        tagListUV.removeAllTags()
        for tag in tags {
            let tagModel: TagModel = TagModel()
            tagModel.initTag(tag: tag)
            if let id = tagModel.tagID, !id.isEmpty {
                if let tagName = tagModel.tags, !tagName.isEmpty, tagName != " " {
                    tagArr.append(tagModel)
                    tagListUV.addTag(tagName)
                }
            }
        }
    }
}

extension RecentWallCell: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        var selectedTag = TagModel()
        for tag in tagArr {
            if tag.tags == title {
                selectedTag = tag
                break
            }
        }
        delegate?.onTapTag(tag: selectedTag)
    }
}
