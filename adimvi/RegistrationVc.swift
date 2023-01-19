
//  RegistrationVc.swift
//  adimvi
//  Created by javed carear  on 11/07/19.
//  Copyright © 2019 webdesky.com. All rights reserved.

import UIKit
import Alamofire
class RegistrationVc: UIViewController {
    @IBOutlet weak var buttonUncheck: UIButton!
    @IBOutlet weak var txtName: FloatLabelTextField!
    @IBOutlet weak var txtEmail: FloatLabelTextField!
    @IBOutlet weak var txtPassword: FloatLabelTextField!
    
    @IBOutlet weak var txtConfirmPassword: FloatLabelTextField!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var buttonCheck: UIButton!
    let defaults = UserDefaults.standard
    var Token:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        // imgIcon.setImageColor(color:#colorLiteral(red: 1, green: 0.3725490196, blue: 0.06666666667, alpha: 1))
        Token  = SharedManager.sharedInstance.DeviceToken
        txtName.delegate = self
    }
    
    @IBAction func onRegistration(_ sender: Any) {
        let userName = txtName.text
        let password = txtPassword.text
        let Email = txtEmail.text
        let ConPassword = txtConfirmPassword.text
        if (userName!.isEmpty) {
            self.showAlert(strMessage: "Por favor, escribe tu nombre de usuario")
            return
        }
        if (password!.isEmpty) {
            self.showAlert(strMessage: "Por favor, escribe tu contraseña")
            return
        }
        if (Email!.isEmpty) {
            self.showAlert(strMessage: "Por favor, introduce tu correo electrónico")
            return
        }
        if (ConPassword!.isEmpty) {
            self.showAlert(strMessage: "por favor, repite tu contraseña")
            return
        }
        if password! != ConPassword! {
            self.showAlert(strMessage: "Las contraseñas no coinciden")
            return
        }
        CallUserRegister()
    }
    
    @IBAction func OnBackLogin(_ sender: Any) {
        let vc:LoginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func OnNotify(_ sender: UIButton) {
        if sender.tag == 1{
            buttonCheck.isHidden = false
            buttonUncheck.isHidden = true
        }
        if sender.tag == 2{
            buttonCheck.isHidden = true
            buttonUncheck.isHidden = false
        }
    }
    
    func showAlert(strMessage:String) ->() {
        let actionSheetController: UIAlertController = UIAlertController(title: "Mensaje", message: strMessage, preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func CallUserRegister() {
        objActivity.startActivityIndicator()
        let params = ["handle":"\(txtName.text!)",
                      "email":"\(txtEmail.text!)",
                      "passcheck":"\(txtPassword.text!)",
                      "createdip":"1111111","fcm_id":"\(Token!)"]
            as Dictionary<String, String>
        
        var request = URLRequest(url: URL(string:"\(WebURL.BaseUrl)\(WebURL.userRegister)")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                debugPrint(json)
                let ResponceCode = json["code"] as! String
                if ResponceCode == "200"{
                    if let responce = json["response"] as? NSDictionary {
                        DispatchQueue.main.async {
                            objActivity.stopActivity()
                            if let user = responce.object(forKey:"user") as? NSDictionary{
                                let userId = user["userid"] as! String
                                self.defaults.set(userId, forKey:"ID")
                                let dictUserInfo = user
                                SharedManager.sharedInstance.setUserInfo(dictObject: dictUserInfo as! Dictionary<String, Any>)
                                
                                let tc = Storyboards.tabBarStoryboard.instantiateViewController(withIdentifier: "TabViewController") as! TabViewController
                                tc.modalPresentationStyle = .fullScreen
                                self.present(tc, animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                    self.showAlert(strMessage: "Este nombre de usuario ya está registrado.")
                    objActivity.stopActivity()
                }
                
                
            } catch {
                objActivity.stopActivity()
                print("error")
            }
        })
        task.resume()
    }
    @IBAction func OnContact(_ sender: Any) {
        let vc:ContactViewController = self.storyboard?.instantiateViewController(withIdentifier: "ContactViewController") as! ContactViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func OnTermsAndConditions(_ sender: Any) {
        let vc:WebViewViewController = self.storyboard?.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        vc.UrlLink  = "https://www.adimvi.com/?qa=T%C3%A9rminos-y-privacidad"
        vc.Title = "Términos y Condiciones"
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func OnTermandprivacy(_ sender: Any) {
        let vc:WebViewViewController = self.storyboard?.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        vc.UrlLink  = "https://www.adimvi.com/?qa=T%C3%A9rminos-y-privacidad"
        vc.Title = "Términos y política de privacidad"
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func OnInformation(_ sender: Any) {
        let vc:WebViewViewController = self.storyboard?.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        vc.UrlLink  = "https://www.adimvi.com/?qa=Informaci%C3%B3n"
        vc.Title = "Información"
        self.present(vc, animated: true, completion: nil)
    }
}

extension RegistrationVc: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtName {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else {return false}
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count < 16
        }
        return true
    }
}
