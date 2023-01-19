//
//  TagListViewController.swift
//  adimvi
//
//  Created by javed carear  on 28/09/19.
//  Copyright © 2019 webdesky.com. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
class TagListViewController: UIViewController,UICollectionViewDelegateFlowLayout {
@IBOutlet weak var collectionviewTagList: UICollectionView!
     var arraytagList =  [[String: Any]]()
    var buttonType:String!
     
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTagList), name: Notification.Name("reloadTag"), object: nil)
        
         CallWebserviceTagList()
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.darkGray]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    @objc func reloadTagList(notification: NSNotification) {
        CallWebserviceTagList()
    }
    
}
// Mark:- Collection view data source and layout menthods
extension TagListViewController:UICollectionViewDataSource,UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        let width = self.collectionviewTagList.frame.size.width / 2
//        let height = self.collectionviewTagList.frame.size.height
//        return CGSize(width: width - 0, height: height - 50)
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arraytagList.count
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let padding: CGFloat =  2
//        let collectionViewSize = collectionView.frame.size.width - padding
//        return CGSize(width: collectionViewSize/2,height:25)
//    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionviewTagList.dequeueReusableCell(withReuseIdentifier: "TagListViewCell", for: indexPath) as! TagListViewCell

        let dictData = self.arraytagList[indexPath.row]

        if let Title = dictData["tags"] as? String{
            cell.labelTagName.text = Title
        }
         cell.buttonTap.tag = indexPath.row
         cell.buttonTap.addTarget(self, action: #selector(self.tapAction(_:)), for: UIControl.Event.touchUpInside)
    
        
        
        return cell
 }
    
    @objc func tapAction(_ sender : UIButton) {
       
        let dict = self.arraytagList[sender.tag] as AnyObject
        let tag = dict["tagid"] as! String
        let tagName = dict["tags"] as! String
        buttonType = "1"
        let vc:PopularTagPostViewController = self.storyboard?.instantiateViewController(withIdentifier: "PopularTagPostViewController") as!PopularTagPostViewController
        vc.titleTags.title = tagName
        vc.TagPostrId = tag
        self.navigationController?.pushViewController(vc, animated: true)
  
    }
    
    func CallWebserviceTagList(){
        let Para =
            ["postid":"\(SharedManager.sharedInstance.PostId!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.postByTagList)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["tags"]as? [[String:Any]]{
                                self.arraytagList = Data
                               print(self.arraytagList)
                                self.collectionviewTagList.reloadData()
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
