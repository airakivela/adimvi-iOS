//
//  ChatRoomVC.swift
//  adimvi
//
//  Created by Aira on 25.10.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase
import iRecordView
import AVFoundation
import GrowingTextView

protocol ChatRoomVCCloseDelgate {
    func didShowFollowDialog(room: RoomModel)
    func didCloseRoom()
}

class ChatRoomVC: UIViewController {
    
    @IBOutlet weak var roomBGUIMG: UIImageView!
    @IBOutlet weak var roomAdminAvatarUIMG: UIImageView!
    @IBOutlet weak var roomAdminNameLB: UILabel!
    @IBOutlet weak var roomAdminVerifyUIMG: UIImageView!
    @IBOutlet weak var roomMemberCntLB: UILabel!
    @IBOutlet weak var adminMessageTV: UITableView!
    @IBOutlet weak var otherMessageTV: UITableView!
    @IBOutlet weak var roomCloseUIMG: UIImageView!
    @IBOutlet weak var msgTextV: GrowingTextView!
    @IBOutlet weak var cameraUIMG: UIImageView!
    @IBOutlet weak var typingLB: UILabel!
    @IBOutlet weak var sendUB: UIButton!
    @IBOutlet weak var recordUV: RecordView!
    @IBOutlet weak var recordUB: RecordButton!
    @IBOutlet weak var inputUV: UIView!
    
    var roomObserveHandle: DatabaseHandle?
    var roomMessageHandle: DatabaseHandle?
    var typingObserveHandle: DatabaseHandle?
    
    let userID: String = UserDefaults.standard.string(forKey: "ID")!
    var uploadData: Data?
    var isAlreadyTyping: Bool = false
    
    var delegate: ChatRoomVCCloseDelgate?
    var imagePicker = UIImagePickerController()
    var room: RoomModel = RoomModel()
    var adminMessages: [RoomMessageModel] = [RoomMessageModel]()
    var otherMesagees: [RoomMessageModel] = [RoomMessageModel]()
    
    var audioRecordeer: AVAudioRecorder?
    var recordFileURL: URL?
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AVAudioSession.sharedInstance().requestRecordPermission { (allowed) in
            if !allowed {
                print("permission denied")
            }
            
        }
        
        roomCloseUIMG.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapClose)))
        initView(room: room)
        
        adminMessageTV.register(UINib(nibName: "AdminMessageCell", bundle: nil), forCellReuseIdentifier: "AdminMessageCell")
        adminMessageTV.register(UINib(nibName: "AdminAudioMessageCell", bundle: nil), forCellReuseIdentifier: "AdminAudioMessageCell")
        adminMessageTV.rowHeight = UITableView.automaticDimension
        adminMessageTV.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi))
        adminMessageTV.dataSource = self
        
        otherMessageTV.register(UINib(nibName: "OtherMessageCell", bundle: nil), forCellReuseIdentifier: "OtherMessageCell")
        otherMessageTV.register(UINib(nibName: "OtherAudioMessageCell", bundle: nil), forCellReuseIdentifier: "OtherAudioMessageCell")
        otherMessageTV.rowHeight = UITableView.automaticDimension
        otherMessageTV.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi))
        otherMessageTV.dataSource = self
        
        cameraUIMG.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCamera)))
        
        msgTextV.delegate = self
        
        recordUB.recordView = recordUV
        recordUV.slideToCancelText = "Desliza para cancelar"
        recordUV.slideToCancelTextColor = UIColor(named: "blackwhite")
        
        recordUV.isSoundEnabled = true
        recordUV.offset = 0
        recordUV.delegate = self
        
        recordUB.setImage(UIImage(systemName: "mic")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        recordUV.isHidden = true
        inputUV.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showRoomTitleDialog()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        roomObserveHandle = FireUtil.firebaseRef.fireDBRoomIDS.child("\(room.roomID)").observe(.value, with: { (snapshot) in
            if !snapshot.exists() {
                self.dismiss(animated: true) { [self] in
                    if self.room.roomID != Int(userID) {
                        self.delegate?.didCloseRoom()
                    }
                }
            }
        })
        
        roomMessageHandle = FireUtil.firebaseRef.fireDBRoomMessage.child("\(room.roomID)").child("roomMessages").observe(.value, with: { (snpashot) in
            self.initRoomMessageList()
        })
        
        typingObserveHandle = FireUtil.firebaseRef.fireDBRoomMessage.child("\(room.roomID)").child("isTyping").observe(.value, with: { (snap) in
            var isTyping = false
            if !snap.exists() {
                isTyping = false
            } else {
                isTyping = snap.value as! Bool
            }
            self.handleTypingIndicator(isAdminTyping: isTyping)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FireUtil.firebaseRef.fireDBRoomIDS.child("\(room.roomID)").removeObserver(withHandle: roomObserveHandle!)
        FireUtil.firebaseRef.fireDBRoomMessage.child("\(room.roomID)").child("roomMessages").removeObserver(withHandle: roomMessageHandle!)
        FireUtil.firebaseRef.fireDBRoomMessage.child("\(room.roomID)").child("isTypiing").removeObserver(withHandle: typingObserveHandle!)
    }
    
    @IBAction func didTapSendUB(_ sender: Any) {
        didTapSendUB()
    }
    
}

//MARK: - ChatRoomVC's own function

extension ChatRoomVC {
    
    func showRoomTitleDialog () {
        let alert = UIAlertController(title: "Tema de la sala", message: room.title, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func initView(room: RoomModel) {
        roomBGUIMG.image = room.background
        if room.adminAvatar.isEmpty {
            roomAdminAvatarUIMG.image = UIImage(named: "Splaceicon")
        } else {
            roomAdminAvatarUIMG.sd_setImage(with: URL(string: room.adminAvatar), placeholderImage: UIImage(named: "Splaceicon"))
        }
        if room.adminVerify == 1 {
            roomAdminVerifyUIMG.isHidden = false
        } else {
            roomAdminVerifyUIMG.isHidden = true
        }
        roomAdminNameLB.text = room.adminName
        roomMemberCntLB.text = getThousandWithK(value: room.memberCnt)
    }
    
    func setUPAudioRecord() {
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let format = DateFormatter()
        format.dateFormat = "yyyyMMddHHmmss"
        let currentFileName = "\(format.string(from: Date())).m4a"
        self.recordFileURL = path.appendingPathComponent(currentFileName)
        
        let recordSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 24000, //32000,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey: 24000 //44100.0
        ]
        
        do {
            audioRecordeer = try AVAudioRecorder(url: recordFileURL!, settings: recordSettings)
            audioRecordeer?.record()
            audioRecordeer?.isMeteringEnabled = true
            print("recording")
        } catch (let error){
            audioRecordeer = nil
            print("error")
            print(error.localizedDescription)
        }
    }
    
    func initRoomMessageList() {
        let param: [String: String] = [
            "loggedin_userid": userID,
            "roomID":"\(room.roomID)"
        ]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.GET_ROOM_MESSAGE)"
        Alamofire.request(Api, method: .post, parameters: param).responseJSON { [self] (response) in
            switch response.result {
            case .success(_):
                let responseJSON = JSON.init(response.result.value!)
                let roomInfo: JSON = responseJSON["room"]
                let roomModel: RoomModel = RoomModel()
                roomModel.initWithJSON(object: roomInfo)
                self.room = roomModel
                initView(room: self.room)
                let roomMessages: [JSON] = responseJSON["message"].arrayValue
                adminMessages.removeAll()
                otherMesagees.removeAll()
                for message in roomMessages {
                    let roomMessage: RoomMessageModel = RoomMessageModel()
                    roomMessage.initWithJSON(jsonObject: message)
                    if room.adminID == roomMessage.userID {
                        adminMessages.append(roomMessage)
                    } else {
                        otherMesagees.append(roomMessage)
                    }
                }
                DispatchQueue.main.async {
                    self.adminMessageTV.reloadData()
                    self.otherMessageTV.reloadData()
                }
                break
            case .failure(_):
                break
            }
        }
    }
    
    @objc func didTapClose() {
        if Int(userID) == room.adminID {
            showCloseDialog(title: "Salir de la sala", msg: "¿Deseas salir y abandonar la sala de chat?")
        } else {
            showCloseDialog(title: "Abandonar la sala", msg: "¿Deseas salir de la sala de chat en vivo?")
        }
    }
    
    func showCloseDialog(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { _ in
            alert.dismiss(animated: true) { [self] in
                if Int(userID) == room.adminID {
                    closeRoom()
                } else {
                    leaveRoom(willShowFollowDialog: true)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func closeRoom() {
        let param: [String: String] = [
            "roomID": "\(room.roomID)"
        ]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.CLOSE_ROOM)"
        Alamofire.request(Api, method: .post, parameters: param).responseJSON { [self] (response) in
            switch response.result {
            case .success(_):
                objActivity.stopActivity()
                FireUtil.firebaseRef.closeRoom(room: room)
                break
            case .failure(_):
                objActivity.stopActivity()
                break
            }
        }
    }
    
    func leaveRoom(willShowFollowDialog: Bool) {
        let userID: String = UserDefaults.standard.string(forKey: "ID")!
        let param: [String: String] = [
            "loggedin_userid": userID,
            "roomID":"\(room.roomID)"
        ]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.LEAVE_ROOM)"
        Alamofire.request(Api, method: .post, parameters: param).responseJSON {(response) in
            switch response.result {
            case .success(_):
                objActivity.stopActivity()
                FireUtil.firebaseRef.setRoomMessage(room: self.room)
                FireUtil.firebaseRef.joinLeaveRoom(room: self.room, isJoin: false)
                if willShowFollowDialog {
                    self.dismiss(animated: true) { [self] in
                        delegate?.didShowFollowDialog(room: room)
                    }
                }
                else {
                    self.dismiss(animated: true, completion: nil)
                }
                break
            case .failure(_):
                objActivity.stopActivity()
                break
            }
        }
    }
    
    @objc func handleCamera() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        } else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary(){
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func handleTypingIndicator(isAdminTyping: Bool) {
        if room.adminID == Int(userID) {
            typingLB.isHidden = true
        } else {
            typingLB.isHidden = !isAdminTyping
        }
    }
    
    func showFullImageVC(image: UIImage) {
        let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier:  "FullImageVC") as! FullImageVC
        vc.image = image
        present(vc, animated: true, completion: nil)
    }
    
    func didTapSendUB() {
        let msgStr: String = msgTextV.text!
        if msgStr.isEmpty && uploadData == nil {
            return
        }
        let param: [String: String] = [
            "type": "GROUP",
            "fromuserid": userID,
            "touserid": "\(room.roomID)",
            "content": msgStr
        ]
        let url: String = "\(WebURL.BaseUrl)\(WebURL.ADD_ROOM_MESSAGE)"
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in param {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if let data = self.uploadData {
                multipartFormData.append(data,withName: "extra", fileName: "Post.png", mimeType: "image/png")
            }
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: nil) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let err = response.error{
                        #if DEBUG
                        print(err.localizedDescription)
                        #endif
                        return
                    }
                    self.reloadUI()
                    FireUtil.firebaseRef.setRoomMessage(room: self.room)
                }
            case .failure(let error):
                #if DEBUG
                print(error.localizedDescription)
                #endif
            }
        }
    }
    
    func reloadUI() {
        self.msgTextV.text = ""
//        self.msgTextV.textColor = UIColor.lightGray
//        self.textViewDidChange(self.msgTextV)
//        self.msgTextV.delegate = self
        self.uploadData = nil
        self.handleButtonState(isRecording: true)
        self.cameraUIMG.image = UIImage(systemName: "camera")
        self.cameraUIMG.layer.cornerRadius = 0.0
    }
    
    func handleButtonState(isRecording: Bool) {
        if isRecording {
            recordUB.isHidden = false
            sendUB.isHidden = true
        } else {
            sendUB.isHidden = false
            recordUB.isHidden = true
        }
    }
    
    func showPlayVC(model: RoomMessageModel) {
        let vc = UIStoryboard(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier: "VoicePlayerVC") as! VoicePlayerVC
        
        vc.callback = {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            vc.removeFromParent()
            vc.view.removeFromSuperview()
            vc.dismiss(animated: false, completion: nil)
        }
        self.addChild(vc)
        vc.model = model
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        vc.view.frame = self.view.frame
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
}

//MARK: - Image Picker Delegate
extension ChatRoomVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            cameraUIMG.image = editedImage
            cameraUIMG.layer.cornerRadius = 11.0
            uploadData = editedImage.pngData()
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.isNavigationBarHidden = false
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

//MARK: - TextViewDelegate for adapting height
extension ChatRoomVC: GrowingTextViewDelegate {

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" || textView.text.isEmpty {
            handleButtonState(isRecording: true)
        } else {
            handleButtonState(isRecording: false)
        }
        if room.adminID == Int(userID) {
            FireUtil.firebaseRef.removeAdminTyping(room: room)
            isAlreadyTyping = false
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText: NSString = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with:text)
        if updatedText.isEmpty {
            handleButtonState(isRecording: true)
            if room.adminID == Int(userID) {
                FireUtil.firebaseRef.removeAdminTyping(room: room)
                isAlreadyTyping = false
            }
//            return false
        } else {
            handleButtonState(isRecording: false)
            if room.adminID == Int(userID) {
                if !isAlreadyTyping {
                    FireUtil.firebaseRef.setAdminTyping(room: room)
                }
            }
            
            
        }
        return true
    }
}

//MARK: -TableViewDataSource
extension ChatRoomVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == adminMessageTV {
            return adminMessages.count
        } else {
            return otherMesagees.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == adminMessageTV {
            let message: RoomMessageModel = adminMessages[indexPath.row]
            if message.format == "3" {
                let cell = adminMessageTV.dequeueReusableCell(withIdentifier: "AdminAudioMessageCell", for: indexPath) as! AdminAudioMessageCell
                cell.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))
                cell.model = adminMessages[indexPath.row]
                cell.callback = { [self] result in
                    showPlayVC(model: result)
                }
                return cell
            } else {
                let cell = adminMessageTV.dequeueReusableCell(withIdentifier: "AdminMessageCell", for: indexPath) as! AdminMessageCell
                cell.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))
                cell.message = message
                cell.cellCallBack = { [self] result in
                    showFullImageVC(image: result)
                }
                return cell
            }
        } else {
            let message: RoomMessageModel = otherMesagees[indexPath.row]
            if message.format == "3" {
                let cell = otherMessageTV.dequeueReusableCell(withIdentifier: "OtherAudioMessageCell", for: indexPath) as! OtherAudioMessageCell
                cell.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))
                cell.model = message
                cell.callback = { [self] result in
                    showPlayVC(model: result)
                }
                return cell
            } else {
                let cell = otherMessageTV.dequeueReusableCell(withIdentifier: "OtherMessageCell", for: indexPath) as! OtherMessageCell
                cell.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))
                cell.message = message
                cell.cellCallBack = { [self] result in
                    showFullImageVC(image: result)
                }
                return cell
            }
        }
    }
}

//MARK: -iRecordView Delegate
extension ChatRoomVC: RecordViewDelegate {
    func onStart() {
        reloadUI()
        inputUV.isHidden = true
        recordUV.isHidden = false
        if !isAlreadyTyping && room.adminID == Int(userID) {
            FireUtil.firebaseRef.setAdminTyping(room: room)
            isAlreadyTyping = true
        }
        setUPAudioRecord()
        
    }
    
    func onCancel() {
        inputUV.isHidden = false
        recordUV.isHidden = true
        if room.adminID == Int(userID) {
            FireUtil.firebaseRef.removeAdminTyping(room: room)
            isAlreadyTyping = false
        }
        audioRecordeer?.deleteRecording()
    }
    
    func onFinished(duration: CGFloat) {
        inputUV.isHidden = false
        recordUV.isHidden = true
        if room.adminID == Int(userID) {
            FireUtil.firebaseRef.removeAdminTyping(room: room)
            isAlreadyTyping = false
        }
        audioRecordeer?.stop()
        let messageModel = RoomMessageModel()
        let recordTime = Int(duration * 1000)
        messageModel.content = "\(recordTime)"
        messageModel.extra = recordFileURL!.absoluteString
        messageModel.senderAvatar = room.adminAvatar
        messageModel.userName = room.adminName
        messageModel.format = "3"
        messageModel.senderVerify = room.adminVerify
        if Int(userID) == room.adminID {
            adminMessages.insert(messageModel, at: 0)
            adminMessageTV.reloadData()
        } else {
            otherMesagees.insert(messageModel, at: 0)
            otherMessageTV.reloadData()
        }
        
        
        let param: [String: String] = [
            "type": "GROUP",
            "fromuserid": userID,
            "touserid": "\(room.roomID)",
            "content": messageModel.content
        ]
        let url: String = "\(WebURL.BaseUrl)\(WebURL.ADD_VOICE_ROOM_MESSAGE)"
        
        let fileName = messageModel.extra.components(separatedBy: "/").last
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in param {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if let data = self.audioRecordeer?.url {
                multipartFormData.append(data,withName: "audio", fileName: fileName!, mimeType: "audio/x-m4a")
            }
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: nil) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let err = response.error{
                        #if DEBUG
                        print(err.localizedDescription)
                        #endif
                        return
                    }
                    self.reloadUI()
                    FireUtil.firebaseRef.setRoomMessage(room: self.room)
                    self.audioRecordeer = nil
                }
            case .failure(let error):
                #if DEBUG
                print(error.localizedDescription)
                #endif
            }
        }
        
    }
}


