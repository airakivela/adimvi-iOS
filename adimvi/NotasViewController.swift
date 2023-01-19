
//  NotasViewController.swift
//  adimvi
//  Created by javed carear  on 10/05/1942 Saka.
//  Copyright © 1942 webdesky.com. All rights reserved.

import UIKit
import Alamofire
class NotasViewController: UIViewController {
    
    @IBOutlet weak var tableviewNotas: UITableView!
    @IBOutlet weak var buttonAdd2: UIButton!
    @IBOutlet weak var buttonAdd1: UIButton!
    @IBOutlet weak var htAddview: NSLayoutConstraint!
    @IBOutlet weak var contentUV: UIView!
    
    @IBOutlet weak var labelNotasTitle: FloatLabelTextField!
    @IBOutlet weak var textviewAddNotas: UITextView!
    var Decription = "0"
    var UserID:String!
    var Notasid:String!
    var arrayNotas = [[String: Any]]()
    var noteId:Int! = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        //TextViewPlaceholders
        textviewAddNotas.text = "Placeholder"
        textviewAddNotas.textColor = UIColor.red
        textviewAddNotas.delegate = self
        textviewAddNotas.text = "Empieza a escribir aquí"
        textviewAddNotas.textColor = UIColor.lightGray
        textviewAddNotas.selectedTextRange = textviewAddNotas.textRange(from: textviewAddNotas.beginningOfDocument, to: textviewAddNotas.beginningOfDocument)
        UserID = UserDefaults.standard.string(forKey: "ID")
        CallWebserviceNotasList()
    }
    
    @IBAction func OnAddNotas(_ sender: UIButton) {
        if sender.tag == 1 {
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.noteId = 0
                self.view.layoutIfNeeded()
            })
            self.buttonAdd1.isHidden = true
            self.buttonAdd2.isHidden = false
            contentUV.isHidden = false
            tableviewNotas.isHidden = true
            textviewAddNotas.text = "Empieza a escribir aquí"
            textviewAddNotas.textColor = UIColor.lightGray
            self.labelNotasTitle.text = ""
        }
        if sender.tag == 2 {
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
            self.buttonAdd1.isHidden = false
            self.buttonAdd2.isHidden = true
            tableviewNotas.isHidden = false
            contentUV.isHidden = true
        }
    }
    
    @IBAction func OnAdd(_ sender: Any) {
        if(noteId == 0){
            CallWebserviceAddNotas()
        }else{
            CallWebserviceeditNotas()
        }
        
    }
    
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func CallWebserviceAddNotas(){
        let Para =
            ["userid":"\(UserID!)","title":"\(labelNotasTitle.text!)","description":"\(textviewAddNotas.text!)"] as [String : Any]
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.addNotes)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        self.contentUV.isHidden = true
                        self.buttonAdd1.isHidden = false
                        self.buttonAdd2.isHidden = true
                        self.labelNotasTitle.text = ""
                        self.textviewAddNotas.text = "Empieza a escribir aquí"
                        objActivity.stopActivity()
                        DispatchQueue.main.async {
                            self.CallWebserviceNotasList()
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
    
    func CallWebserviceeditNotas(){
        let Para =
            ["userid":"\(UserID!)","title":"\(labelNotasTitle.text!)","description":"\(textviewAddNotas.text!)","noteId": "\(Notasid!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.updateNotes)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        self.contentUV.isHidden = true
                        self.buttonAdd1.isHidden = false
                        self.buttonAdd2.isHidden = true
                        self.labelNotasTitle.text = ""
                        self.textviewAddNotas.text = "Empieza a escribir aquí"
                        objActivity.stopActivity()
                        DispatchQueue.main.async {
                            self.CallWebserviceNotasList()
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
//MARK:- Extension TableView Delegate/DataSource Methods
extension NotasViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayNotas.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        self.buttonAdd1.isHidden = true
        self.buttonAdd2.isHidden = false
        tableviewNotas.isHidden = true
        contentUV.isHidden = false
        let dictData = self.arrayNotas[indexPath.row]
        if let Title = dictData["title"] as? String{
            self.labelNotasTitle.text = Title
        }
        if let description = dictData["description"] as? String{
            self.textviewAddNotas.text = description
            textviewAddNotas.textColor = UIColor.init(named: "Dark grey (Dark mode)")
        }
        noteId = dictData["noteId"] as? Int
        let NotasID = dictData["noteId"] as! String
        Notasid = NotasID
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idetifier = "NotasTableViewCell"
        let cell:NotasTableViewCell = tableviewNotas.dequeueReusableCell(withIdentifier: idetifier)as! NotasTableViewCell
        let dictData = self.arrayNotas[indexPath.row]
        if let Title = dictData["title"] as? String{
            cell.labeltitle.text = Title
        }
        if let description = dictData["description"] as? String{
            cell.buttonDescription.text = description
        }
        cell.buttonDelete.tag = indexPath.row
        cell.buttonDelete.addTarget(self, action: #selector(self.OnDelete(_:)), for: UIControl.Event.touchUpInside)
        return cell
    }
    
    @objc func OnDelete(_ sender : UIButton) {
        let dict = self.arrayNotas[sender.tag]
        let NotasID = dict["noteId"] as! String
        Notasid = NotasID
        CallWebserviceDeleteNotas()
    }
    
    func CallWebserviceNotasList(){
        let Para = ["userid":"\(UserID!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.notesList)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["notesList"]as? [[String:Any]]{
                                self.arrayNotas = Data
                                self.tableviewNotas.reloadData()
                            }
                        }
                        DispatchQueue.main.async {
                            self.tableviewNotas.isHidden = false
                        }
                    }
                    break
                case .failure(_):
                    print(response.result.error as Any)
                    break
                }
            }
    }
    
    func CallWebserviceDeleteNotas(){
        let Para = ["noteId":"\(Notasid!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.notesDelete)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        DispatchQueue.main.async {
                            self.CallWebserviceNotasList()
                        }
                    }
                    break
                case .failure(_):
                    print(response.result.error as Any)
                    break
                }
            }
    }
}

extension NotasViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText: NSString = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with:text)
        if updatedText.isEmpty {
            textView.text = "Empieza a escribir aquí"
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            return false
        } else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.init(named: "Dark grey (Dark mode)")
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
}
