//
//  ProfilerootViewController.swift
//  adimvi
//
//  Created by Apple on 14/02/21.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import Foundation
import UIKit
import TwitterProfile
import Alamofire

class ProfilerootViewController : UIViewController, UIScrollViewDelegate, TPDataSource, TPProgressDelegate {
    
    var headerVC: ProfileVC?
    
    let refresh = UIRefreshControl()
    var ProfileType:String!
    var userId:String!
    var LoginUsers:String!
    var OtherUsers:String!
    @IBOutlet weak var buttonFollow: UIButton!
    @IBOutlet weak var htUserStack: NSLayoutConstraint!
    @IBOutlet weak var wallet: UIBarButtonItem!
    @IBOutlet weak var viewSettingbutton: UIView!
    @IBOutlet weak var viewFollow: UIView!
    @IBOutlet weak var Backbutton: UIBarButtonItem!
    @IBOutlet weak var buttonWallet: UIBarButtonItem!
    @IBOutlet weak var buttonRightMenu1: UIBarButtonItem!
    
    var isFromPostDetail: Bool = false
    var orginalPostData: [String: Any] = [String: Any]()
    
    var isFromOriginalWall: Bool = false
    var originalWallData: [String: Any] = [String: Any]()
    
    var isFromNotificationPost: Bool = false
    var usernameLB: UILabel = UILabel()
    var imgVerify: UIImageView = UIImageView()
    var WallType:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        //implement data source to configure tp controller with header and bottom child viewControllers
        //observe header scroll progress with TPProgressDelegate
        self.tp_configure(with: self, delegate: self)
        LoginUsers = UserDefaults.standard.string(forKey: "ID")
        ProfileType = SharedManager.sharedInstance.otherProfile
        if  ProfileType == "1"{
            if isFromPostDetail {
                userId = UserDefaults.standard.string(forKey: "ID")
            } else {
                userId = UserDefaults.standard.string(forKey: "OtherUserID")
            }
            buttonRightMenu1.isEnabled = false
            buttonRightMenu1.tintColor = .clear
            
            wallet.isEnabled = false
            wallet.tintColor = UIColor.clear
            
            self.navigationItem.rightBarButtonItems?.remove(at: 0)
        } else {
            userId = UserDefaults.standard.string(forKey: "ID")
            Backbutton.isEnabled = false
            Backbutton.tintColor = UIColor.clear
        }
        callUpdateViewWallCount()
        initLeftItem()
        self.tabBarController?.tabBar.isHidden = false
        self.hidesBottomBarWhenPushed = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func initLeftItem() {
        let leftView = UIStackView()
        leftView.alignment = .center
        leftView.distribution = .fill
        leftView.axis = .horizontal
        leftView.spacing = 6.0
        
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "Gback.png"), for: .normal)
        leftView.addArrangedSubview(button)
        button.widthAnchor.constraint(equalToConstant: 32).isActive = true
        button.heightAnchor.constraint(equalToConstant: 32).isActive = true
        button.addTarget(self, action: #selector(onBackPressed), for: .touchUpInside)
                
        usernameLB = UILabel()
        usernameLB.textColor = .label
        usernameLB.font = .boldSystemFont(ofSize: 18)
        leftView.addArrangedSubview(usernameLB)
        usernameLB.widthAnchor.constraint(lessThanOrEqualToConstant: 160.0).isActive = true
                
        imgVerify.image = UIImage(named: "ic_facebook_check_marker")
        leftView.addArrangedSubview(imgVerify)
        imgVerify.widthAnchor.constraint(equalToConstant: 16.0).isActive = true
        imgVerify.heightAnchor.constraint(equalToConstant: 16.0).isActive = true
        
        if ProfileType == "1" {
            button.isHidden = false
        } else {
            button.isHidden = true
        }
        
        let leftButton = UIBarButtonItem(customView: leftView)
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    func callUpdateViewWallCount() {
        OtherUsers = UserDefaults.standard.string(forKey: "OtherUserID")
        userId = UserDefaults.standard.string(forKey: "ID")
        if OtherUsers == userId {
            return
        }
        if let entityID = OtherUsers {
            let param = ["userid": "\(entityID)"]
            let myService:String = "\(WebURL.BaseUrl)\(WebURL.UPDATE_USER_REWALL_COUNT)"
            Alamofire.request(myService, method: .post, parameters: param)
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
        } else {
            return
        }
    }
    
    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func OnWriteMenu(_ sender: UIButton) {
        headerVC?.OnWriteMenu(with: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.hidesBottomBarWhenPushed = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.hidesBottomBarWhenPushed = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func handleRefreshControl() {
        print("refreshing")
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.refresh.endRefreshing()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    //MARK: TPDataSource
    func headerViewController() -> UIViewController {
        headerVC = UIStoryboard.init(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC
        headerVC?.isFromPostDetail = self.isFromPostDetail
        headerVC?.delegate = self
        return headerVC!
    }
    
    var bottomVC: XLPagerTabStripExampleViewController!
    
    func bottomViewController() -> UIViewController & PagerAwareProtocol {
        bottomVC = UIStoryboard.init(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier: "XLPagerTabStripExampleViewController") as? XLPagerTabStripExampleViewController
        bottomVC.isFromPostDetail = isFromPostDetail
        bottomVC.originalPostData = self.orginalPostData
        bottomVC.isFromNotificationPost = isFromNotificationPost
        return bottomVC
    }
    
    //stop scrolling header at this point
    func minHeaderHeight() -> CGFloat {
        return (topInset + 0)
    }
    
    //MARK: TPProgressDelegate
    func tp_scrollView(_ scrollView: UIScrollView, didUpdate progress: CGFloat) {
        headerVC?.update(with: progress, minHeaderHeight: minHeaderHeight())
    }
    
    func tp_scrollViewDidLoad(_ scrollView: UIScrollView) {
        refresh.tintColor = .white
        refresh.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        let refreshView = UIView(frame: CGRect(x: 0, y: 30, width: 0, height: 0))
        scrollView.addSubview(refreshView)
        refreshView.addSubview(refresh)
    }
}

extension ProfilerootViewController: ProfileVCDelegate {
    func didFinishUserName(name: String, verify: String) {
        usernameLB.text = name
        if verify == "1" {
            imgVerify.isHidden = false
        } else {
            imgVerify.isHidden = true
        }
    }
}
