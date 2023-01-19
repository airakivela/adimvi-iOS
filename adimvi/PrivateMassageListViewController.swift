//  PrivateMassageListViewController.swift
//  adimvi
//  Created by javed carear  on 01/02/20.
//  Copyright © 2020 webdesky.com. All rights reserved.


import UIKit
import Alamofire
import SDWebImage
class PrivateMassageListViewController: UIViewController {
    @IBOutlet weak var tableviewPMassageList: UITableView!
    var UserID:String!
    var ProfileType:String!
    let defaults = UserDefaults.standard
    var arrayPMassageList =  [[String: Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        UserID = UserDefaults.standard.string(forKey: "ID")
        tableviewPMassageList.estimatedRowHeight = 100
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CallWebservicePMassageList()
    }
    
    @IBAction func OnCancel(_ sender: Any) {
        
    }
    
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
//MARK:- Extension TableView Delegate/DataSource Methods
extension PrivateMassageListViewController : UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayPMassageList.count
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
        let idetifier = "PmassageListTableViewCell"
        let cell: PmassageListTableViewCell = tableviewPMassageList.dequeueReusableCell(withIdentifier: idetifier)as!  PmassageListTableViewCell
        let dictData = self.arrayPMassageList[indexPath.row]
        
        if let username = dictData["user_name"] as? String{
            cell.labelUserName.text = username
        }
        if let Content = dictData["content"] as? String{
            cell.labelMassage.text = Content
        }
        if  let profilePic = dictData["user_image"] as? String{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            cell.imgProfile.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        }
        
        if let hasRecentPost = dictData["hasRecentPost"] as? Int {
            if hasRecentPost == 1{
                if (dictData["otherUser"] as! String) != UserID {
                    cell.recentWallUV.layer.borderWidth = 2.0
                } else {
                    cell.recentWallUV.layer.borderWidth = 0.0
                }
            } else {
                cell.recentWallUV.layer.borderWidth = 0.0
            }
        }
        
        if let verify = dictData["verify"] as? String {
            cell.verifiedMarker.isHidden = verify == "1" ? false : true
        }
        if let time = dictData["created"] as? String {
            cell.lastMsgTime.text = time
        }
        cell.buttonProfile.tag = indexPath.row
        cell.buttonProfile.addTarget(self, action: #selector(self.OnProfile(_:)), for: UIControl.Event.touchUpInside)
        return cell
    }
    
    @objc func OnProfile(_ sender : UIButton) {
        let dict = self.arrayPMassageList[sender.tag]
        let ToUserId = dict["otherUser"] as! String
        self.defaults.set(ToUserId, forKey: "OtherUserID")
        let vc: PrivateMessageViewController = self.storyboard?.instantiateViewController(withIdentifier:"PrivateMessageViewController")as! PrivateMessageViewController
        vc.OtherUserId = ToUserId
        vc.targetUserName = dict["user_name"] as? String
        vc.targetUserAvatar = dict["user_image"] as? String
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
    
    func CallWebservicePMassageList(){
        let Para =
            ["userid":"\(UserID!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.allPrivateMessagesList)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        let code = myData["code"] as! String
                        
                        if code == "200"{
                            self.tableviewPMassageList.isHidden = false
                            if let arr = myData["response"] as? [String:Any]{
                                if let Data = arr["message"]as? [[String:Any]]{
                                    self.arrayPMassageList = Data
                                    self.tableviewPMassageList.reloadData()
                                }
                            }
                        } else {
                            self.tableviewPMassageList.isHidden = true
                        }
                        
                        DispatchQueue.main.async {
                            
                        }
                    }
                    
                    break
                case .failure(_):
                    print(response.result.error as Any)
                    break
                }
            }
    }
}
