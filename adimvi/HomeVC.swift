
//  HomeVC.swift
//  adimvi
//  Created by javed carear  on 17/06/19.
//  Copyright © 2019 webdesky.com. All rights reserved.


import UIKit
import Alamofire
import SDWebImage
import UserNotifications
import TangramKit
import SwiftPullToRefresh
import Firebase

class HomeVC: BaseViewController{
    @IBOutlet weak var buttonPosts: UIButton!
    @IBOutlet weak var buttonMembers: UIButton!
    @IBOutlet weak var buttonTag: UIButton!
    @IBOutlet weak var viewSearchType: UIView!
    @IBOutlet weak var recentWallSV: UIStackView!
    @IBOutlet weak var recentWallCV: UICollectionView!
    @IBOutlet weak var recentWallLB: UILabel!
    @IBOutlet weak var recentWallTopSpace: NSLayoutConstraint!
    
    @IBOutlet weak var collectionHomeHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionHome: UICollectionView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var ViewRightmenu: UIView!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var collectionFeature: UICollectionView!
    @IBOutlet weak var chatRoomBI: UIBarButtonItem!
    
    @IBOutlet weak var WellButton: BadgeBarButtonItem!
    @IBOutlet weak var verifiedMarker: UIImageView!
    
    @IBOutlet weak var parentScrollVIew: UIScrollView!
    var gameTimer: Timer!
    var reseContentOffset : CGFloat = 0.0
    var Userid:String!
    var Well:NSInteger!
    //var Well = 0
    var ImageStatus = "0"
    var SearchType = "post"
    let defaults = UserDefaults.standard
    @IBOutlet weak var tableviewSearch: UITableView!
    @IBOutlet weak var SearchMembers: UISearchBar!
    var arrayProfile = [[String: Any]]()
    var filterData = [String]()
    var issearching = false
    var Data = [String]()
    var arraySearchProduct =  [[String: Any]]()
    var arrayCategories =  [[String: Any]]()
    var arrayFeatured = [[String: Any]]()
    
    var arrayTags =  [[String: Any]]()
    
    var arrayRecntWall = [[String: Any]]()
    
    var goingUp: Bool?
    var childScrollingDownDueToParent = false
    var childScrollView: UIScrollView {
        return collectionHome
    }
    
    var roomExistHandler: DatabaseHandle?
    
    var imgRoom: UIImageView = {
        let imgRoom = UIImageView()
        imgRoom.translatesAutoresizingMaskIntoConstraints = false
        imgRoom.image = UIImage(named: "ic_room")?.withRenderingMode(.alwaysTemplate)
        imgRoom.tintColor = UIColor(named: "Dark grey (Dark mode)")
        imgRoom.isUserInteractionEnabled = true
        return imgRoom
    }()
    
    var gifRoom: UIImageView = {
        let gifRoom = UIImageView()
        gifRoom.translatesAutoresizingMaskIntoConstraints = false
        gifRoom.setGifImage(UIImage(gifName: "room.gif"))
        gifRoom.isUserInteractionEnabled = true
        return gifRoom
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Userid = UserDefaults.standard.string(forKey: "ID")
        
        CallWebserviceGetProfile()
        tableviewSearch.estimatedRowHeight = 48
        
        SearchMembers.delegate = self
        SearchMembers.delegate = self
        let backgroundImage = getImageWithCustomColor(color: .clear, size: CGSize(width: UIScreen.main.bounds.size.width, height: 50))
        SearchMembers.setSearchFieldBackgroundImage(backgroundImage, for: .normal)
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)        
        parentScrollVIew.delegate = self
        verifiedMarker.isHidden = true
        
        
        collectionFeature.delegate = self
        collectionFeature.dataSource = self
        
        recentWallCV.delegate = self
        recentWallCV.dataSource = self
        
        parentScrollVIew.spr_setIndicatorHeader {
            self.CallWebServiceRecentWalls()
        }
        
        let stackUV = UIStackView()
        stackUV.axis = .horizontal
        stackUV.spacing = 0.0
        stackUV.distribution = .fillEqually
        stackUV.isUserInteractionEnabled = true
        stackUV.addArrangedSubview(gifRoom)
        stackUV.addArrangedSubview(imgRoom)
        chatRoomBI.customView = stackUV
        stackUV.centerXAnchor.constraint(equalTo: chatRoomBI.customView!.centerXAnchor).isActive = true
        stackUV.centerYAnchor.constraint(equalTo: chatRoomBI.customView!.centerYAnchor).isActive = true
        stackUV.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        stackUV.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        gifRoom.isHidden = true
        chatRoomBI.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapRoom)))
        stackUV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapRoom)))
        
        if UserDefaults.standard.bool(forKey: "PassedGuide") == true {
            return
        } else {
            let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier: "GuideVC") as! GuideVC
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc func didTapRoom() {
        self.performSegue(withIdentifier: "RoomList", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CallWebserviceCaregories()
        if isClickedNotification {
            didComeNotification()
        }
        if isClickFollowRoom {
            didComeFollowRoom()
        }
        CallWebServiceRecentWalls()
        NotificationCenter.default.addObserver(self, selector: #selector(didComeNotification), name: .didClickNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didComeFollowRoom), name: .didClickRoom, object: nil)
        if !gifRoom.isAnimatingGif() {
            gifRoom.startAnimatingGif()
        }
        initFireChatRoom()
    }
    
    func initFireChatRoom() {
        roomExistHandler = FireUtil.firebaseRef.fireDBRoomIDS.observe(.value) { [self] (snap) in
            if snap.childrenCount > 0 {
                imgRoom.isHidden = true
                gifRoom.isHidden = false
            } else {
                imgRoom.isHidden = false
                gifRoom.isHidden = true
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if gifRoom.isAnimatingGif() {
            gifRoom.stopAnimatingGif()
        }
        FireUtil.firebaseRef.fireDBRoomIDS.removeObserver(withHandle: roomExistHandler!)
    }
    
    @objc func didComeNotification() {
        let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        self.navigationController!.pushViewController(vc, animated: false)
    }
    
    @objc func didComeFollowRoom() {
        let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier: "ChatRoomListVC") as! ChatRoomListVC
        self.navigationController!.pushViewController(vc, animated: false)
    }
    
    @IBAction func OnProfile(_ sender: Any) {
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        // SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        SearchMembers.layoutIfNeeded()
        SearchMembers.layoutSubviews()
        let textFieldInsideUISearchBar = SearchMembers.value(forKey: "searchField") as? UITextField
        textFieldInsideUISearchBar?.backgroundColor = UIColor(named: "Light grey (Dark mode)")
        textFieldInsideUISearchBar?.font = textFieldInsideUISearchBar?.font?.withSize(15)
        textFieldInsideUISearchBar?.layer.cornerRadius = 8.0
        textFieldInsideUISearchBar?.clipsToBounds = true
        SearchMembers.layer.borderWidth = 0
        SearchMembers.layer.borderColor = UIColor.clear.cgColor
        SearchMembers.searchBarStyle = .minimal
        SearchMembers.layoutIfNeeded()
        SearchMembers.layoutSubviews()
    }
    
    func getImageWithCustomColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    @IBAction func OnSearch(_ sender: UIButton) {
        if sender.tag == 1{
            buttonPosts.setTitleColor(.darkGray, for: .normal)
            buttonMembers.setTitleColor(.lightGray, for: .normal)
            buttonTag.setTitleColor(.lightGray, for: .normal)
            SearchType = "post"
            ImageStatus = "0"
            CallWebserviceSearch()
        }
        if sender.tag  == 2{
            buttonPosts.setTitleColor(.lightGray, for: .normal)
            buttonMembers.setTitleColor(.darkGray, for: .normal)
            buttonTag.setTitleColor(.lightGray, for: .normal)
            SearchType = "member"
            ImageStatus = "1"
            CallWebserviceSearch()
        }
        if sender.tag == 3 {
            buttonPosts.setTitleColor(.lightGray, for: .normal)
            buttonMembers.setTitleColor(.lightGray, for: .normal)
            buttonTag.setTitleColor(.darkGray, for: .normal)
            SearchType = "tag"
            ImageStatus = "0"
            CallWebserviceSearch()
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    //UIScrollView INT TO COUNT
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        _ = round(scrollView.contentOffset.x / scrollView.frame.size.width)
    }
    
    @objc func goToPoint() {
        DispatchQueue.main.async() {
            UIView.animate(withDuration: 0.4, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                self.reseContentOffset = self.collectionHome.frame.size.width
                    + self.collectionHome.contentOffset.x  + 10
                if self.reseContentOffset  <  self.collectionHome.contentSize.width    {
                    self.collectionHome.contentOffset.x = self.reseContentOffset
                    _ = round(self.collectionHome.contentOffset.x / self.collectionHome.frame.size.width)
                }
                else{
                    _ = round(self.collectionHome.contentOffset.y / self.collectionHome.frame.size.width)
                    self.reseContentOffset = 0.0
                    self.collectionHome.contentOffset.x = 0
                }
            }, completion: nil)
        }
    }
    
    @IBAction func OnMembers(_ sender: Any) {
        let vc:MembersVC = self.storyboard?.instantiateViewController(withIdentifier: "MembersVC") as! MembersVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func OnFollowers(_ sender: Any) {
        let vc:FollowingSegmentViewController = self.storyboard?.instantiateViewController(withIdentifier: "FollowingSegmentViewController") as! FollowingSegmentViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func OnTapSegment(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            let vc:MostActiveVC = self.storyboard?.instantiateViewController(withIdentifier: "MostActiveVC") as! MostActiveVC
            vc.Webservice = "getMostActivePost"
            vc.SegmentType = "0"
            vc.labelTitle.title = "TENDENCIAS"
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 2:
            let vc:MostActiveVC = self.storyboard?.instantiateViewController(withIdentifier: "MostActiveVC") as! MostActiveVC
            vc.Webservice = "getRecentPost"
            vc.SegmentType = "0"
            vc.labelTitle.title = "RECIENTES"
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 3:
            let vc:MostActiveVC = self.storyboard?.instantiateViewController(withIdentifier: "MostActiveVC") as! MostActiveVC
            vc.Webservice = "getMostVotedPost"
            vc.SegmentType = "0"
            vc.labelTitle.title = "MÁS VOTADOS"
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 4:
            let vc:MostActiveVC = self.storyboard?.instantiateViewController(withIdentifier: "MostActiveVC") as! MostActiveVC
            vc.Webservice = "Post"
            vc.SegmentType = "0"
            vc.labelTitle.title = "MÁS VISITADOS"
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 5:
            let vc:MostActiveVC = self.storyboard?.instantiateViewController(withIdentifier: "MostActiveVC") as! MostActiveVC
            vc.Webservice = "get"
            vc.SegmentType = "0"
            vc.labelTitle.title = "MÁS COMENTADOS"
            self.navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
    }
}

extension HomeVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        goingUp = scrollView.panGestureRecognizer.translation(in: scrollView).y < 0
        let parentViewMaxContentYOffset = parentScrollVIew.contentSize.height - parentScrollVIew.frame.height
        print(parentViewMaxContentYOffset)
        if goingUp! {
            if scrollView == childScrollView {
                // if parent scroll view is't scrolled maximum (i.e. menu isn't sticked on top yet)
                if parentScrollVIew.contentOffset.y < parentViewMaxContentYOffset && !childScrollingDownDueToParent {
                    parentScrollVIew.contentOffset.y = max(min(parentScrollVIew.contentOffset.y + childScrollView.contentOffset.y, parentViewMaxContentYOffset), 0)
                    childScrollView.contentOffset.y = 0
                }
            }
        } else {
            if scrollView == childScrollView {
                if childScrollView.contentOffset.y < 0 && parentScrollVIew.contentOffset.y > 0 {
                    parentScrollVIew.contentOffset.y = max(parentScrollVIew.contentOffset.y - abs(childScrollView.contentOffset.y), 0)
                }
            }
            // if downward scrolling view is parent scrollView
            if scrollView == parentScrollVIew {
                if childScrollView.contentOffset.y > 0 && parentScrollVIew.contentOffset.y < parentViewMaxContentYOffset {
                    childScrollingDownDueToParent = true
                    childScrollView.contentOffset.y = max(childScrollView.contentOffset.y - (parentViewMaxContentYOffset - parentScrollVIew.contentOffset.y), 0)
                    // stick parent view to top coz it's scrolled offset is assigned to child
                    parentScrollVIew.contentOffset.y = parentViewMaxContentYOffset
                    childScrollingDownDueToParent = false
                }
            }
        }
    }
}

//Mark:- Collection view delegate methods
extension HomeVC:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    
}
// Mark:- Collection view data source and layout menthods
extension HomeVC:UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == collectionFeature || collectionView == recentWallCV {
            return 1
        } else {
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionHome {
            if section == 1 {
                return 1
            } else {
                return arrayCategories.count
            }
        } else if collectionView == recentWallCV {
            return arrayRecntWall.count
        } else {
            return arrayFeatured.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionHome {
            if indexPath.section == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularTagCollectionViewCell", for: indexPath) as! popularTagCollectionViewCell
                cell.initCell(data: arrayTags)
                cell.delegate = self
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCVCell", for: indexPath) as! HomeCVCell
                let dictData = self.arrayCategories[indexPath.item]
                let Title = dictData["title"] as! String
                cell.labelTitle.text = Title
                let Image = dictData["image"] as! String
                cell.imgCategories.sd_setImage(with: URL(string: Image), placeholderImage: UIImage(named: "Place.png"))
                cell.buttonTap.tag = indexPath.item
                cell.buttonTap.addTarget(self, action: #selector(self.tapAction(_:)), for: UIControl.Event.touchUpInside)
                return cell
            }
        } else if collectionView == recentWallCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentWallUserCV", for: indexPath) as! RecentWallUserCV
            let dictData = arrayRecntWall[indexPath.row]
            if let paid = dictData["paid"] as? Int, paid == 1 {
                cell.decoUV.layer.borderColor = UIColor(named: "mainGreen")?.cgColor
            } else {
                cell.decoUV.layer.borderColor = UIColor(named: "AppColor")?.cgColor
            }
            if let profilePic = dictData["avatarblobid"] as? String{
                let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                cell.userIMG.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))                
            } else {
                cell.userIMG.image = UIImage(named: "Splaceicon")
            }
            if let verify = dictData["verify"] as? String {
                if verify == "1" {
                    cell.verifyUIMG.isHidden = false
                } else {
                    cell.verifyUIMG.isHidden = true
                }
            } else {
                cell.verifyUIMG.isHidden = true
            }
            cell.actionUB.tag = indexPath.row
            cell.actionUB.addTarget(self, action: #selector(didTapRecentWall), for: .touchUpInside)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedCell", for: indexPath) as! FeaturedCell
            if indexPath.row == self.arrayFeatured.count - 1 {
                cell.trailingSize.constant = 8.0
            } else {
                cell.trailingSize.constant = 0.0
            }
            let dictData = self.arrayFeatured[indexPath.row]
            if let verify = dictData["verify"] as? String {
                if verify == "1" {
                    cell.imgVerify.isHidden = false
                } else {
                    cell.imgVerify.isHidden = true
                }
            } else {
                cell.imgVerify.isHidden = true
            }
            if let Title = dictData["post_title"] as? String {
                cell.titleLB.text = Title
            }
            if let CategoriesName = dictData["total_message"] as? String {
                cell.messageLB.text = CategoriesName
            }
            if let CategoriesName = dictData["netvotes"] as? String {
                cell.seenCountLB.text = CategoriesName
            }
            if let CategoriesName = dictData["post_created"] as? String {
                cell.seentimeLB.text = CategoriesName
            }
            let Image = dictData["post_image"] as! String
            cell.imagePost.sd_setImage(with: URL(string: Image), placeholderImage: UIImage(named: "Place.png"))
            if let PostContent = dictData["webViewLink"] as? String {
                cell.webUV.loadRequest(URLRequest(url: URL(string: "\(PostContent)")!))
                cell.webUV.backgroundColor = .clear
                cell.webUV.isOpaque = false
            }
            if let profilePic = dictData["avatarblobid"] as? String{
                let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                cell.imgAvatar.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
            } else {
                cell.imgAvatar.image = UIImage(named: "Splaceicon")
            }
            cell.actionUB.tag = indexPath.row
            cell.actionUB.addTarget(self, action: #selector(onTapFeatureCell), for: .touchUpInside)
            return cell
        }
    }
    
    @objc func didTapRecentWall(sendr: UIButton) {
        let index: Int = sendr.tag
        let range: Int = arrayRecntWall.count
        let dictData = Array(arrayRecntWall[index..<range])
        let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier: "RecentWallVC") as! RecentWallVC
        vc.dictData = dictData
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @objc func onTapFeatureCell(sender: UIButton) {
        let dict = self.arrayFeatured[sender.tag]
        let PostId = dict["postid"] as! String
        let vc: PostDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier:"PostDetailsViewController")as! PostDetailsViewController
        vc.hidesBottomBarWhenPushed = true
        vc.PostID = PostId
        SharedManager.sharedInstance.PostId = PostId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func OnPost(_ sender : UIButton) {
        let dict = self.arrayTags[sender.tag]
        let NotasID = dict["tagid"] as! String
        let Title = dict["tags"] as! String
        let vc: PopularTagPostViewController = self.storyboard?.instantiateViewController(withIdentifier:"PopularTagPostViewController")as! PopularTagPostViewController
        vc.TagPostrId = NotasID
        vc.titleTags.title = Title
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func tapAction (_ sender : UIButton) {
        let dict = self.arrayCategories[sender.tag] as AnyObject
        let ID = dict["categoryid"] as! String
        let Title = dict["title"] as! String
        let vc: CategoriesDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "CategoriesDetailViewController")as! CategoriesDetailViewController
        vc.hidesBottomBarWhenPushed = true
        vc.CategoriesID = ID
        vc.titleCategories.title = Title
        vc.strTitle = Title
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collectionFeature {
            return CGSize(width: 250.0, height: 324.0)
        } else if collectionView == recentWallCV{
            return CGSize(width: 100.0, height: 100.0)
        } else {
            if indexPath.section == 1 {
                let width: CGFloat = self.collectionHome.frame.size.width
                let deviceHeight: CGFloat = UIScreen.main.bounds.height
                let height: CGFloat = deviceHeight > 700 ? 550.0 : 400.0
                return CGSize(width: width,height:height)
            }
            else {
                let width = self.collectionHome.frame.size.width/2
                let height = width * 0.8
                return CGSize(width: width - 0,height:height - 8)
            }
        }
    }
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == collectionFeature || collectionView == recentWallCV {
            return 0.0
        } else {
            return 8.0
        }
    }
    
    func collectionView (_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == collectionFeature || collectionView == recentWallCV{
            return UICollectionReusableView()
        } else {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HomeVCCollectionHeader", for: indexPath) as! HomeVCCollectionHeader
            if indexPath.section == 0 {
                headerView.category.text = "Tus categorías favoritas"
            } else {
                headerView.category.text = "Etiquetas más populares"
            }
            return headerView
        }
    }
    
    func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == collectionFeature || collectionView == recentWallCV{
            return CGSize(width: 0, height: 0)
        } else {
            return CGSize(width: collectionHome.frame.width, height: 80.0)
        }
    }
    
    func CallWebserviceCaregories() {
        let Para =
            ["userid":"\(Userid!)","offset":"100","limit":"0"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.getCategories)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        let Notification = myData["totalNotify"] as! NSInteger
                        var badgeText: String = ""
                        if Notification != 0 {
                            badgeText = Notification > 99 ? "+99" : "\(Notification)"
                        }
                        self.WellButton.setBadge(text: badgeText)
                        let application = UIApplication.shared
                        let center = UNUserNotificationCenter.current()
                        center.requestAuthorization(options: [.badge]) { (bool, error) in
                            print("success")
                        }
                        application.applicationIconBadgeNumber = Notification
                        application.registerForRemoteNotifications()
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["postinfo"]as? [[String:Any]], let Feature = arr["featured"] as? [[String: Any]]{
                                self.arrayFeatured = Feature
                                self.arrayCategories = Data
                                let Api:String = "\(WebURL.BaseUrl)\(WebURL.popularTagList)"
                                Alamofire.request(Api, method: .get,parameters:nil)
                                    .responseJSON { response in
                                        switch(response.result) {
                                        case .success(_):
                                            if response.result.value != nil{
                                                debugPrint(response.result)
                                                let myData = response.result.value as! [String :Any]
                                                if let arr = myData["response"] as? [String:Any]{
                                                    if let Data = arr["tags"]as? [[String:Any]]{
                                                        self.arrayTags = Data
                                                        var collectionHeight: CGFloat = 0.0
                                                        let cellHeight = self.collectionHome.frame.size.width/2 * 0.8
                                                        if self.arrayCategories.count % 2 == 0 {
                                                            collectionHeight += cellHeight * CGFloat(self.arrayCategories.count / 2)
                                                        } else {
                                                            collectionHeight += cellHeight * CGFloat(self.arrayCategories.count / 2 + 1)
                                                        }
                                                        if self.arrayTags.count % 3 == 0 {
                                                            collectionHeight += CGFloat(40 * self.arrayTags.count / 3)
                                                        } else {
                                                            collectionHeight += CGFloat(40 * (self.arrayTags.count / 3 + 1))
                                                        }
                                                        self.collectionHomeHeight.constant = CGFloat(collectionHeight + 180) - self.parentScrollVIew.frame.height
                                                        self.collectionHome.reloadData()
                                                        self.collectionFeature.reloadData()
                                                        print(isVerifiedUser)
                                                        self.verifiedMarker.isHidden = isVerifiedUser ? false : true
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
                    }
                    break
                case .failure(_):
                    print(response.result.error as Any)
                    break
                }
            }
    }
    
    func CallWebserviceSearch(){
        let Para =
            ["search":"\(SearchMembers.text!)","offset":"100","limit":"0","type":"\(SearchType)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.homeSearchNew)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["search"]as? [[String:Any]]{
                                self.arraySearchProduct = Data
                                self.tableviewSearch.reloadData()
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
    //Userinformation
    func CallWebserviceGetProfile(){
        objActivity.startActivityIndicator()
        let Para =
            ["userid":"\(Userid!)","login_userid":"\(Userid!)"
            ] as [String : Any]
        let myService:String = "\(WebURL.BaseUrl)\(WebURL.getProfile)"
        objActivity.startActivityIndicator()
        Alamofire.request(myService, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [[String:Any]]{
                            self.arrayProfile = arr
                            SharedManager.sharedInstance.arrayEditProfie = arr
                            let data =  self.arrayProfile[0]
                            if let Username = data["username"]as? String{
                                self.labelUserName.text = "Hola \(Username)"
                            }
                            if let profilePic = data["avatarblobid"] as? String {
                                let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                                self.imgProfile.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
                            } else {
                                self.imgProfile.image = UIImage(named: "Splaceicon")
                            }
                        }
                        objActivity.stopActivity()
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
    
    func CallWebServiceRecentWalls() {
        arrayRecntWall.removeAll()
        let Para =
            ["userid":"\(Userid!)","login_userid":"\(Userid!)"
            ] as [String : Any]
        let myService:String = "\(WebURL.BaseUrl)\(WebURL.GET_RECENT_WALL_USER)"
        Alamofire.request(myService, method: .post,parameters:Para)
            .responseJSON { response in
                self.parentScrollVIew.spr_endRefreshing()
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let code = myData["code"] as? String {
                            if code != "200" {
                                self.recentWallSV.isHidden = true
                                self.recentWallCV.isHidden = true
                                self.recentWallLB.isHidden = true
                                self.recentWallTopSpace.constant = 0.0
                            } else {
                                if let arr = myData["response"] as? [String:Any] {
                                    let wallFollowPost = arr["wallFollowPost"] as! [[String: Any]]
                                    let paidWall = arr["paidWall"] as! [[String: Any]]
                                    if wallFollowPost.isEmpty && paidWall.isEmpty {
                                        self.recentWallSV.isHidden = true
                                        self.recentWallCV.isHidden = true
                                        self.recentWallLB.isHidden = true
                                        self.recentWallTopSpace.constant = 0.0
                                    } else {
                                        self.recentWallTopSpace.constant = 20.0
                                        self.recentWallSV.isHidden = false
                                        self.recentWallCV.isHidden = false
                                        self.recentWallLB.isHidden = false
                                    }
                                    for item in paidWall {
                                        self.arrayRecntWall.append(item)
                                    }
                                    for item in wallFollowPost {
                                        self.arrayRecntWall.append(item)
                                    }
                                    DispatchQueue.main.async {
                                        self.recentWallCV.reloadData()
                                    }
                                }
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
//MARK:- Extension TableView Delegate/DataSource Methods
extension HomeVC: UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if issearching {
            return arraySearchProduct.count
        }
        return Data.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dictData = self.arraySearchProduct[indexPath.row]
        if issearching{
            if SearchType == "post" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PostSearchCell") as! PostSearchCell
                cell.actionUB.tag = indexPath.item
                cell.actionUB.addTarget(self, action: #selector(self.SearchAction(_:)), for: UIControl.Event.touchUpInside)
                if let name = dictData["handle"] as? String {
                    cell.nameLB.text = name
                }
                if  let profilePic = dictData["avatar"] as? String{
                    let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                    cell.userUIMG.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
                }  else {
                    cell.userUIMG.image = UIImage(named: "Splaceicon")
                }
                if let rating = dictData["avgRating"] as? Double {
                    cell.ratingUV.rating = rating
                }
                if let Title = dictData["title"] as? String{
                    cell.titleLB.text = Title
                }
                return cell
            } else if SearchType == "member" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MemebrSearchCell") as! MemebrSearchCell
                cell.actionUB.tag = indexPath.item
                cell.actionUB.addTarget(self, action: #selector(self.SearchAction(_:)), for: UIControl.Event.touchUpInside)
                if  let profilePic = dictData["avatarblobid"] as? String{
                    let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                    cell.userUIMG.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
                }  else {
                    cell.userUIMG.image = UIImage(named: "Splaceicon")
                }
                if let verify = dictData["userverify"] as? String {
                    if verify == "0" {
                        cell.verifyUIMG.isHidden = true
                    } else {
                        cell.verifyUIMG.isHidden = false
                    }
                }
                if let Title = dictData["title"] as? String{
                    cell.nameLB.text = Title
                }
                if let following = dictData["totalFollowing"] as? String{
                    cell.siguiendoLB.text = following + " siguiendo"
                }
                if let followers = dictData["totalFollowers"] as? String{
                    cell.seguidoLB.text = followers + " seguidores"
                }
                if let postCnt = dictData["totalPost"] as? String{
                    cell.postCountLB.text = postCnt + " Posts"
                }
                return cell
            } else {
                let idetifier = "SearchViewCell"
                let cell:SearchViewCell = tableviewSearch.dequeueReusableCell(withIdentifier: idetifier)as! SearchViewCell
                
                if ImageStatus == "1"{
                    cell.WtImage.constant = 30
                } else {
                    cell.WtImage.constant = 0
                }
                if let profilePic = dictData["avatarblobid"] as? String{
                    let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                    cell.imageUsers.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
                } else {
                    cell.imageUsers.image = UIImage(named: "Splaceicon")
                }
                if let Title = dictData["title"] as? String {
                    cell.labelSearchTitle.text = Title
                }
                cell.buttonTab.tag = indexPath.item
                cell.buttonTab.addTarget(self, action: #selector(self.SearchAction(_:)), for: UIControl.Event.touchUpInside)
                return cell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    @objc func SearchAction(_ sender : UIButton) {
        let dictData = self.arraySearchProduct[sender.tag]
        let Post = dictData["id"] as!String
        let Title = dictData["title"] as!String
        if SearchType == "post"{
            let CatId = dictData["categoryid"] as!String
            SharedManager.sharedInstance.PostId = Post
            let vc: PostDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailsViewController")as! PostDetailsViewController
            vc.hidesBottomBarWhenPushed = true
            vc.PostID = Post
            vc.CatID = CatId
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if SearchType == "member"{
            self.defaults.set(Post, forKey: "OtherUserID")
            let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
            SharedManager.sharedInstance.otherProfile = "1"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if SearchType == "tag"{
            let vc: PopularTagPostViewController = self.storyboard?.instantiateViewController(withIdentifier: "PopularTagPostViewController")as! PopularTagPostViewController
            vc.TagPostrId = Post
            vc.titleTags.title = Title
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        SearchMembers.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchBar.text == nil || searchBar.text == ""{
            issearching = false
            viewSearchType.isHidden = true
            self.tableviewSearch.isHidden = true
            tableviewSearch.reloadData()
        } else {
            issearching = true
            viewSearchType.isHidden = false
            self.tableviewSearch.isHidden = false
            CallWebserviceSearch()
        }
    }
    
    @IBAction func didTapButton() {
        showAlert()
    }
    
    func showAlert() {
        let alert = UIAlertController (title: "Estadísticas", message: "La función estadísticas estará disponibe en las próximas versiones de la app. Puedes acceder a esta información entrando en www.adimvi.com", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: {action in
            print ("tapped Okay")
            
        }))
        present (alert, animated: true)
    }
}
class HomeCVCell: UICollectionViewCell {
    @IBOutlet weak var buttonTap: UIButton!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imgCategories: UIImageView!
}

class RecentWallUserCV: UICollectionViewCell {
    @IBOutlet weak var decoUV: UIView!
    @IBOutlet weak var userIMG: UIImageView!
    @IBOutlet weak var actionUB: UIButton!
    @IBOutlet weak var verifyUIMG: UIImageView!
}

func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
}

class HomeVCCollectionHeader: UICollectionReusableView {
    @IBOutlet weak var category: UILabel!
}

extension String {
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.width)
    }
}

extension HomeVC: PopularTagDeleagte {
    func didTapTagDelegate(tag: [String: Any]) {
        let NotasID = tag["tagid"] as! String
        let Title = tag["tags"] as! String
        let vc: PopularTagPostViewController = self.storyboard?.instantiateViewController(withIdentifier:"PopularTagPostViewController")as! PopularTagPostViewController
        vc.TagPostrId = NotasID
        vc.titleTags.title = Title
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

class FeaturedCell: UICollectionViewCell {
    @IBOutlet weak var imagePost: UIImageView!
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var webUV: UIWebView!
    @IBOutlet weak var seentimeLB: UILabel!
    @IBOutlet weak var seenCountLB: UILabel!
    @IBOutlet weak var messageLB: UILabel!
    @IBOutlet weak var actionUB: UIButton!
    @IBOutlet weak var trailingSize: NSLayoutConstraint!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var imgVerify: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

@IBDesignable
public class Gradient: UIView {
    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}
    
    override public class var layerClass: AnyClass { CAGradientLayer.self }
    
    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
    
    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }
    
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updatePoints()
        updateLocations()
        updateColors()
    }
    
}

class MemebrSearchCell: UITableViewCell {
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var userUIMG: UIImageView!
    @IBOutlet weak var verifyUIMG: UIImageView!
    @IBOutlet weak var seguidoLB: UILabel!
    @IBOutlet weak var postCountLB: UILabel!
    @IBOutlet weak var siguiendoLB: UILabel!
    @IBOutlet weak var actionUB: UIButton!
    
}

class PostSearchCell: UITableViewCell {
    @IBOutlet weak var ratingUV: FloatRatingView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var userUIMG: UIImageView!
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var actionUB: UIButton!
}

