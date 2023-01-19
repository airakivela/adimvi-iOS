//
//  PopularTagViewController.swift
//  adimvi
//
//  Created by Mac on 18/04/20.
//  Copyright © 2020 webdesky.com. All rights reserved.


import UIKit

class PopularTagViewController: UIViewController {
    @IBOutlet weak var tablePopulerTag: UITableView!
       var Userid:String!
       var arrayTagList =  [[String: Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
   
}
//MARK:- Extension TableView Delegate/DataSource Methods
extension PopularTagViewController : UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayTagList.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idetifier = "PopulerTagTableViewCell"
        let cell: PopulerTagTableViewCell = tablePopulerTag.dequeueReusableCell(withIdentifier: idetifier)as!  PopulerTagTableViewCell
        _ = self.arrayTagList[indexPath.row]
        return cell
    }
}
