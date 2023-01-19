
//  MostPopularTagViewController.swift
//  adimvi
//  Created by javed carear  on 20/05/1942 Saka.
//  Copyright © 1942 webdesky.com. All rights reserved.

import UIKit
import Alamofire
class MostPopularTagViewController: UIViewController {
    @IBOutlet weak var CollectionviewPopularTag: UICollectionView!
    var arrayTags =  [[String: Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CallWebserviceGetTags()
    }
    
    
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func CallWebserviceGetTags(){
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.popularTagList)"
        objActivity.startActivityIndicator()
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
                                
                                self.CollectionviewPopularTag.reloadData()
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
    
}
// Mark:- Collection view data source and layout menthods
extension MostPopularTagViewController:UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.CollectionviewPopularTag.frame.size.width / 4
        let height = self.CollectionviewPopularTag.frame.size.height
        return CGSize(width: width - 0, height: height - 518)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularTagCollectionViewCell", for: indexPath) as! popularTagCollectionViewCell
        
        let dictData = self.arrayTags[indexPath.item]
        _ = dictData["tags"] as! String
        return cell
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
}
