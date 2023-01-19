
//  favoriteMembersVC.swift
//  adimvi
//  Created by javed carear  on 18/06/19.



import UIKit
import Alamofire
class MembersVC: BaseViewController {
    @IBOutlet weak var tableviewMembers: UITableView!
    let defaults = UserDefaults.standard
     var Userid:String!
     var Postuserid:String!
     var arrayMembers =  [[String: Any]]()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        Userid = UserDefaults.standard.string(forKey: "ID")
        CallWebserviceMembers()
        
    }

    @IBAction func OnNotifications(_ sender: Any) {
        let vc: NotificationVC = self.storyboard?.instantiateViewController(withIdentifier:"NotificationVC")as! NotificationVC
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    @IBAction func OnSearch(_ sender: Any) {
    let vc: MemberSearchViewController = self.storyboard?.instantiateViewController(withIdentifier:"MemberSearchViewController")as! MemberSearchViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
   
    func CallWebserviceMembers(){
        let Para =
            ["userid":"\(Userid!)","limit":"0","offset":"50"] as [String : Any]
            let Api:String = "\(WebURL.BaseUrl)\(WebURL.getMemberList)"
        objActivity.startActivityIndicator()
       
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["members"]as? [[String:Any]]{
                                self.arrayMembers = Data
                                self.tableviewMembers.reloadData()
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
  
    func CallWebSetFollow(_ index: Int){
        let Para =
            ["entityid":"\(Postuserid!)","userid":"\(Userid!)"] as [String : Any]
            let Api:String = "\(WebURL.BaseUrl)\(WebURL.setUserFollowing)"
        objActivity.startActivityIndicator()
        let dict = arrayMembers[index] as [String: Any]
        if let Post = dict["post_followup"] as? String {
            if Post == "1"{
                NotificationCenter.default.post(name: .didChangePostByFollowUser, object: nil, userInfo: ["removeUserID": self.Postuserid!])
            }else{
                NotificationCenter.default.post(name: .didChangePostByFollowUser, object: nil)
            }
        }
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        self.CallWebserviceMembers()
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

extension MembersVC:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMembers.count
    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView(frame: .zero)
//
//        view.backgroundColor = UIColor.white
//        return view
//
//    }
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableviewMembers.dequeueReusableCell(withIdentifier: "MembersCell", for: indexPath) as! MembersCell
        
        let dictData = self.arrayMembers[indexPath.row]
        let Name = dictData["username"] as! String
        cell.labelName.text = Name
        let following = dictData["totalFollowing"] as! String
        cell.labelFollowing.text = "\(following) Siguiendo"
        let followers = dictData["totalFollowers"] as! String
        cell.labelFollowers.text = "\(followers) Seguidores"
        let Point = dictData["points"] as! String
        cell.labelPoints.text = Point
        if  let profilePic = dictData["avatarblobid"] as? String{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"


            cell.imgProfilePic.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        }
        if let Favourite = dictData["follow"] as? String{
            if Favourite == "1"{
                cell.buttonFollow.isHidden = true
                cell.buttonNotFollow.isHidden = false
            }else{
                cell.buttonFollow.isHidden = false
                cell.buttonNotFollow.isHidden = true
            }
        
            
        }
       
        cell.buttonTab.tag = indexPath.row
        cell.buttonTab.addTarget(self, action: #selector(self.OnUsers(_:)), for: UIControl.Event.touchUpInside)
        
        cell.buttonFollow.tag = indexPath.row
        cell.buttonFollow.addTarget(self, action: #selector(self.OnFollow(_:)), for: UIControl.Event.touchUpInside)

        cell.buttonNotFollow.tag = indexPath.row
        cell.buttonNotFollow.addTarget(self, action: #selector(self.OnFollow(_:)), for: UIControl.Event.touchUpInside)
        
        cell.buttonMembers.tag = indexPath.row
        cell.buttonMembers.addTarget(self, action: #selector(self.OnMembers(_:)), for: UIControl.Event.touchUpInside)
        
        return cell
        
    }
    @objc func OnUsers(_ sender: UIButton) {
        let dict = self.arrayMembers[sender.tag]
        let OtherId = dict["userid"] as! String
        self.defaults.set(OtherId, forKey: "OtherUserID")
        
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func OnMembers(_ sender: UIButton) {
        let dict = self.arrayMembers[sender.tag]
        let Userid = dict["userid"] as! String
        let vc: MemberPublicationViewController = self.storyboard?.instantiateViewController(withIdentifier:"MemberPublicationViewController")as! MemberPublicationViewController
           vc.UserID = Userid
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
    @objc func OnFollow(_ sender: UIButton) {
        let dict = self.arrayMembers[sender.tag]
        let OtherId = dict["userid"] as! String
        Postuserid = OtherId
        CallWebSetFollow(sender.tag)
        
    }
  
}


class MembersCell: UITableViewCell{
    
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var buttonFollow: UIButton!
    @IBOutlet weak var buttonNotFollow: UIButton!
    @IBOutlet weak var labelFollowers: UILabel!
    @IBOutlet weak var labelFollowing: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var buttonTab: UIButton!
     @IBOutlet weak var buttonMembers: UIButton!
    @IBOutlet weak var labelPoints: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
}
