
//  PrivateMessageViewController.swift
//  adimvi
//  Created by javed carear  on 22/08/19.
//  Copyright © 2019 webdesky.com. All rights reserved.

import UIKit
import Alamofire
import SDWebImage
import SwiftyJSON
import GrowingTextView

class PrivateMessageViewController: UIViewController {
    @IBOutlet weak var uploadImage: UIImageView!
    @IBOutlet weak var tableviewPrivateMassage: UITableView!
    @IBOutlet weak var TextviewContent: GrowingTextView!
    @IBOutlet weak var sendImg: UIImageView!
    var OtherUserId:String!
    var UserID:String!
    var ImageStatus = "0"
    var imagePicker = UIImagePickerController()
    var Imagename:UIImage!
    var NotifiationStatus:String!
    var FromUserId:String!
    
    var targetUserName: String?
    var targetUserAvatar: String?
    var targetUserVerify: Bool?
    
    var typingIndicator: UILabel = {
        let indicator: UILabel = UILabel()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.text = "• Escribiendo"
        indicator.font = .systemFont(ofSize: 12.0)
        indicator.textColor = UIColor(named: "Dark light grey (dark mode)")
        return indicator
    }()
    
    var onlineStatus: UILabel = {
        let indicator: UILabel = UILabel()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.text = "• En línea"
        indicator.font = .systemFont(ofSize: 12.0)
        indicator.textColor = UIColor(named: "Dark light grey (dark mode)")
        return indicator
    }()
    
    var isAlreadyTyping: Bool = false
    var isTargetUserOnline: String = "0"
    
    @IBOutlet weak var htMainView: NSLayoutConstraint!
    var arrayprivateMassage =  [[String: Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        TextviewContent.text = "Placeholder"
//        TextviewContent.sizeToFit()
//        TextviewContent.textColor = UIColor.red
//        TextviewContent.delegate = self
//        TextviewContent.text = "Escribe..."
//        TextviewContent.textColor = UIColor.lightGray
//        TextviewContent.selectedTextRange = TextviewContent.textRange(from: TextviewContent.beginningOfDocument, to: TextviewContent.beginningOfDocument)
        TextviewContent.delegate = self
        tableviewPrivateMassage.estimatedRowHeight = 100
        tableviewPrivateMassage.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi))
        tableviewPrivateMassage.showsVerticalScrollIndicator = false
        UserID = UserDefaults.standard.string(forKey:"ID")
        OtherUserId = UserDefaults.standard.string(forKey: "OtherUserID")
        if NotifiationStatus == "1"{
            OtherUserId = UserDefaults.standard.string(forKey: "ID")
        }
        sendImg.isUserInteractionEnabled = true
        sendImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapSend)))
        
        
        let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0))
        imageView.layer.cornerRadius = 15.0
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        
        if let avatar = targetUserAvatar, !avatar.isEmpty {
            let imageURl = "\(WebURL.ImageUrl)\(avatar)"
            imageView.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        } else {
            let logo = UIImage(named: "Splaceicon")?.resizedImage(newWidth: 30.0)
            imageView.image = logo
        }
        
        
        let name = UILabel()
        if let nameStr = targetUserName, !nameStr.isEmpty {
            name.text = nameStr
        } else {
            name.text = ""
        }
        
        let verifiedMark = UIImageView()
        verifiedMark.image = UIImage(named: "ic_facebook_check_marker")
        verifiedMark.widthAnchor.constraint(equalToConstant: 16.0).isActive = true
        verifiedMark.heightAnchor.constraint(equalToConstant: 16.0).isActive = true
        
        let stackUV = UIStackView()
        stackUV.spacing = 8.0
        stackUV.alignment = .center
        stackUV.axis = .horizontal
        
        stackUV.addArrangedSubview(imageView)
        stackUV.addArrangedSubview(name)
        stackUV.addArrangedSubview(typingIndicator)
        stackUV.addArrangedSubview(onlineStatus)
        typingIndicator.isHidden = true
        onlineStatus.isHidden = true
        if let verify = targetUserVerify {
            if verify {
                stackUV.addArrangedSubview(verifiedMark)
            }            
        }
        
        stackUV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapUserAvatar)))
        
        self.title = ""
        self.navigationItem.leftBarButtonItems?.append(UIBarButtonItem(customView: stackUV))
        
    }
    
    @objc func appMovedToBackground() {
        FireUtil.firebaseRef.removePrivateMessageTypingIndicator(userID1: UserID, userID2: OtherUserId)
        FireUtil.firebaseRef.removeChanelUserOnline(userID1: UserID, userID2: OtherUserId)
    }
    
    @objc func appMovedToForeground() {
        FireUtil.firebaseRef.setChanelUserOnline(userID1: UserID, userID2: OtherUserId)
    }
    
    @objc func didTapUserAvatar() {
        UserDefaults.standard.set(OtherUserId, forKey: "OtherUserID")
        
        let vc: ProfilerootViewController = self.storyboard?.instantiateViewController(withIdentifier:"ProfilerootViewController")as! ProfilerootViewController
        SharedManager.sharedInstance.otherProfile = "1"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        receiveFireDataChange()
        //MARK: - remove typing indicator and online when app is in background.
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        FireUtil.firebaseRef.removePrivateMessageTypingIndicator(userID1: UserID, userID2: OtherUserId)
        FireUtil.firebaseRef.removeChanelUserOnline(userID1: UserID, userID2: OtherUserId)
    }
    
    @objc func didTapSend() {
        if ImageStatus == "1"{
            UploadingImage()
        }else{
            SendPrivateMassage()
        }
    }
    
    @IBAction func OnSendPrivateMassage(_ sender: Any) {
        
        
    }
    
    @objc func removeImage() {
        let imageView = (self.view.viewWithTag(100)! as! UIImageView)
        imageView.removeFromSuperview()
        navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = false
    }
    
    func addImageViewWithImage(image: UIImage) {
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.black
        imageView.image = image
        imageView.tag = 100
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(self.removeImage))
        dismissTap.numberOfTapsRequired = 1
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(dismissTap)
        self.view.addSubview(imageView)
        navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = true
        imageView.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2)
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
    }
}
//MARK:- Extension TableView Delegate/DataSource Methods
extension PrivateMessageViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayprivateMassage.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? PrivateMassageViewCell {
            if cell.Postimage.image == nil {
                let alert = UIAlertController(title: "Attention", message: "Image not ready", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            } else {
                self.addImageViewWithImage(image:  cell.Postimage.image!)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idetifier = "PrivateMassageViewCell"
        let cell:PrivateMassageViewCell = tableviewPrivateMassage.dequeueReusableCell(withIdentifier: idetifier)as! PrivateMassageViewCell
        cell.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))
        let dictData = arrayprivateMassage[indexPath.row]
        if let Image = dictData["image_path"] as? String{
            cell.Postimage.sd_setImage(with: URL(string:Image))
            if cell.Postimage.image != nil{
                cell.htImages.constant = 180
                cell.htColorView.constant = 270
            }else{
                cell.htImages.constant = 0
                cell.htColorView.constant = 85
            }
        }
        if let verify = dictData["verify"] as? String {
            cell.verifiedMarker.isHidden = verify == "1" ? false : true
        }
        if let Content = dictData["content"] as? String {
            cell.labelMassage.text = Content
        }
        if let time = dictData["created"] as? String {
            cell.labeTime.text = time
        }
        if let FromUser = dictData["from_user"] as? String {
            cell.labelUserName.text = FromUser
        }
        if let FromUserid = dictData["from_userid"] as? String {
            FromUserId = FromUserid
        }
        if let hasRecentPost = dictData["hasRecentPost"] as? Int {
            if hasRecentPost == 1{
                if (dictData["from_userid"] as! String) != UserID {
                    cell.recentWallUV.layer.borderWidth = 2.0
                } else {
                    cell.recentWallUV.layer.borderWidth = 0.0
                }
            } else {
                cell.recentWallUV.layer.borderWidth = 0.0
            }
        }
        if UserID == FromUserId {
            cell.recentWallUV.layer.borderWidth = 0.0
            cell.ColorView.backgroundColor = UIColor.init(named: "low white (dark mode)")
            cell.labelUserName.textColor = .orange
            cell.htLeading.constant = 60
            cell.htTraling.constant = 14
        } else {
            cell.ColorView.backgroundColor = UIColor.init(named: "Pink (dark mode)")
            cell.labelUserName.textColor = UIColor.init(named: "Dark grey (Dark mode)")
            cell.htTraling.constant = 60
            cell.htLeading.constant = 14
        }
        if  let profilePic = dictData["from_user_avatarblobid"] as? String{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            cell.imgProfilePic.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
        }
        return cell
    }
    
    func CallWebservicePMessage(){
        let Para = ["fromuserid":"\(UserID!)","touserid":"\(OtherUserId!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.privateMessagesList)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["message"]as? [[String:Any]]{
                                self.arrayprivateMassage = Data
                                self.tableviewPrivateMassage.reloadData()
                                _ =  self.arrayprivateMassage[0]
                            }
                        }
                    }
                    break
                case .failure(_):
                    print(response.result.error as Any)
                    break
                }
            }
    }
    
    func scrollToBottom () {
        DispatchQueue.main.async {
            if self.arrayprivateMassage.count == 0 {
                return
            } else {
                let index = IndexPath(row: self.arrayprivateMassage.count - 1, section: 0)
                self.tableviewPrivateMassage.scrollToRow(at: index, at: .bottom, animated: true)
            }
        }
    }
    
    //Multipart Image
    func UploadingImage(){
        let imageData: NSData = Imagename!.pngData()! as NSData
        let Para: [String: Any] =
            ["fromuserid":"\(UserID!)",
             "touserid":"\(OtherUserId!)",
             "content":"\(TextviewContent.text!)",
             "isON":isTargetUserOnline
            ]
        print(Para)
        requestWith(videoData: imageData as Data, parameters: Para, onCompletion: { (response) in
            
        }) { (error) in
            
        }
    }
    
    //MARK: - Upload video with multipart
    func requestWith(videoData: Data?, parameters: [String : Any], onCompletion: ((JSON?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
        let url = "\(WebURL.BaseUrl)\(WebURL.addPrivateMessages)"
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if let data = videoData{
                multipartFormData.append(data,withName: "image_name", fileName: "Post.png", mimeType: "image/png")
            }
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: nil) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let err = response.error{
                        onError?(err)
                        return
                    }
                    debugPrint(response.result.value!)
                    onCompletion?(nil)
//                    self.TextviewContent.text = "Placeholder"
//                    self.TextviewContent.textColor = UIColor.red
//                    self.TextviewContent.delegate = self
//                    self.TextviewContent.text = "Escribe..."
//                    self.textViewDidChange(self.TextviewContent)
                    self.TextviewContent.text = ""
                    self.ImageStatus = "0"
                    self.Imagename = nil
//                    self.TextviewContent.textColor = UIColor.lightGray
//                    self.TextviewContent.selectedTextRange = self.TextviewContent.textRange(from: self.TextviewContent.beginningOfDocument, to: self.TextviewContent.beginningOfDocument)
                    self.uploadImage.image = UIImage(named:"SCamera")
                    self.liveChatMode()
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                onError?(error)
            }
        }
    }
    
    //MARK: - Send private Massage
    func SendPrivateMassage(){
        let Para = ["fromuserid":"\(UserID!)","touserid":"\(OtherUserId!)","content":"\(TextviewContent.text!)","image_name":"", "isON":isTargetUserOnline] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.addPrivateMessages)"
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        self.TextviewContent.text = ""
//                        self.TextviewContent.text = "Placeholder"
//                        self.TextviewContent.textColor = UIColor.red
//                        self.TextviewContent.delegate = self
//                        self.TextviewContent.text = "Escribe..."
//                        self.textViewDidChange(self.TextviewContent)
//                        self.TextviewContent.textColor = UIColor.lightGray
//                        self.TextviewContent.selectedTextRange = self.TextviewContent.textRange(from: self.TextviewContent.beginningOfDocument, to: self.TextviewContent.beginningOfDocument)
                        self.liveChatMode()
                    }
                    break
                case .failure(_):
                    print(response.result.error as Any)
                    break
                }
            }
    }
    
    //MARK: - Firebase Database sync
    func liveChatMode() {
        FireUtil.firebaseRef.addPrivateMessage(userID1: UserID, userID2: OtherUserId)
    }
    
    func receiveFireDataChange() {
        FireUtil.firebaseRef.receivePrivateMessage(userID1: UserID, userID2: OtherUserId) {
            self.CallWebservicePMessage()
        }
        FireUtil.firebaseRef.observePrivateMessageTypingIndicator(userID1: UserID, userID2: OtherUserId) { (result) in
            if result {
                self.typingIndicator.isHidden = false
                self.onlineStatus.isHidden = true
            } else {
                self.typingIndicator.isHidden = true
                if self.isTargetUserOnline == "1" {
                    self.onlineStatus.isHidden = false
                } else {
                    self.onlineStatus.isHidden = true
                }
            }
        }
        FireUtil.firebaseRef.setChanelUserOnline(userID1: UserID, userID2: OtherUserId)
        FireUtil.firebaseRef.observeChanelUserOnineStatus(userID1: UserID, userID2: OtherUserId) { (result) in
            if result {
                self.isTargetUserOnline = "1"
                self.onlineStatus.isHidden = false
            } else {
                self.isTargetUserOnline = "0"
                self.onlineStatus.isHidden = true
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
    
    @IBAction func btnChooseImageOnClick(_ sender: UIButton) {
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
    
//MARK: - Open the camera
    func openCamera(){
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
//MARK: - Choose image from camera roll
    func openGallary(){
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
}

//MARK: - UIImagePickerControllerDelegate

extension PrivateMessageViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            Imagename = editedImage
            uploadImage.image = editedImage
            ImageStatus = "1"
            uploadImage.layer.masksToBounds = true
            uploadImage.layer.cornerRadius = uploadImage.bounds.width / 2
            picker.dismiss(animated: true) { [self] in
                FireUtil.firebaseRef.setChanelUserOnline(userID1: UserID, userID2: OtherUserId)
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.isNavigationBarHidden = false
            picker.dismiss(animated: true) { [self] in
                FireUtil.firebaseRef.setChanelUserOnline(userID1: UserID, userID2: OtherUserId)
            }
        }
    }
}

extension PrivateMessageViewController: GrowingTextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        if !isAlreadyTyping {
            FireUtil.firebaseRef.setTypeingIndicator(userID1: UserID, userID2: OtherUserId)
            isAlreadyTyping = true
        }
        let currentText: NSString = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with:text)

        if updatedText.isEmpty {
            FireUtil.firebaseRef.removePrivateMessageTypingIndicator(userID1: UserID, userID2: OtherUserId)
            isAlreadyTyping = false
            return false
        }
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        FireUtil.firebaseRef.removePrivateMessageTypingIndicator(userID1: UserID, userID2: OtherUserId)
        isAlreadyTyping = false
    }

}
