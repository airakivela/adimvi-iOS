//  PostTagViewController.swift
//  adimvi
//  Created by javed carear  on 27/09/19.
//  Copyright © 2019 webdesky.com. All rights reserved.


import UIKit
import Alamofire
import SDWebImage
class PostTagViewController: UIViewController {
    @IBOutlet weak var tableviewPostTag: UITableView!
    var arrayFollowing =  [[String: Any]]()
    var Tag:String!
    var UserID:String!
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
    UserID = UserDefaults.standard.string(forKey: "ID")
    CallWebserviceTagPost()
     self.title = "\(Tag!)"
        
    }
    
    @IBAction func OnDetail(_ sender: Any) {
    }
    @IBAction func OnBack(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
       }
}
//MARK:- Extension TableView Delegate/DataSource Methods
extension PostTagViewController : UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayFollowing.count
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
        let idetifier = "PostTagViewCell"
        let cell:PostTagViewCell = tableviewPostTag.dequeueReusableCell(withIdentifier: idetifier)as! PostTagViewCell
        
        let dictData = self.arrayFollowing[indexPath.row]

        if let Title = dictData["post_title"] as? String {
            cell.labelTitle.text = Title
        }
//        if let Title = dictData["price"] as? String {
//            cell.labelPrice.text = Title
//        }
        if let Username = dictData["username"] as? String {
            cell.labelusName.text = Username
        }
        if let PostDescription = dictData["post_description"] as? String {
            cell.labeldescription.text = PostDescription
        }

        if let CategoriesName = dictData["category_name"] as? String {
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
            cell.buttonTime.setTitle( CategoriesName, for: .normal)
        }

        let Image = dictData["post_image"] as! String
        cell.imageFollowers.sd_setImage(with: URL(string: Image), placeholderImage: UIImage(named: "Place.png"))


        if  let profilePic = dictData["avatarblobid"] as? String{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
           

            cell.imgProfilePic.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        }  else {
            cell.imgProfilePic.image = UIImage(named: "Splaceicon")
        }
        cell.buttonProfile.tag = indexPath.row
        cell.buttonProfile.addTarget(self, action: #selector(self.OnProfile(_:)), for: UIControl.Event.touchUpInside)
        
        cell.buttonDetail.tag = indexPath.row
        cell.buttonDetail.addTarget(self, action: #selector(self.OnPost(_:)), for: UIControl.Event.touchUpInside)
        
        
        return cell
  }
    
    @objc func OnProfile(_ sender : UIButton) {
        let dict = self.arrayFollowing[sender.tag]
        let OtherId = dict["userid"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func OnPost(_ sender: UIButton) {
         let dict = self.arrayFollowing[sender.tag]
         let PostId = dict["postid"] as! String
         let vc: PostDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier:"PostDetailsViewController")as! PostDetailsViewController
        vc.hidesBottomBarWhenPushed = true
         vc.PostID = PostId
         SharedManager.sharedInstance.PostId = PostId
         self.navigationController?.pushViewController(vc, animated: true)
         
    
     }
    
    
    func CallWebserviceTagPost(){
        let Para =
            ["userid":"\(UserID!)","tagid":"\(Tag!)","limit":"0","offset":"20"] as [String : Any]
        print(Para)
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.popularTagPostList)"
        
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
                                self.arrayFollowing = Data
                                self.tableviewPostTag.reloadData()
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
