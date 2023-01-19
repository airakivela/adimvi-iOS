
//  PopUpDeletePostViewController.swift
//  adimvi
//  Created by javed carear  on 25/01/20.
//  Copyright © 2020 webdesky.com. All rights reserved.


import UIKit
import Alamofire

class PopUpDeletePostViewController: UIViewController {
    
    
    var Postid:String!
    override func viewDidLoad() {
        super.viewDidLoad()
       print(Postid!)
    }
    
    @IBAction func OnCanel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func OnDelete(_ sender: Any) {
    CallWebserviceDeletePost()
    }
 
 func CallWebserviceDeletePost(){
        let Para =
            ["postid":"\(Postid!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.postDelete)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                     
                        self.dismiss(animated: true, completion: nil)
                    
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
