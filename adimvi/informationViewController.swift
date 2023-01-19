//
//  informationViewController.swift
//  adimvi
//
//  Created by Jose Miguel Richart Paulino on 28/01/2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit
import Alamofire

class informationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func OnBack(_ sender: Any) {
           self.navigationController?.popViewController(animated: true)
       }
        @IBAction func Onforgetpassword(_ sender: Any) {
        let vc:WebViewViewController = self.storyboard?.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        vc.UrlLink  = "https://www.adimvi.com/?qa=forgot"
        vc.Title = "Recuperar contraseña"
         vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    @IBAction func OnInformation(_ sender: Any) {
        let vc:WebViewViewController = self.storyboard?.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        vc.UrlLink  = "https://www.adimvi.com/?qa=Informaci%C3%B3n"
        vc.Title = "Preguntas frecuentes"
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
    
}
