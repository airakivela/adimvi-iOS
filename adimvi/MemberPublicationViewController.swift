//
//  MemberPublicationViewController.swift
//  adimvi
//
//  Created by javed carear  on 03/02/20.
//  Copyright © 2020 webdesky.com. All rights reserved.
//

import UIKit
import Alamofire
class MemberPublicationViewController: UIViewController {
    @IBOutlet weak var tableviewMemberPublication: UITableView!
    var arrayPulication =  [[String: Any]]()
    var UserID:String!
    var ProfileType:String!
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CallWebservicePulication()
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.darkGray]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
}
//MARK:- Extension TableView Delegate/DataSource Methods
extension MemberPublicationViewController : UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayPulication.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 520
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idetifier = "MembersPublicationTableViewCell"
        let cell:MembersPublicationTableViewCell = tableviewMemberPublication.dequeueReusableCell(withIdentifier: idetifier)as! MembersPublicationTableViewCell
        
        let dictData = self.arrayPulication[indexPath.row]
        if let Title = dictData["post_title"] as? String {
            cell.labelTitle.text = Title
        }
        
        if let CategoriesName = dictData["category_name"] as? String {
            cell.buttonCategoriesName.setTitle( CategoriesName, for: .normal)
        }
        
        
        //    if let Title = dictData["price"] as? String {
        //        cell.labelPrice.text = Title
        //    }
        if let Username = dictData["username"] as? String {
            cell.labelusName.text = Username
        }
        if let PostDescription = dictData["post_description"] as? String {
            cell.labeldescription.text = PostDescription
        }
        
        if let CategoriesName = dictData["cat_title"] as? String {
            cell.buttonCategoriesName.setTitle( CategoriesName, for: .normal)
        }
        
        if let CategoriesName = dictData["views"] as? String {
            cell.buttonSeen.setTitle( CategoriesName, for: .normal)
        }
        if let CategoriesName = dictData["total_message"] as? String {
            cell.buttonMessageCount.setTitle( CategoriesName, for: .normal)
        }
        
        if let CategoriesName = dictData["netvotes"] as? String {
            cell.buttonlike.setTitle( CategoriesName, for: .normal)
        }
        if let CategoriesName = dictData["post_time"] as? String {
            cell.buttonSeenTime.setTitle( CategoriesName, for: .normal)
        }
        
        let Image = dictData["post_image"] as! String
        cell.imageFollowers.sd_setImage(with: URL(string: Image), placeholderImage: UIImage(named: "Place"))
        
        if  let profilePic = dictData["avatarblobid"] as? String{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            cell.imgProfilePic.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        }
        
        if let hasRecentPost = dictData["hasRecentPost"] as? Int {
            if hasRecentPost == 1{
                if (dictData["userid"] as! String) != UserID {
                    cell.recentWallUV.layer.borderWidth = 2.0
                } else {
                    cell.recentWallUV.layer.borderWidth = 0.0
                }
            } else {
                cell.recentWallUV.layer.borderWidth = 0.0
            }
        }
        
        cell.buttonTap.tag = indexPath.row
        cell.buttonTap.addTarget(self, action: #selector(self.OnDetail(_:)), for: UIControl.Event.touchUpInside)
        
        cell.buttonCategoriesName.tag = indexPath.row
        cell.buttonCategoriesName.addTarget(self, action: #selector(self.OnCategories(_:)), for: UIControl.Event.touchUpInside)
        
        cell.buttonProfile.tag = indexPath.row
        cell.buttonProfile.addTarget(self, action: #selector(self.OnUsers(_:)), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    @objc func OnCategories(_ sender : UIButton) {
        let dict = self.arrayPulication[sender.tag]
        let ID = dict["categoryid"] as! String
        
        let vc: CategoriesDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "CategoriesDetailViewController")as! CategoriesDetailViewController
        vc.hidesBottomBarWhenPushed = true
        vc.CategoriesID = ID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    @objc func OnDetail(_ sender: UIButton) {
        let dict = self.arrayPulication[sender.tag]
        let PostId = dict["postid"] as! String
        
        let vc: PostDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier:"PostDetailsViewController")as! PostDetailsViewController
        vc.hidesBottomBarWhenPushed = true
        vc.PostID = PostId
        SharedManager.sharedInstance.PostId = PostId
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func OnUsers(_ sender : UIButton) {
        let dict = self.arrayPulication[sender.tag]
        let OtherId = dict["userid"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func OnPost(_ sender: UIButton) {
        let dict = self.arrayPulication[sender.tag]
        let PostId = dict["postid"] as! String
        let vc: ToPostVC = self.storyboard?.instantiateViewController(withIdentifier:"ToPostVC")as! ToPostVC
        vc.Postid = PostId
        vc.DraftStatus = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func CallWebservicePulication(){
        let Para =
            ["userid":"\(UserID!)","limit":"0","offset":"200"] as [String : Any]
        
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.getUserPublications)"
        
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["posts"]as? [[String:Any]]{
                                self.arrayPulication = Data
                                self.tableviewMemberPublication.reloadData()
                                if self.arrayPulication.count == 0{
                                    self.tableviewMemberPublication.isHidden = true
                                }else{
                                    self.tableviewMemberPublication.isHidden = false
                                }
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
    
    
}
