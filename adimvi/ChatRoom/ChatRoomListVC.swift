//
//  ChatRoomListVC.swift
//  adimvi
//
//  Created by Aira on 22.10.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON

class ChatRoomListVC: UIViewController {
    
    @IBOutlet weak var parentSV: UIScrollView!
    @IBOutlet weak var siguiendoRoomCV: UICollectionView!
    @IBOutlet weak var normalRoomUV: UIView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var normalRoomTV: UITableView!
    
    var goingUp: Bool?
    var childScrollingDownDueToParent = false
    
    var siguiendoRooms: [RoomModel] = [RoomModel]()
    var normalRooms: [RoomModel] = [RoomModel]()
    var filterNormalRooms: [RoomModel] = [RoomModel]()
    
    let userID: String = UserDefaults.standard.string(forKey: "ID")!
    
    var roomObserve: DatabaseHandle?
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        siguiendoRoomCV.register(UINib(nibName: "AddRoomCell", bundle: nil), forCellWithReuseIdentifier: "AddRoomCell")
        siguiendoRoomCV.register(UINib(nibName: "SiguiendoRoomCell", bundle: nil), forCellWithReuseIdentifier: "SiguiendoRoomCell")
        siguiendoRoomCV.delegate = self
        siguiendoRoomCV.dataSource = self
        
        normalRoomTV.register(UINib(nibName: "NormalRoomCell", bundle: nil), forCellReuseIdentifier: "NormalRoomCell")
        normalRoomTV.rowHeight = UITableView.automaticDimension
        normalRoomTV.estimatedRowHeight = 122.0
        normalRoomTV.delegate = self
        normalRoomTV.dataSource = self
        
        parentSV.delegate = self
        searchTF.delegate = self
        
        isClickFollowRoom = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initFireDB()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let roomHandle = roomObserve {
            FireUtil.firebaseRef.fireDBRoomIDS.removeObserver(withHandle: roomHandle)
        }
    }
    
     // MARK: - Navigation
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     }
    
    @IBAction func didTapBackUB(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - ChatRoomListVC's functions
extension ChatRoomListVC {
    
    func initFireDB() {
        objActivity.startActivityIndicator()
        roomObserve = FireUtil.firebaseRef.fireDBRoomIDS.observe(.value, with: { [self] (_) in
            onCallFetchRoomList()
        })
    }
    
    func onCallFetchRoomList() {
        let userID: String = UserDefaults.standard.string(forKey: "ID")!
        let param: [String: String] = [
            "userid": userID
        ]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.GET_ROOM_LIST)"
        Alamofire.request(Api, method: .post, parameters: param).responseJSON { [self] (response) in
            switch response.result {
            case .success(_):
                objActivity.stopActivity()
                siguiendoRooms.removeAll()
                normalRooms.removeAll()
                filterNormalRooms.removeAll()
                let responseJSON = JSON.init(response.result.value!)
                let resultJSON: [JSON] = responseJSON["response"].arrayValue
                for json in resultJSON {
                    let roomModel: RoomModel = RoomModel()
                    roomModel.initWithJSON(object: json)
                    if roomModel.isSiguiendo == 1 {
                        siguiendoRooms.append(roomModel)
                    } else {
                        normalRooms.append(roomModel)
                    }
                }
                if let filterKey = searchTF.text?.lowercased() {
                    if filterKey.isEmpty {
                        filterNormalRooms = normalRooms
                    } else {
                        filterNormalRooms = normalRooms.filter({ (room) -> Bool in
                            room.title.contains(filterKey)
                        })
                    }
                }
                if normalRooms.isEmpty {
                    parentSV.isScrollEnabled = false
                    normalRoomUV.isHidden = true
                } else {
                    parentSV.isScrollEnabled = true
                    normalRoomUV.isHidden = false
                }
                siguiendoRoomCV.reloadData()
                normalRoomTV.reloadData()
                break
            case .failure(_):
                objActivity.stopActivity()
                break
            }
        }
    }
    
    func filterRooms(key: String) {
        filterNormalRooms.removeAll()
        filterNormalRooms = normalRooms.filter({ (room) -> Bool in
            room.title.lowercased().contains(key)
        })
        normalRoomTV.reloadData()
    }
    
    func joinRoom(room: RoomModel) {
        objActivity.startActivityIndicator()
        let param: [String: String] = [
            "roomID": "\(room.roomID)",
            "loggedin_userid": "\(userID)"
        ]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.JOIN_ROOM)"
        Alamofire.request(Api, method: .post, parameters: param).responseJSON { (response) in
            switch response.result {
            case .success(_):
                objActivity.stopActivity()
                FireUtil.firebaseRef.joinLeaveRoom(room: room, isJoin: true)
                let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier: "ChatRoomVC") as! ChatRoomVC
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                vc.room = room
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
                break
            case .failure(_):
                objActivity.stopActivity()
                break
            }
        }
    }
}

//MARK: - CollectionViewDelegate and DataSource
extension ChatRoomListVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.performSegue(withIdentifier: "addRoom", sender: nil)
        } else {
            let room = siguiendoRooms[indexPath.row - 1]
            joinRoom(room: room)
        }
    }
}

extension ChatRoomListVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 15.0)
    }
}

extension ChatRoomListVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return siguiendoRooms.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddRoomCell", for: indexPath) as? AddRoomCell
            return cell!
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SiguiendoRoomCell", for: indexPath) as? SiguiendoRoomCell
            cell?.room = siguiendoRooms[indexPath.row - 1]
            return cell!
        }
    }
    
}

//MARK: - TableViewDelegat and DataSource
extension ChatRoomListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ChatRoomListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterNormalRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NormalRoomCell") as? NormalRoomCell
        cell?.room = normalRooms[indexPath.row]
        cell?.callBack = { [self] in
            let room = normalRooms[indexPath.row]
            joinRoom(room: room)
        }
        return cell!
    }
}

//MARK: - ScrollViewDelegate
extension ChatRoomListVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        goingUp = scrollView.panGestureRecognizer.translation(in: scrollView).y < 0
        let parentViewMaxContentYOffset = parentSV.contentSize.height - parentSV.frame.height
        
        if goingUp! {
            if scrollView == normalRoomTV {
                if parentSV.contentOffset.y < parentViewMaxContentYOffset && !childScrollingDownDueToParent {
                    parentSV.contentOffset.y = min(parentSV.contentOffset.y + normalRoomTV.contentOffset.y, parentViewMaxContentYOffset)
                    normalRoomTV.contentOffset.y = 0
                }
            }
        } else {
            if scrollView == normalRoomTV {
                if normalRoomTV.contentOffset.y < 0 && parentSV.contentOffset.y > 0 {
                    parentSV.contentOffset.y = max(parentSV.contentOffset.y - abs(normalRoomTV.contentOffset.y), 0)
                }
            }
            if scrollView == parentSV {
                if normalRoomTV.contentOffset.y > 0 && normalRoomTV.contentOffset.y < parentViewMaxContentYOffset {
                    childScrollingDownDueToParent = true
                    normalRoomTV.contentOffset.y = max(normalRoomTV.contentOffset.y - (parentViewMaxContentYOffset - parentSV.contentOffset.y), 0)
                    parentSV.contentOffset.y = parentViewMaxContentYOffset
                    childScrollingDownDueToParent = false
                }
            }
        }
    }
}

//MARK: - TextField Delegate
extension ChatRoomListVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchKey = textField.text! + string
        filterRooms(key: searchKey.lowercased())
        return true
    }
}

//MARK: - ChatRoomVC Delegate
extension ChatRoomListVC: ChatRoomVCCloseDelgate {
    func didShowFollowDialog(room: RoomModel) {
        if room.adminID == Int(userID) {
            return
        }
        let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier: "FollowVC") as! FollowVC
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.room = room
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func didCloseRoom() {
        let alert = UIAlertController(title: "Cierre de sala", message: "La persona que ha creado esta sala ha terminado el chat. ¡Gracias por unirte!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - FollowVC Delegate
extension ChatRoomListVC: FollowVCDelegate {
    func didTapFollowUB() {
        initFireDB()
    }
}
