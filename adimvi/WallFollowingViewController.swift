//
//  WallFollowingViewController.swift
//  adimvi
//  Created by javed carear  on 16/10/19.
//  Copyright © 2019 webdesky.com. All rights reserved.


import UIKit
import Alamofire
class WallFollowingViewController: UIViewController {
    @IBOutlet weak var tableviewWall: UITableView!
    var LoginId:String!
    let defaults = UserDefaults.standard
    var MessageId:String!
    var arrayWall =  [[String: Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        SharedManager.sharedInstance.hearticon = "0"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        LoginId = UserDefaults.standard.string(forKey: "ID")
        tableviewWall.estimatedRowHeight = 100
        CallWebserviceWallList()
    }
    @objc func removeImage() {
        
        let imageView = (self.view.viewWithTag(100)! as! UIImageView)
        imageView.removeFromSuperview()
        navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = false
    }
    
    func addImageViewWithImage(image: UIImage) {
        
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        //        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.black
        imageView.image = image
        imageView.tag = 100
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(self.removeImage))
        dismissTap.numberOfTapsRequired = 1
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(dismissTap)
        self.view.addSubview(imageView)
        imageView.layer.zPosition = 1
        navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = true
        imageView.center = CGPoint(x: self.view.frame.size.width/2, y:
                                    self.view.frame.size.height/2)
        
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        
        imageView.contentMode = .scaleAspectFit
        
    }
    
    
}
//MARK:- Extension TableView Delegate/DataSource Methods
extension WallFollowingViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayWall.count
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? WallFollowingViewCell {
            if cell.imgWallPost.image == nil {
                let alert = UIAlertController(title: "Attention", message: "image not available", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            } else {
                //                self.addImageViewWithImage(image: cell.imgWallPost.image!)
                let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier:  "FullImageVC") as! FullImageVC
                vc.image = cell.imgWallPost.image!
                present(vc, animated: true, completion: nil)
            }
            
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idetifier = "WallFollowingViewCell"
        let cell:WallFollowingViewCell = tableviewWall.dequeueReusableCell(withIdentifier: idetifier)as! WallFollowingViewCell
        
        let dictData = self.arrayWall[indexPath.row]
        if let tagData = dictData["tags"] as? [[String: Any]] {
            cell.initTag(tags: tagData)
        }
        cell.delegate = self
        
        if let Comments = dictData["content"] as? String{
            cell.labelComments.text = Comments
        }
        if let time = dictData["created"] as? String{
            cell.labelTime.text = time
        }
        if let massage = dictData["totalComments"] as? String {
            cell.buttonmassageCount.setTitle(massage, for: .normal)
        }
        if let favourite = dictData["total_favourite"] as? String {
            cell.buttonFavourite.setTitle(favourite, for: .normal)
            cell.buttonUnFavourite.setTitle(favourite, for: .normal)
        }
        if let verify = dictData["verify"] as? String {
            cell.verifyMarker.isHidden = verify == "1" ? false : true
        }
        
        if let Image = dictData["imageUrl"] as?String{
            cell.imgWallPost.sd_setImage(with: URL(string:Image))
            
            if cell.imgWallPost.image != nil{
                cell.htImages.constant = 180
                
            }else{
                cell.htImages.constant = 0
                //
            }
            
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
        
        if let username = dictData["username"] as? String{
            cell.labelUserName.text = username
        }
        
        if  let profilePic = dictData["avatarblobid"] as? String{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            cell.imgProfile.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        } else {
            cell.imgProfile.image = UIImage(named: "Splaceicon")
        }
        
        if let hasRecentPost = dictData["hasRecentPost"] as? Int {
            if hasRecentPost == 1{
                if (dictData["touserid"] as! String) != LoginId {
                    cell.recentWallUV.layer.borderWidth = 2.0
                } else {
                    cell.recentWallUV.layer.borderWidth = 0.0
                }
            } else {
                cell.recentWallUV.layer.borderWidth = 0.0
            }
        }
        
        cell.buttonFavourite.tag = indexPath.row
        cell.buttonFavourite.addTarget(self, action: #selector(self.Onfavourite(_:)), for: UIControl.Event.touchUpInside)
        
        cell.buttonUnFavourite.tag = indexPath.row
        cell.buttonUnFavourite.addTarget(self, action: #selector(self.Onfavourite(_:)), for: UIControl.Event.touchUpInside)
        
        
        
        cell.buttonmassageCount.tag = indexPath.row
        cell.buttonmassageCount.addTarget(self, action: #selector(self.OnComments(_:)), for: UIControl.Event.touchUpInside)
        
        cell.buttonUserProfile.tag = indexPath.row
        cell.buttonUserProfile.addTarget(self, action: #selector(self.OnUsers(_:)), for: UIControl.Event.touchUpInside)
        
        if let rewall = dictData["rewall"] as? [String: Any] {
            cell.originWallUV.isHidden = false
            cell.originPostUV.isHidden = true
            if let profilePic = rewall["origin_wall_useravatar"] as? String{
                let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                cell.originWallUserAvatar.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
            } else {
                cell.originWallUserAvatar.image = UIImage(named: "Splaceicon")
            }
            cell.originWallUserName.text = rewall["origin_wall_username"] as? String
            cell.originWallContent.text = rewall["origin_wall_content"] as? String
            cell.originWallCreated.text = rewall["origin_wall_created"] as? String
            if let verify = rewall["origin_wall_userverify"] as? String {
                cell.originWallUserVerify.isHidden = verify == "1" ? false : true
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
            if let repost = dictData["repost"] as? [String: Any] {
                cell.originPostUV.isHidden = false
                //            cell.originPostUVHeight.constant = 50.0
                //            cell.originPostUVTopSpacing.constant = 12.0
                if  let profilePic = repost["origin_post_content"] as? String{
                    cell.originPostExtra.sd_setImage(with: URL(string: profilePic), placeholderImage: UIImage(named: "Splaceicon"))
                }
                if let title = repost["origin_post_title"] as? String {
                    cell.originPostTitle.text = title
                }
                if let created = repost["origin_post_created"] as? String {
                    cell.originPostCreated.text = created
                }
            } else {
                cell.originPostUV.isHidden = true
            }
            cell.originPostActionUB.tag = indexPath.row
            cell.originPostActionUB.addTarget(self, action: #selector(onTapOriginPost), for: .touchUpInside)
        }
        
        
        if let remuroCount = dictData["remuroCount"] as? String {
            cell.remuroUB.setTitle(remuroCount, for: .normal)
        }
        cell.remuroUB.tag = indexPath.row
        cell.remuroUB.addTarget(self, action: #selector(onTapRemuroUB), for: .touchUpInside)
        return cell
    }
    
    @objc func onTapOriginWallExtra(sender: UIButton) {
        let cell = tableviewWall.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as? WallFollowingViewCell
        let image: UIImage = cell!.originWallExtra.image!
        let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier:  "FullImageVC") as! FullImageVC
        vc.image = image
        present(vc, animated: true, completion: nil)
    }
    
    @objc func onTapOriginPost(sender: UIButton) {
        let dictData = self.arrayWall[sender.tag]
        let originPost = dictData["repost"] as! [String: Any]
        let postID = originPost["origin_post_id"] as! String
        let vc: PostDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier:"PostDetailsViewController")as! PostDetailsViewController
        vc.hidesBottomBarWhenPushed = true
        vc.PostID = postID
        SharedManager.sharedInstance.PostId = postID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onTapRemuroUB(sender: UIButton) {
        let dict: [String: Any] = self.arrayWall[sender.tag]
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        ISREWALL = true
        ORIGINWALLDATA = dict
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func OnComments(_ sender : UIButton) {
        let dict = self.arrayWall[sender.tag]
        let OtherId = dict["fromuserid"] as! String
        let message = dict["messageid"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        
        let vc: WallCommentsViewController = self.storyboard?.instantiateViewController(withIdentifier:"WallCommentsViewController")as! WallCommentsViewController
        vc.MessageId = message
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func Onfavourite(_ sender : UIButton) {
        let dict = self.arrayWall[sender.tag]
        let Mid = dict["messageid"] as! String
        MessageId = Mid
        webserviceWallFavourite()
        
        
    }
    
    @objc func OnUsers(_ sender : UIButton) {
        let dict = self.arrayWall[sender.tag]
        let OtherId = dict["fromuserid"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
    
    func CallWebserviceWallList(){
        let Para =
            ["userid":"\(LoginId!)"] as [String : Any]
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.wallFollowList)"
        
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["wallFollowPost"]as? [[String:Any]]{
                                self.arrayWall = Data
                                self.tableviewWall.reloadData()
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
    
    //Wall Favourite
    func webserviceWallFavourite(){
        let Para =
            ["messageid":"\(MessageId!)","userid":"\(LoginId!)","login_userId":"\(LoginId!)"] as [String : Any]
        print(Para)
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.setWallfavourite)"
        
        
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        _ = response.result.value as! [String :Any]
                        
                        self.CallWebserviceWallList()
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

extension WallFollowingViewController: WallFollowingViewCellDelegate {
    func onTapTag(tag: TagModel) {
        let vc: PopularTagPostViewController = self.storyboard?.instantiateViewController(withIdentifier:"PopularTagPostViewController")as! PopularTagPostViewController
        vc.TagPostrId = tag.tagID
        vc.titleTags.title = tag.tags
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
