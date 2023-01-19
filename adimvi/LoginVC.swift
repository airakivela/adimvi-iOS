
//  LoginVC.swift
//  adimvi
//  Created by javed carear  on 15/06/19.
//  Copyright © 2019 webdesky.com. All rights reserved.

import UIKit
import Alamofire
class LoginVC: UIViewController {
    @IBOutlet weak var lblUserLine:UILabel!
    @IBOutlet weak var txtUserName:UITextField!
    @IBOutlet weak var txtPassword:UITextField!
    @IBOutlet weak var imgIcon:UIImageView!
    @IBOutlet weak var lblPassLine:UILabel!
    var Token:String!
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        // imgIcon.setImageColor(color:#colorLiteral(red: 1, green: 0.3725490196, blue: 0.06666666667, alpha: 1))
        Token  = SharedManager.sharedInstance.DeviceToken
    }
    
    
    @IBAction func actionTouchUpInsideEnter(_ sender: Any) {
        let userName = txtUserName.text
        let password = txtPassword.text
        if (userName!.isEmpty) {
            self.showAlert(strMessage: "Por favor, escribe tu nombre")
            return
        }
        if (password!.isEmpty) {
            self.showAlert(strMessage: "Por favor, escribe tu contraseña")
            return
        }
        CallWebserviceUserLogin()
        
    }
    @IBAction func OnRegistration(_ sender: Any) {
        let vc:RegistrationVc = self.storyboard?.instantiateViewController(withIdentifier: "RegistrationVc") as! RegistrationVc
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    
    func CallWebserviceUserLogin() {
        objActivity.startActivityIndicator()
        let params = ["handle":"\(txtUserName.text!)","password":"\(txtPassword.text!)","fcm_id":"\(Token!)"] as Dictionary<String, String>
        var request = URLRequest(url: URL(string:"\(WebURL.BaseUrl)\(WebURL.userlogin)")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                let ResponceCode = json["code"] as! String
                
                if ResponceCode == "200" {
                    if let responce = json["response"] as? NSDictionary {
                        objActivity.stopActivity()
                        if let user = responce.object(forKey: "user") as? NSDictionary{
                            print(user)
                            let userId = user["userid"] as! String
                            self.defaults.set(userId, forKey: "ID")
                            let Emailid = user["email"] as! String
                            self.defaults.set(Emailid, forKey: "Email")
                            let dictUserInfo = user
                            SharedManager.sharedInstance.setUserInfo(dictObject: dictUserInfo as! Dictionary<String, Any>)
                            DispatchQueue.main.async {
                                let tc = Storyboards.tabBarStoryboard.instantiateViewController(withIdentifier: "TabViewController") as! TabViewController
                                tc.modalPresentationStyle = .fullScreen
                                self.present(tc, animated: true, completion: nil)
                            }
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.showAlert(strMessage: "El nombre de usuario o la contraseña son incorrectos.")
                    }
                }
            } catch {
                objActivity.stopActivity()
                print("error")
            }
        })
        objActivity.stopActivity()
        task.resume()
    }
    
    @IBAction func OnForgetPassword(_ sender: Any) {
        let vc:WebViewViewController = self.storyboard?.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        vc.UrlLink  = "https://www.adimvi.com/?qa=forgot"
        vc.Title = "Recuperar contraseña"
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func OnInformation(_ sender: Any) {
        let vc:WebViewViewController = self.storyboard?.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        vc.UrlLink  = "https://www.adimvi.com/?qa=Informaci%C3%B3n"
        vc.Title = "Información"
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func OnTermAndprivacy(_ sender: Any) {
        let vc:WebViewViewController = self.storyboard?.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        vc.UrlLink  = "https://www.adimvi.com/?qa=T%C3%A9rminos-y-privacidad"
        vc.Title = "Términos y política de privacidad"
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func OnContact(_ sender: Any) {
        let vc:ContactViewController = self.storyboard?.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func showAlert(strMessage:String) ->() {
        let actionSheetController: UIAlertController = UIAlertController(title: "Mensaje", message: strMessage, preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
}

extension LoginVC:UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}
