
//  WebViewViewController.swift
//  adimvi
//  Created by javed carear  on 04/10/19.
//  Copyright © 2019 webdesky.com. All rights reserved.


import UIKit

class WebViewViewController: UIViewController,UIWebViewDelegate {
    @IBOutlet weak var labelTitleText: UILabel!
    @IBOutlet weak var webviewOpenUrl: UIWebView!
     var UrlLink:String?
     var Title:String!
     override func viewDidLoad() {
        super.viewDidLoad()
     labelTitleText.text! = "\(Title!)"
        if(UrlLink != ""){
            webviewOpenUrl.loadRequest(URLRequest(url: URL(string: "\(UrlLink!)")!))
        }
        else{
            webviewOpenUrl.loadRequest(URLRequest(url: URL(string: "https://www.adimvi.com")!))
        }
    
   
    }
    
    @IBAction func Onback(_ sender: Any) {
     self.dismiss(animated: true, completion: nil)
    }
    
    

}
