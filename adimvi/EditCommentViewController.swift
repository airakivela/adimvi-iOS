//
//  EditCommentViewController.swift
//  adimvi
//
//  Created by javed carear  on 12/09/19.
//  Copyright © 2019 webdesky.com. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
class EditCommentViewController: UIViewController {
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var textviewComment: UITextView!
    var PostID:String!
    var UserID:String!
    var CategoryId:String!
    var EditComment:NSAttributedString!
    override func viewDidLoad() {
        super.viewDidLoad()
        textviewComment.attributedText! = EditComment
       
    }
    
    @IBAction func OnEdit(_ sender: Any) {
        CallWebEdit()
     
    }
  
    func CallWebEdit(){
        let Para =
            ["postid":"\(PostID!)","comment":"\(textviewComment.text!)","type":"A"] as [String : Any]
        
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.editHideShowpostComment)"
        
        
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        
                        self.textviewComment.text = ""
                        
                      
                        DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                            
                        }
                    }
                   
                    break
                case .failure(_):
                    objActivity.stopActivity()
                    print(response.result.error as Any)
                    break
                }
        }
    }
    
    

}
