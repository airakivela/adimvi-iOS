//
//  FollowVC.swift
//  adimvi
//
//  Created by Aira on 25.10.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit
import Alamofire

protocol FollowVCDelegate {
    func didTapFollowUB()
}

class FollowVC: UIViewController {

    @IBOutlet weak var userUIMG: UIImageView!
    @IBOutlet weak var userNameLB: UILabel!
    @IBOutlet weak var siguiendoUB: UIButton!
    @IBOutlet weak var seguirUB: UIButton!
    
    var room: RoomModel!
    var delegate: FollowVCDelegate?
    var isClickedFollowUB: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        userNameLB.text = room.adminName
        if room.adminAvatar.isEmpty {
            userUIMG.image = UIImage(named: "Splaceicon")
        } else {
            userUIMG.sd_setImage(with: URL(string: room.adminAvatar), placeholderImage: UIImage(named: "Splaceicon"))
        }
        if room.isSiguiendo == 1 {
            seguirUB.isHidden = true
            siguiendoUB.isHidden = false
        } else {
            seguirUB.isHidden = false
            siguiendoUB.isHidden = true
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func didTapCloseUB(_ sender: Any) {
        if isClickedFollowUB == false {
            dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true) {
                self.delegate?.didTapFollowUB()
            }
        }
    }
    
    @IBAction func didTapFollowUB(_ sender: Any) {
        isClickedFollowUB = true
        let param: [String: String] = [
            "userid": UserDefaults.standard.string(forKey: "ID")!,
            "entityid": "\(room.adminID)"
        ]
        objActivity.startActivityIndicator()
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.setUserFollowing)"
        Alamofire.request(Api, method: .post, parameters: param).responseJSON { [self] (response) in
            switch response.result {
            case .success(_):
                objActivity.stopActivity()
                if siguiendoUB.isHidden {
                    seguirUB.isHidden = true
                    siguiendoUB.isHidden = false
                } else {
                    seguirUB.isHidden = false
                    siguiendoUB.isHidden = true
                }
                break
            case .failure(_):
                objActivity.stopActivity()
                break
            }
        }
    }
}
