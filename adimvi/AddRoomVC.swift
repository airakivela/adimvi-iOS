//
//  AddRoomVC.swift
//  adimvi
//
//  Created by Aira on 23.10.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AddRoomVC: UIViewController {

    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var termsUB: UIButton!
    @IBOutlet weak var roomBGCV: UICollectionView!
    
    let userID: String = UserDefaults.standard.string(forKey: "ID")!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        roomBGCV.register(UINib(nibName: "RoomBGCell", bundle: nil), forCellWithReuseIdentifier: "RoomBGCell")
        roomBGCV.delegate = self
        roomBGCV.dataSource = self
    }
    
    @IBAction func onTapCheckUB(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func onTpaTerms(_ sender: Any) {
        let vc:WebviewTabController = self.storyboard?.instantiateViewController(withIdentifier: "WebviewTabController") as! WebviewTabController
        vc.UrlLink  = "https://www.adimvi.com/appAPI/index.php/front/terms"
        vc.Title = "Información"
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func onTapAddRoom(_ sender: Any) {
        if titleTF.text!.isEmpty {
            showValidationAlert(msg: "Introduce el título de tu directos")
            return
        }
        if !termsUB.isSelected {
            showValidationAlert(msg: "Por favor, lee y verifica los términos y condiciones")
            return
        }
        onCallAddRoom()
    }
    
    @IBAction func onTapBackBI(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - AddRoomVC's own function
extension AddRoomVC {
    func onCallAddRoom() {
        let userID: String = UserDefaults.standard.string(forKey: "ID")!
        let title: String = titleTF.text!
        let selectedBgIndex = BGList.firstIndex { (room) -> Bool in
            room.isSelected == true
        }
        let bgIndex: String = "\(selectedBgIndex!)"
        let param: [String: String] = [
            "adminID": userID,
            "title": title,
            "bgIndex": bgIndex
        ]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.ADD_ROOM)"
        Alamofire.request(Api, method: .post, parameters: param).responseJSON {(response) in
            switch response.result {
            case .success(_):
                objActivity.stopActivity()
                let responseJSON = JSON.init(response.result.value!)
                let room: RoomModel = RoomModel()
                room.roomID = responseJSON["response"].intValue
                room.adminID = Int(userID)!
                room.adminName = ""
                room.memberCnt = 1
                room.title = title
                room.adminAvatar = ""
                room.adminVerify = 0
                room.background = BGList[selectedBgIndex!].image
                FireUtil.firebaseRef.createRoom(room: room) {
                    let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier: "ChatRoomVC") as! ChatRoomVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    vc.room = room
                    self.present(vc, animated: true, completion: nil)
                }
                
                break
            case .failure(_):
                objActivity.stopActivity()
                break
            }
        }
    }
    
    func showValidationAlert(msg: String) {
        let alert = UIAlertController(title: "Mensaje", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: - Collection View Delegate & DataSource
extension AddRoomVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for i in 0 ..< BGList.count {
            if i == indexPath.row {
                BGList[i].isSelected = true
            } else {
                BGList[i].isSelected = false
            }
        }
        collectionView.reloadData()
    }
}

extension AddRoomVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = roomBGCV.frame.height
        let width = (9.0 / 16.0) * height
        #if DEBUG
        print("w--->\(width), h--->\(height)")
        #endif
        return CGSize(width: width, height: floor(height))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 15.0)
    }
}

extension AddRoomVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BGList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomBGCell", for: indexPath) as! RoomBGCell
        cell.bgItem = BGList[indexPath.row]
        return cell
    }
}

