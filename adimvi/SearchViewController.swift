//
//  SearchViewController.swift
//  adimvi
//
//  Created by javed carear  on 30/09/19.
//  Copyright © 2019 webdesky.com. All rights reserved.
//

import UIKit
import Alamofire
class SearchViewController: UIViewController {
 @IBOutlet weak var tableviewSearch: UITableView!
    @IBOutlet weak var SearchMembers: UISearchBar!
    var filterData = [String]()
    var issearching = false
    var Data = [String]()
    var arraySearchProduct =  [[String: Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableviewSearch.estimatedRowHeight = 44
        
        SearchMembers.delegate = self
        SearchMembers.delegate = self
        SearchMembers.returnKeyType = UIReturnKeyType.done
        
    }
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    func CallWebserviceSearch(){
        let Para =
            ["search":"\(SearchMembers.text!)","offset":"100","limit":"0"] as [String : Any]
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.homeSearch)"
        
        //objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["search_post"]as? [[String:Any]]{
                                self.arraySearchProduct = Data
                                self.tableviewSearch.reloadData()
                                
                            }
                        }
                        
                        
                       // objActivity.stopActivity()
                        DispatchQueue.main.async {
                            
                        }
                    }
                   // objActivity.stopActivity()
                    break
                case .failure(_):
                    //objActivity.stopActivity()
                    print(response.result.error as Any)
                    break
                }
        }
    }
    

}
//MARK:- Extension TableView Delegate/DataSource Methods
extension SearchViewController: UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idetifier = "SearchViewCell"
        let cell:SearchViewCell = tableviewSearch.dequeueReusableCell(withIdentifier: idetifier)as! SearchViewCell
        if issearching{
            let dictData = self.arraySearchProduct[indexPath.row]
            if let Title = dictData["title"] as? String{
            cell.labelSearchTitle.text = Title
                cell.buttonTab.tag = indexPath.item
                cell.buttonTab.addTarget(self, action: #selector(self.tapAction(_:)), for: UIControl.Event.touchUpInside)
                
                
                
            }
                
            
        }else{
            
        }
    return cell
}
    @objc func tapAction(_ sender : UIButton) {
        let dictData = self.arraySearchProduct[sender.tag]
        let Post = dictData["postid"] as!String
        let CatId = dictData["categoryid"] as!String
        SharedManager.sharedInstance.PostId = Post
        
        let vc: PostDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailsViewController")as! PostDetailsViewController
        vc.hidesBottomBarWhenPushed = true
        vc.PostID = Post
        vc.CatID = CatId
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchBar.text == nil || searchBar.text == ""{
            issearching = false
            view.endEditing(true)
            tableviewSearch.reloadData()
        }else{
            issearching = true
            let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchBar.text!)
            filterData = (self.arraySearchProduct as NSArray).filtered(using: searchPredicate) as! [String]
            CallWebserviceSearch()
            tableviewSearch.reloadData()
        }
    }
    
    
}
