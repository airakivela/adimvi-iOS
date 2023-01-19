//
//  CheckoutVC.swift
//  adimvi
//
//  Created by javed carear  on 20/06/19.
//  Copyright © 2019 webdesky.com. All rights reserved.
//

import UIKit

class CheckoutListVC: BaseViewController {

    @IBOutlet weak var tableCheckout: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableCheckout.tableFooterView = UIView(frame: .zero)
       // self.navigationItem.titleView = self.setNavigationTitleView()
    }
    


}

//Mark:- UITableView delegate Methods
extension CheckoutListVC:UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}
//Mark:- UItableView DataSource Methods
extension CheckoutListVC:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckoutListCell") as! CheckoutListCell
       
        
        return cell
        
    }
    
}

class CheckoutListCell: UITableViewCell {
 
    
}
