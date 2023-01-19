//
//  MemberSearchViewController.swift
//  adimvi
//  Created by javed carear  on 01/10/19.
//  Copyright © 2019 webdesky.com. All rights reserved.


import UIKit
import Alamofire
import SDWebImage
class MemberSearchViewController: UIViewController {
    @IBOutlet weak var tableviewSearch: UITableView!
    @IBOutlet weak var SearchMembers: UISearchBar!
     let defaults = UserDefaults.standard
    var filterData = [String]()
    var issearching = false
    var Data = [String]()
    
    var arraySearchProduct =  [[String: Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.darkGray]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        SearchMembers.delegate = self
        SearchMembers.delegate = self
        SearchMembers.returnKeyType = UIReturnKeyType.done
        
    }
    
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
 
    func CallWebserviceSearch(){
        let Para =
            ["search":"\(SearchMembers.text!)","offset":"500","limit":"0"] as [String : Any]
       
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.homeSearch)"
        
       // objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["search_members"]as? [[String:Any]]{
                                self.arraySearchProduct = Data
                                self.tableviewSearch.reloadData()
                                
                            }
                        }
                        
                        
                        //objActivity.stopActivity()
                        DispatchQueue.main.async {
                            
                        }
                    }
                    //objActivity.stopActivity()
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
extension MemberSearchViewController: UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if issearching {
            return arraySearchProduct.count
        }
        return Data.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idetifier = "SearchMembersViewCell"
        let cell:SearchMembersViewCell = tableviewSearch.dequeueReusableCell(withIdentifier: idetifier)as! SearchMembersViewCell
        if issearching{
            let dictData = self.arraySearchProduct[indexPath.row]
            if let Title = dictData["username"] as? String{
                cell.labelUsername.text = Title
            }
            if  let profilePic = dictData["avatarblobid"] as? String{
                let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
                cell.ProfilePic.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
            }
            
            
            
                cell.buttonTab.tag = indexPath.item
                cell.buttonTab.addTarget(self, action: #selector(self.tapAction(_:)), for: UIControl.Event.touchUpInside)
                
                
                
            
            
            
        }else{
            
        }
        return cell
    }
    @objc func tapAction(_ sender : UIButton) {
        let dictData = self.arraySearchProduct[sender.tag]
        let Id = dictData["userid"] as!String
     self.defaults.set(Id, forKey: "OtherUserID")
       
        
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
  
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchBar.text == nil || searchBar.text == ""{
            issearching = false
            view.endEditing(true)
            tableviewSearch.reloadData()
        }else{
            issearching = true
            let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@",searchBar.text!)
            filterData = (self.arraySearchProduct as NSArray).filtered(using: searchPredicate) as! [String]
            CallWebserviceSearch()
            tableviewSearch.reloadData()
        }
    }
    
    
}
