
//  ContactViewController.swift
//  adimvi
//  Created by javed carear  on 04/10/19.
//  Copyright © 2019 webdesky.com. All rights reserved.


import UIKit
import Alamofire

class ContactViewController: UIViewController {
    @IBOutlet weak var textviewWriteComments: UITextView!
    @IBOutlet weak var textfieldName: UITextField!
    @IBOutlet weak var textfieldEmail: UITextField!
    var UserID:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        UserID = UserDefaults.standard.string(forKey: "ID")
    }
    
    @IBAction func OnBack(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func OnSend(_ sender: Any) {
        let userName = textfieldName.text
        let Email = textfieldEmail.text
         let Comments = textviewWriteComments.text
        if (userName!.isEmpty) {
            self.showAlert(strMessage:
            "Por favor, introduce tu nombre")
            return
        }
        if (Email!.isEmpty) {
            self.showAlert(strMessage: "Por favor, introduce tu correo electrónico")
            return
        }
        if (Comments!.isEmpty) {
            self.showAlert(strMessage: "Por favor, escribe tu comentario")
            return
        }
        CallWebserviceSendFeedback()
    }
    func CallWebserviceSendFeedback(){
        let Para =
            ["userid":"\(UserID!)","username":"\(textfieldName.text!)","comment":"\(textviewWriteComments.text!)","email":"\(textviewWriteComments.text!)"] as [String : Any]
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.contact)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["data"] as? [String:Any]{
                        }
                        let massage = myData["message"] as! String
                        self.showAlert(strMessage: "\(massage)")
                        
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
