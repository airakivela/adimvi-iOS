
//  WebviewTabController.swift
//  adimvi
//  Created by javed carear  on 15/01/20.
//  Copyright © 2020 webdesky.com. All rights reserved.

import UIKit
class WebviewTabController: UIViewController {
    @IBOutlet weak var webview: UIWebView!
   
         var UrlLink:String?
         var Title:String!
         override func viewDidLoad() {
            super.viewDidLoad()
            if(UrlLink != ""){
                webview.loadRequest(URLRequest(url: URL(string: "\(UrlLink!)")!))
            }
            else{
                webview.loadRequest(URLRequest(url: URL(string: "https://www.adimvi.com")!))
            }
        
        }
        
        @IBAction func Onback(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
        }
        
        

    }
