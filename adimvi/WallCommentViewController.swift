
//  WallCommentViewController.swift
//  adimvi
//  Created by javed carear  on 31/12/19.
//  Copyright © 2019 webdesky.com. All rights reserved.

import UIKit
import Alamofire
class WallCommentViewController:UIViewController {
 @IBOutlet weak var textviewComments: UITextView!
    var touserid:String!
    var LoginId:String!
    var MessageId:String!
    var EditType:String!
    var ProfileType:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        ProfileType = SharedManager.sharedInstance.otherProfile
               if  ProfileType == "1" {
                   touserid = UserDefaults.standard.string(forKey: "OtherUserID")
               }else{
                   touserid = UserDefaults.standard.string(forKey: "ID")
                }
               LoginId = UserDefaults.standard.string(forKey: "ID")
        
    }
    
    @IBAction func OnAddComments(_ sender: Any) {
        let Comments = textviewComments.text
        if (Comments!.isEmpty) {
            self.showAlert(strMessage: "Tu comentario ha sido añadido.")
            return
        }
        webserviceAddComment()
    
    }
    @IBAction func OnSeeComments(_ sender: Any) {
           let vc:WallViewController = self.storyboard?.instantiateViewController(withIdentifier: "WallViewController") as! WallViewController
           self.navigationController?.pushViewController(vc, animated: true)
           
       }
       
       
      // add Comments
       func webserviceAddComment(){
           let Para =
               ["fromuserid":"\(LoginId!)","touserid":"\(touserid!)",
                   "wall_message":"\(textviewComments.text!)"] as [String : Any]
           let Api:String = "\(WebURL.BaseUrl)\(WebURL.addNewWall)"
           
           objActivity.startActivityIndicator()
           Alamofire.request(Api, method: .post,parameters:Para)
               .responseJSON { response in
                   switch(response.result) {
                   case .success(_):
                       if response.result.value != nil{
                           debugPrint(response.result)
                           let myData = response.result.value as! [String :Any]
                        if (myData["response"] as? [String:Any]) != nil {
                               
                           }
                           self.textviewComments.text = ""
                             self.showAlert(strMessage: "Tu post ha sido añadido al muro")
                          
                           
                           objActivity.stopActivity()
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
       
       func showAlert(strMessage:String) ->() {
           let actionSheetController: UIAlertController = UIAlertController(title: "Mensaje", message: strMessage, preferredStyle: .alert)
           let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) { action -> Void in
           }
           actionSheetController.addAction(cancelAction)
           self.present(actionSheetController, animated: true, completion: nil)
       }
  

}
