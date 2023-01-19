

import UIKit
import Alamofire

var isVerifiedUser: Bool = false

class TabViewController: UITabBarController,UITabBarControllerDelegate {
    var Notify:String!
    var Userid:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        CallWebserviceGetProfile()
        
    }
    
    
    
    // UITabBarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        SharedManager.sharedInstance.otherProfile = "0"
        
        self.tabBar.items![3].badgeValue = nil
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Userid = UserDefaults.standard.string(forKey: "ID")
        CallWebserviceSalesNotify()
        if isClickedSaleNotification {
            didReceiveSaleNotification()
        }
        
        if isClickNewPostNotification {
            didReceiveNewPostNotification()
        }
        if let hasnewPost = UserDefaults.standard.value(forKey: "HASNEWPOST") as? Bool{
            if hasnewPost {
                self.tabBar.items![1].badgeValue = "●"
                self.tabBar.items![1].badgeColor = .clear
                self.tabBar.items![1].setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .normal)
            }
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveSaleNotification), name: .didClickSaleNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNewPostNotification), name: .didClickNewPost, object: nil)
    }
    
    @objc func didReceiveNewPostNotification() {
        self.selectedIndex = 1
    }
    
    @objc func didReceiveSaleNotification() {
        self.selectedIndex = 3
    }
    
    func CallWebserviceSalesNotify(){
        let Para = ["userid":"\(Userid!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.salesNotify)"
        
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            let Noti = arr["total_notify"]as!String
                            if Noti == "0"{
                                print("Yes")
                            } else {
                                self.tabBar.items![3].badgeValue = Noti
                            }
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
    
    func CallWebserviceGetProfile(){
        let Para =
            ["userid":"\(UserDefaults.standard.string(forKey:"ID")!)","login_userid":"\(UserDefaults.standard.string(forKey:"ID")!)"
            ] as [String : Any]
        
        print(Para)
        let myService:String = "\(WebURL.BaseUrl)\(WebURL.getProfile)"
        
        Alamofire.request(myService, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [[String:Any]]{
                            let profilePic = arr[0]["avatarblobid"] as! String
                            if profilePic == "" {
                                return
                            }
                            let isVerified = arr[0]["isVerify"] as! String
                            isVerifiedUser = isVerified == "1" ? true : false
                            let imageURL = "\(WebURL.ImageUrl)\(profilePic)"
                            DispatchQueue.global().async {
                                if let data = try? Data(contentsOf: URL(string:imageURL)!) {
                                    DispatchQueue.main.async {
                                        let profileImage = UIImage(data: data)?.resizedImage(newWidth: 40.0).roundedImage.withRenderingMode(.alwaysOriginal)
                                        self.addSubviewToLastTabItem(profileImage!)
                                    }
                                }
                            }
                            
                            if let userAD = arr[0]["fadSense"] as? String {
                                UserDefaults.standard.setValue(userAD, forKey: "USERAD")
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
    
}

extension UIImage {
    var roundedImage: UIImage {
        let rect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1)
        UIBezierPath(roundedRect: rect, cornerRadius: self.size.height).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func resizedImage(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHieght = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHieght))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHieght))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension UITabBarController {
    func addSubviewToLastTabItem(_ imageName: UIImage) {
        if let lastTabBarButton = self.tabBar.subviews.last, let tabItemImageView = lastTabBarButton.subviews.first {
            if let accountTabBarItem = self.tabBar.items?.last {
                accountTabBarItem.selectedImage = nil
                accountTabBarItem.image = nil
            }
            let imgView = UIImageView()
            imgView.frame = tabItemImageView.frame
            imgView.layer.cornerRadius = tabItemImageView.frame.height/2
            imgView.layer.masksToBounds = true
            imgView.contentMode = .scaleAspectFill
            imgView.clipsToBounds = true
            imgView.image = imageName
            self.tabBar.subviews.last?.addSubview(imgView)
        }
    }
}
