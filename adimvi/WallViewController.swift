//
//  WallViewController.swift
//  adimvi
//  Created by javed carear  on 22/08/19.
//  Copyright © 2019 webdesky.com. All rights reserved.


import UIKit
import Alamofire
import SDWebImage
class WallViewController: UIViewController {
    
    @IBOutlet weak var htEditView: NSLayoutConstraint!
    @IBOutlet weak var textviewComment: UITextView!
    var touserid:String!
    var LoginId:String!
    var MessageId:String!
    var EditType:String!
    var ProfileType:String!
    let defaults = UserDefaults.standard
    var arrayCommentsList =  [[String: Any]]()
    @IBOutlet weak var tableviewWall: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableviewWall.estimatedRowHeight = 100
        ProfileType = SharedManager.sharedInstance.otherProfile
        if  ProfileType == "1" {
            touserid = UserDefaults.standard.string(forKey: "OtherUserID")
        }else{
            touserid = UserDefaults.standard.string(forKey: "ID")
        }
        LoginId = UserDefaults.standard.string(forKey: "ID")
        CallWebserviceCommentList()
    }
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func OnAddComment(_ sender: Any) {
        let Comments = textviewComment.text
        
        if (Comments!.isEmpty) {
            self.showAlert(strMessage:
                            "Por favor ingrese sus comentarios")
            return
        }
        
        if EditType == "1"{
            webserviceEditComment()
        }else{
            webserviceAddComment()
            
        }
    }
    
}
//MARK:- Extension TableView Delegate/DataSource Methods
extension WallViewController: UITableViewDelegate,UITableViewDataSource {
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
        return arrayCommentsList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idetifier = "WallTableViewCell"
        let cell:WallTableViewCell = tableviewWall.dequeueReusableCell(withIdentifier: idetifier)as! WallTableViewCell
        
        cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.height/2
        cell.imgProfile.clipsToBounds = true
        
        let dictData = self.arrayCommentsList[indexPath.row]
        
        if let Comments = dictData["content"] as? String{
            cell.labelComments.text = Comments
        }
        if let verify = dictData["verify"] as? String {
            cell.verifiedMarker.isHidden = verify == "1" ? false : true
        }
        if let ToUser = dictData["touserid"] as? String{
            
            if ToUser == LoginId! {
                cell.buttonDelete.isHidden = false
            }else{
                cell.buttonDelete.isHidden = true
                
            }
            
        }
        
        if let ToUser = dictData["fromuserid"] as? String{
            
            if ToUser == LoginId! {
                cell.buttonEdit.isHidden = false
                cell.buttonDelete.isHidden = false
                cell.RedCorner.isHidden = false
            }else{
                cell.buttonEdit.isHidden = true
                cell.RedCorner.isHidden = true
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
        
        let containerViewHight = self.tableviewWall.contentSize.height
        NotificationCenter.default.post(name: Notification.Name("reloadTable"), object: nil, userInfo: ["hight": containerViewHight])
        
        return cell
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
        webserviceDeleteComment()
        self.ProfileType = SharedManager.sharedInstance.otherProfile
        if  self.ProfileType == "1" {
            self.touserid = UserDefaults.standard.string(forKey: "OtherUserID")
        }else{
            self.touserid = UserDefaults.standard.string(forKey: "ID")
        }
        
        
        
    }
    
    @objc func OnEdit(_ sender : UIButton) {
        let dict = self.arrayCommentsList[sender.tag]
        let Messageid = dict["messageid"] as! String
        MessageId = Messageid
        let Comments = dict["content"] as! String
        self.textviewComment.text = Comments
        EditType = "1"
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.htEditView.constant = 213
            self.view.layoutIfNeeded()
        })
        
    }
    
    @objc func OnComments(_ sender : UIButton) {
        let dict = self.arrayCommentsList[sender.tag]
        let Mid = dict["messageid"] as! String
        
        
        let vc:WallCommentsViewController = self.storyboard?.instantiateViewController(withIdentifier: "WallCommentsViewController") as! WallCommentsViewController
        vc.MessageId = Mid
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAlert(strMessage:String) ->() {
        let actionSheetController: UIAlertController = UIAlertController(title: "Mensaje", message: strMessage, preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func webserviceAddComment(){
        let Para =
            ["fromuserid":"\(LoginId!)","touserid":"\(touserid!)",
             "wall_message":"\(textviewComment.text!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.addNewWall)"
        
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if (myData["response"] as? [String:Any]) != nil {
                            
                        }
                        self.textviewComment.text = ""
                        
                        self.CallWebserviceCommentList()
                        
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
    
    func CallWebserviceCommentList(){
        let Para =
            ["touserid":"\(touserid!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.wallPostList)"
        
        objActivity.startActivityIndicator()
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
                        objActivity.stopActivity()
                        
                        
                        DispatchQueue.main.async {
                            
                        }
                    }
                    
                    break
                case .failure(_):
                    objActivity.stopActivity()
                    print(response.result.error as Any)
                    break
                }
            }
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
                        
                        
                        self.CallWebserviceCommentList()
                        
                        
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
    
    //Edit Comments
    func webserviceEditComment(){
        let Para =
            ["messageid":"\(MessageId!)","wall_message":"\(textviewComment.text!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.editWall)"
        
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        _ = response.result.value as! [String :Any]
                        self.textviewComment.text = ""
                        self.CallWebserviceCommentList()
                        
                        UIView.animate(withDuration: 0.5, animations: { () -> Void in
                            self.htEditView.constant = 0
                            self.view.layoutIfNeeded()
                        })
                        
                        
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
    
    
    //Wall Favourite
    func webserviceWallFavourite(){
        let Para =
            ["messageid":"\(MessageId!)","userid":"\(touserid!)"] as [String : Any]
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
    
    
    
    
    
    
}
