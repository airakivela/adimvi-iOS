
//  SalesVC.swift
//  adimvi
//  Created by javed carear  on 17/06/19.
//  Copyright © 2019 webdesky.com. All rights reserved.

import UIKit
import Alamofire
class SalesVC: BaseViewController {
    
    @IBOutlet weak var txtNoData: UILabel!
    @IBOutlet weak var tableSales: UITableView!
    var Userid:String!
    var arraySales =  [[String: Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        Userid = UserDefaults.standard.string(forKey: "ID")
        CallWebserviceGetSeles()
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.darkGray]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isClickedSaleNotification = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
}


//MARK:- Extension TableView Delegate/DataSource Methods
extension SalesVC : UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arraySales.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idetifier = "SalesViewCell"
        let cell: SalesViewCell = tableSales.dequeueReusableCell(withIdentifier: idetifier)as!  SalesViewCell
        let dictData = self.arraySales[indexPath.row] 
        
        let price = dictData["usd"] as! String
        cell.lblPrice.text = price
        
        let postId = dictData["postid"] as! String
        cell.lblPostID.text = postId
        
        let createDate = dictData["created"] as! String
        cell.lblCreatedDate.text = createDate
        
        let user = dictData["username"] as! String
        cell.lblUserName.text = user
        
        return cell
    }
    func CallWebserviceGetSeles(){
        let Para =
            ["userid":"\(Userid!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.buyPostList)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method:.post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["buyPost"]as? [[String:Any]]{
                                self.arraySales = Data
                                self.tableSales.reloadData()
                                self.txtNoData.isHidden = true
                                self.tableSales.isHidden = false
                            } else {
                                self.txtNoData.isHidden = false
                                self.tableSales.isHidden = true
                            }
                        }
                        
                        objActivity.stopActivity()
                        DispatchQueue.main.async {
                            
                        }
                    }
                    objActivity.stopActivity()
                    break
                case .failure(_):
                    self.txtNoData.isHidden = false
                    self.tableSales.isHidden = true
                    objActivity.stopActivity()
                    print(response.result.error as Any)
                    break
                }
            }
    }
    
}




