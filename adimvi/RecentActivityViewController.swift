
//  RecentActivityViewController.swift
//  adimvi
//  Created by javed carear  on 23/08/19.
//  Copyright © 2019 webdesky.com. All rights reserved.

import UIKit
import Alamofire
class RecentActivityViewController:UIViewController {
@IBOutlet weak var tableviewRecentPublication: UITableView!
    var arrayNotification =  [[String: Any]]()
    @IBOutlet weak var emptyLabel: UILabel!
    let defaults = UserDefaults.standard
     var ProfileType:String!
    var UserID:String!
    override func viewDidLoad() {
        super.viewDidLoad()
         ProfileType = SharedManager.sharedInstance.otherProfile
        if  ProfileType == "1"{
                UserID = UserDefaults.standard.string(forKey: "OtherUserID")
               }else {
              UserID = UserDefaults.standard.string(forKey: "ID")
    }
         tableviewRecentPublication.estimatedRowHeight = 70
        CallWebserviceRecentPublication()
    }
    
    @IBAction func Onback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
//MARK:- Extension TableView Delegate/DataSource Methods
extension RecentActivityViewController : UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayNotification.count == 0{ tableviewRecentPublication.isHidden = true
            emptyLabel.isHidden = false
            return 0
            
        } else {
            emptyLabel.isHidden = true; tableviewRecentPublication.isHidden = false
            return arrayNotification.count
            
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idetifier = "RecentActivityTableViewCell"
        let cell:RecentActivityTableViewCell = tableviewRecentPublication.dequeueReusableCell(withIdentifier: idetifier)as! RecentActivityTableViewCell
        
        let dictData = self.arrayNotification[indexPath.row]
 

        if let content = dictData["title"] as? String{
            cell.labelActivityTitle.text = content
        }
        
        
        if let Created = dictData["created"] as? String {
            cell.LabelTime.text = Created
        }
        
        if let CategotiesName = dictData["msg"] as? String {
            cell.buttonActivityName.setTitle(CategotiesName, for: .normal)
        }
        cell.buttonPostDetail.tag = indexPath.row
        cell.buttonPostDetail.addTarget(self, action: #selector(self.OnDetail(_:)), for: UIControl.Event.touchUpInside)
          return cell
  }
    @objc func OnDetail(_ sender: UIButton) {
        let dict = self.arrayNotification[sender.tag] 
        let PostId = dict["postid"] as! String
        let Status = dict["type"] as! String
       
         if Status == "Wall"||Status == "Favorite"||Status == "Re_Wall"{
              let OtherId = dict["userid"] as! String
                   self.defaults.set(OtherId, forKey: "OtherUserID")
                   let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
                   SharedManager.sharedInstance.otherProfile = "1"
                   self.navigationController?.pushViewController(vc, animated: true)
         }else{
        let vc: PostDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier:"PostDetailsViewController")as! PostDetailsViewController
            vc.hidesBottomBarWhenPushed = true
                vc.PostID = PostId
                   SharedManager.sharedInstance.PostId = PostId
                   self.navigationController?.pushViewController(vc, animated: true)
          
        }
    }
    func CallWebserviceRecentPublication(){
        objActivity.startActivityIndicator()
        let Para =
            ["userid":"\(UserID!)"] as [String : Any]
        print(Para)
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.userRecentActivity)"
        
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["activity"]as? [[String:Any]]{
                                self.arrayNotification = Data
                               self.tableviewRecentPublication.reloadData()
                            }
                        }
                        
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
