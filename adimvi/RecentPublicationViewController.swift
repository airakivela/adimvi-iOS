//  RecentPublicationViewController.swift
//  adimvi
//  Created by javed carear  on 23/08/19.
//  Copyright © 2019 webdesky.com. All rights reserved.

import UIKit
import Alamofire
import SDWebImage
class RecentPublicationViewController: UIViewController {
    var ProfileType:String!
    var Userid:String!
    var arrayPublication =  [[String: Any]]()
    @IBOutlet weak var tableviewRecentPub: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        ProfileType = SharedManager.sharedInstance.otherProfile
        if  ProfileType == "1" {
            Userid = UserDefaults.standard.string(forKey: "OtherUserID")
            
        }else{
            Userid = UserDefaults.standard.string(forKey: "ID")
            
        }
      CallWebservicePublication()
    }
    


}
//MARK:- Extension TableView Delegate/DataSource Methods
extension RecentPublicationViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayPublication.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 370
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idetifier = "RecentPubViewCell"
        let cell:RecentPubViewCell = tableviewRecentPub.dequeueReusableCell(withIdentifier: idetifier)as! RecentPubViewCell
       
        let dictData = self.arrayPublication[indexPath.row]
        
        if let Title = dictData["post_title"] as? String {
            cell.labelTitle.text = Title
        }

//        if let Username = dictData["username"] as? String {
//            cell.labelusName.text = Username
//        }

        if let CategoriesName = dictData["views"] as? String {
            cell.buttonSeen.setTitle( CategoriesName, for: .normal)
        }
        if let CategoriesName = dictData["total_message"] as? String {
            cell.buttonMessageCount.setTitle( CategoriesName, for: .normal)
        }
        
        
        
        if let CategoriesName = dictData["netvotes"] as? String {
            cell.buttonlike.setTitle( CategoriesName, for: .normal)
        }
        
        
        let Image = dictData["post_image"] as! String
        cell.imagePost.sd_setImage(with: URL(string: Image), placeholderImage: UIImage(named: "Place.png"))
        
        
//        if  let profilePic = dictData["avatarblobid"] as? String{
//            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
//
//
//            cell.imgProfilePic.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "UserDummy.png"))
//        }
//
        cell.ButtonTap.tag = indexPath.row
        cell.ButtonTap.addTarget(self, action: #selector(self.OnDetail(_:)), for: UIControl.Event.touchUpInside)
        
        
        return cell
  }
    @objc func OnDetail(_ sender: UIButton) {
        let dict = self.arrayPublication[sender.tag]
        let PostId = dict["postid"] as! String
        
        
        let vc: PostDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier:"PostDetailsViewController")as! PostDetailsViewController
        vc.hidesBottomBarWhenPushed = true
        vc.PostID = PostId
        SharedManager.sharedInstance.PostId = PostId
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    
    
    func CallWebservicePublication(){
        let Para =
            ["userid":"\(Userid!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.getProfileRecentPost)"
        
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
                                self.arrayPublication = Data
                                
                                self.tableviewRecentPub.reloadData()
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
