//
//  PopUpDeleteWallVC.swift
//  adimvi
//
//  Created by javed carear  on 03/06/1942 Saka.
//  Copyright © 1942 webdesky.com. All rights reserved.


import UIKit
import Alamofire
protocol BackButtonActionDelegate {
func pressFinished()
}
class PopUpDeleteWallVC: UIViewController {
var delegate: BackButtonActionDelegate?
 var MessageId:String!
    override func viewDidLoad() {
        super.viewDidLoad()
 
    }
    
    @IBAction func OnDelete(_ sender: Any) {
     delegate?.pressFinished()
     
    }
    
    @IBAction func OnCencel(_ sender: Any) {     
    }
    
      

}
