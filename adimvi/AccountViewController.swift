
//  AccountViewController.swift
//  adimvi
//  Created by javed carear  on 19/08/19.
//  Copyright © 2019 webdesky.com. All rights reserved.


import UIKit
import SwiftyJSON
import Alamofire
class AccountViewController:UIViewController {
    
    @IBOutlet weak var textfieldUserName: UITextField!
    @IBOutlet weak var textfieldLocation: UITextField!
    @IBOutlet weak var labelTextProfile: UILabel!
    @IBOutlet weak var labelTextCover: UILabel!
    @IBOutlet weak var labelTextAds: UILabel!
    @IBOutlet weak var imgCoverCircle: UIImageView!
    @IBOutlet weak var imgProfileCircle: UIImageView!
    @IBOutlet weak var imgAdsCircle: UIImageView!
    @IBOutlet weak var textviewAboutMe: UITextView!
    @IBOutlet weak var textfieldSocialNetwork: UITextField!
    @IBOutlet weak var textfieldLinkWebside: UITextField!
    @IBOutlet weak var textfieldPaypalEmail: UITextField!
    @IBOutlet weak var textfieldEmail: UITextField!
    @IBOutlet weak var textfieldFullName: UITextField!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var textfieldConfirmPwd: UITextField!
    @IBOutlet weak var textfieldnewPwd: UITextField!
    @IBOutlet weak var textfieldOldPwd: UITextField!
    @IBOutlet weak var htImageAdd: NSLayoutConstraint!
    @IBOutlet weak var BgProfile: UIImageView!
    @IBOutlet weak var Bbackgorund: UIImageView!
    @IBOutlet weak var userADImg: UIImageView!
    @IBOutlet weak var labelPosts: UILabel!
    @IBOutlet weak var labelPositiveVote: UILabel!
    @IBOutlet weak var labelReply: UILabel!
    @IBOutlet weak var labelFollowers: UILabel!
    @IBOutlet weak var labelFollowing: UILabel!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var buttonUnSelectedPrivateM: UIButton!
    @IBOutlet weak var buttonSelectedPrivateM: UIButton!
    @IBOutlet weak var buttonSelectedWall: UIButton!
    @IBOutlet weak var ButtonUnselectedWall: UIButton!
    @IBOutlet weak var buttonUnselectedEmail: UIButton!
    @IBOutlet weak var buttonSelectedEmail: UIButton!
    @IBOutlet weak var buttonUnselectedAds: UIButton!
    @IBOutlet weak var buttonSelectedAds: UIButton!
    @IBOutlet weak var edtUserADLink: UITextField!
    @IBOutlet weak var adUV: UIView!
    
    var ShareLink:String!
    var arrayEditPro = [[String: Any]]()
    var imagePicker = UIImagePickerController()
    var cam:String!
    var UserID:String!
    var arrayProfile = [[String: Any]]()
    
    var AllowPrivateMassage = "0"
    var AllowPostWall = "0"
    var EmailSendAllUsers = "0"
    var AllowUserAD = "0"
    var Profileimg:UIImage?
    var Coverimg:UIImage?
    var Adsimg:UIImage?
    var SelectProfile = ""
    var CoverImages = ""
    var UserADimages = ""
    @IBOutlet weak var backgroundImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        Profileimg = UIImage(named:"Place.png")
        Adsimg = UIImage(named:"Place.png")
        Coverimg = UIImage(named:"Place.png")
        
        UserID = UserDefaults.standard.string(forKey:"ID")
        CallWebserviceGetProfile()
        
        textfieldFullName.delegate = self
    }
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func OnPrivateMassage(_ sender: UIButton) {
        if sender.tag == 1{
            buttonSelectedPrivateM.isHidden = false
            buttonUnSelectedPrivateM.isHidden = true
            AllowPrivateMassage = "1"
        }
        if sender.tag == 2{
            buttonSelectedPrivateM.isHidden = true
            buttonUnSelectedPrivateM.isHidden = false
            AllowPrivateMassage = "0"
        }
    }
    
    @IBAction func OnWall(_ sender: UIButton) {
        if sender.tag == 1{
            buttonSelectedWall.isHidden = false
            ButtonUnselectedWall.isHidden = true
            AllowPostWall = "1"
        }
        if sender.tag == 2{
            buttonSelectedWall.isHidden = true
            ButtonUnselectedWall.isHidden = false
            AllowPostWall = "0"
        }
    }
    @IBAction func OnEmail(_ sender: UIButton) {
        if sender.tag == 1{
            buttonSelectedEmail.isHidden = false
            buttonUnselectedEmail.isHidden = true
            EmailSendAllUsers = "1"
        }
        if sender.tag == 2{
            buttonSelectedEmail.isHidden = true
            buttonUnselectedEmail.isHidden = false
            EmailSendAllUsers = "0"
        }
    }
    
    @IBAction func OnAds(_ sender: UIButton) {
        if sender.tag == 1{
            buttonSelectedAds.isHidden = false
            buttonUnselectedAds.isHidden = true
            AllowUserAD = "1"
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.htImageAdd.constant = 92
                self.adUV.isHidden = false
                self.view.layoutIfNeeded()
            })
        }
        if sender.tag == 2{
            buttonSelectedAds.isHidden = true
            buttonUnselectedAds.isHidden = false
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.htImageAdd.constant = 0
                self.adUV.isHidden = true
                self.view.layoutIfNeeded()
            })
            AllowUserAD = "0"
        }
        
    }
    
    func OnProfie()  {
        let data = self.arrayProfile[0]
        if let Username = data["username"]as? String{
            self.textfieldFullName.text = Username
        }
        if let Username = data["username"]as? String{
            self.labelUserName.text = Username
        }
        
        if let Email = data["email"]as? String{
            self.textfieldEmail.text = Email
        }
        if let PayPal = data["paypal"]as? String{
            self.textfieldPaypalEmail.text = PayPal
        }
        
        if let SocialNet = data["social-networks"]as? String{
            self.textfieldSocialNetwork.text = SocialNet
        }
        if let webside = data["website"]as? String{
            self.textfieldLinkWebside.text = webside
            ShareLink = webside
        }
        if let AboutMe = data["about"]as? String{
            self.textviewAboutMe.text = AboutMe
        }
        if let AboutMe = data["location"]as? String{
            self.textfieldLocation.text = AboutMe
        }
        if let Name = data["name"]as? String{
            self.textfieldUserName.text = Name
        }
        
        if let Post = data["totalPost"]as? String{
            self.labelPosts.text = Post
        }
        if let Votes = data["positiveVotes"]as? String{
            self.labelPositiveVote.text = Votes
        }
        if let Replies = data["totalReply"]as? String{
            self.labelReply.text = Replies
        }
        if let Followers = data["totalFollowers"]as? String{
            self.labelFollowers.text = Followers
        }
        if let Following = data["totalFollowing"]as? String{
            self.labelFollowing.text = Following
        }
        if  let profilePic = data["avatarblobid"] as? String, !profilePic.isEmpty{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            self.imgProfilePic.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named:""))
            self.BgProfile.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: ""))
        }
        
        if  let profilePic = data["coverblobid"] as? String, !profilePic.isEmpty{
            let imageURl = "\(WebURL.ImageUrl)\(profilePic)"
            self.backgroundImage.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: ""))
            self.Bbackgorund.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: ""))
        }
        
        if let userAD = data["fadSense"] as? String {
            if userAD == "1" {
                buttonSelectedAds.isHidden = false
                buttonUnselectedAds.isHidden = true
                htImageAdd.constant = 92
                adUV.isHidden = false
                AllowUserAD = "1"
            } else {
                buttonSelectedAds.isHidden = true
                buttonUnselectedAds.isHidden = false
                htImageAdd.constant = 0
                adUV.isHidden = true
                AllowUserAD = "0"
            }
        }
        
        if let userAD = data["uadblobid"] as? String, !userAD.isEmpty {
            let imageURl = "\(WebURL.ImageUrl)\(userAD)"
            self.userADImg.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: ""))
        }
        
        if let userADLink = data["uadimageurl"] as? String {
            edtUserADLink.text = userADLink
        }
        
        if let flags = data["flags"] as? String {
            if flags == "4" || flags == "0" || flags == "5"{
                buttonSelectedPrivateM.isHidden = false
                buttonUnSelectedPrivateM.isHidden = true
                buttonSelectedWall.isHidden = false
                ButtonUnselectedWall.isHidden = true
                AllowPostWall = "1"
                AllowPrivateMassage = "1"
            } else if flags == "20" || flags == "16" || flags == "21"{
                buttonSelectedPrivateM.isHidden = true
                buttonUnSelectedPrivateM.isHidden = false
                buttonSelectedWall.isHidden = false
                ButtonUnselectedWall.isHidden = true
                AllowPostWall = "1"
                AllowPrivateMassage = "0"
            } else if flags == "260" || flags == "256" || flags == "261"{
                buttonSelectedPrivateM.isHidden = false
                buttonUnSelectedPrivateM.isHidden = true
                buttonSelectedWall.isHidden = true
                ButtonUnselectedWall.isHidden = false
                AllowPostWall = "0"
                AllowPrivateMassage = "1"
            } else if flags == "276" || flags == "272" || flags == "277"{
                buttonSelectedPrivateM.isHidden = true
                buttonUnSelectedPrivateM.isHidden = false
                buttonSelectedWall.isHidden = true
                ButtonUnselectedWall.isHidden = false
                AllowPostWall = "0"
                AllowPrivateMassage = "0"
            }
        } else {
            buttonSelectedPrivateM.isHidden = true
            buttonUnSelectedPrivateM.isHidden = false
            buttonSelectedWall.isHidden = true
            ButtonUnselectedWall.isHidden = false
            AllowPostWall = "0"
            AllowPrivateMassage = "0"
        }
        
    }
    
    @IBAction func OnLink(_ sender: Any) {
        let vc:WebviewTabController = self.storyboard?.instantiateViewController(withIdentifier: "WebviewTabController") as! WebviewTabController
        vc.UrlLink  = "\(ShareLink!)"
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func OnProfile(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func OnSaveProfile(_ sender: Any) {
        UpdateProfile()
    }
    
    @IBAction func btnChooseImageOnClick(_ sender: UIButton) {
        if sender.tag == 1{
            cam = "1"
        }
        if sender.tag == 2{
            cam = "2"
        }
        if sender.tag == 3{
            cam = "3"
        }
        
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
            //If you dont want to edit the photo then you can set allowsEditing to false
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        else{
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
    
    
    @IBAction func OnChangePwd(_ sender: Any) {
        let newPwd = textfieldnewPwd.text
        let OldPwd = textfieldOldPwd.text
        let ConPwd = textfieldConfirmPwd.text
        
        if (OldPwd!.isEmpty) {
            self.showAlert(strMessage: "Por favor, introduce tu contraseña anterior.")
            return
        }
        if (newPwd!.isEmpty) {
            self.showAlert(strMessage: "Por favor, introduce tu nueva contraseña.")
            return
        }
        
        if (ConPwd!.isEmpty) {
            self.showAlert(strMessage:
                            "Por favor, repite la nueva contraseña.")
            return
        }
        
        CallWebserviceChangePwd()
        
    }
}

//MARK: - UIImagePickerControllerDelegate

extension AccountViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            if cam == "1"{
                self.imgProfilePic.image = editedImage
                self.BgProfile.image = editedImage
                Profileimg = editedImage
                self.SelectProfile = "Profile.png"
                labelTextProfile.text = "Imagen seleccionada"
            }
            
            if cam == "2"{
                self.backgroundImage.image = editedImage
                self.Bbackgorund.image = editedImage
                Coverimg = editedImage
                self.CoverImages = "Cover.png"
                labelTextCover.text = "Imagen seleccionada"
            }
            
            if cam == "3"{
//                imgAdsCircle.image = #imageLiteral(resourceName: "FillCircle")
                labelTextAds.text = "Imagen seleccionada"
                self.userADImg.image = editedImage
                Adsimg = editedImage
                self.UserADimages = "adsImage"
            }
        }
        
        //Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func CallWebserviceChangePwd(){
        let Para =
            ["user_id":"\(UserID!)","oldPass":"\(textfieldOldPwd.text!)","newPass":"\(textfieldnewPwd.text!)","confirmPass":"\(textfieldConfirmPwd.text!)",
            ] as [String : Any]
        
        let myService:String = "\(WebURL.BaseUrl)\(WebURL.changePassword)"
        objActivity.startActivityIndicator()
        Alamofire.request(myService, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if (myData["response"] as? [String:Any]) != nil{
                        }
                        objActivity.stopActivity()
                        DispatchQueue.main.async {
                            
                        }
                        let actionSheetController: UIAlertController = UIAlertController(title: "Contraseña", message: "Tu contraseña se ha cambiado correctamente.", preferredStyle: .alert)
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel) { action -> Void in
                        }
                        actionSheetController.addAction(cancelAction)
                        self.present(actionSheetController, animated: true, completion: nil)
                    }
                    objActivity.stopActivity()
                    break
                case .failure(_):
                    print(response.result.error as Any)
                    break
                }
            }
    }
    
    //Multipart Image
    func UpdateProfile(){
        let Profile: NSData = Profileimg!.pngData()! as NSData
        let Cover: NSData = Coverimg!.pngData()! as NSData
        let Ads: NSData = Adsimg!.pngData()! as NSData
        
        let Para =
            ["user_id":"\(UserID!)","email":"\(textfieldEmail.text!)","full_name":"\(textfieldFullName.text!)","paypal":"\(textfieldPaypalEmail.text!)",
             "about_me":"\(textviewAboutMe.text!)",
             "location":"\(textfieldLocation.text!)",
             "links_websites":"\(textfieldLinkWebside.text!)",
             "social_networks":"\(textfieldSocialNetwork.text!)",
             "handle":"\(textfieldFullName.text!)",
             "publications_wall":"\(AllowPostWall)",
             "private_messages":"\(AllowPrivateMassage)",
             "subscribe_email":"\(EmailSendAllUsers)",
             "fadsense":"\(AllowUserAD)",
             "full_name1":"\(textfieldUserName.text!)",
             "uadimageurl":"www.google.com",
             "coverImage":"\(Cover)",
             "adsImage":"\(Ads)"
             
            ] as [String : Any]
        print(Para)
        UserDefaults.standard.setValue(AllowUserAD, forKey: "USERAD")
        requestWith(videoData: Profile as Data,parameters: Para, onCompletion: { (response) in
            
        })
        
        requestCover(videoData: Cover as Data, parameters: Para, onCompletion: { (response) in
            
        })
        
        requestUserAD(videoData: Ads as Data, parameters: Para, onCompletion: {(response) in
            
        })
        
        
        { (error) in
            
        }
    }
    
    
    
    //Mark:- Upload video with multipart
    func requestWith(videoData: Data?, parameters: [String : Any], onCompletion: ((JSON?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
        objActivity.startActivityIndicator()
        let url = "\(WebURL.BaseUrl)\(WebURL.editProfile)"
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if let data = videoData{
                multipartFormData.append(data,withName:"profileImage", fileName: "\(self.SelectProfile)", mimeType: "image/png")
                
            }
            
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: nil) { (result) in
            
            switch result {
            
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    
                    if let err = response.error{
                        onError?(err)
                        return
                    }
                    objActivity.stopActivity()
                    debugPrint(response.result.value!)
                    onCompletion?(nil)
                    self.showAlert(title: "Perfil actualizado", strMessage: "¡Tu datos se han guardado!")
                    
                }
                
                objActivity.stopActivity()
            case .failure(let error):
                objActivity.stopActivity()
                print("Error in upload: \(error.localizedDescription)")
                onError?(error)
            }
        }
    }
    
    
    //Mark:- Upload Cover with multipart
    func requestCover(videoData: Data?, parameters: [String : Any], onCompletion: ((JSON?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
        objActivity.startActivityIndicator()
        let url = "\(WebURL.BaseUrl)\(WebURL.editProfile)"
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if let data = videoData{
                multipartFormData.append(data,withName:"coverImage", fileName: "\(self.CoverImages)", mimeType: "image/png")
                
                //  multipartFormData.append(data,withName:"profileImage", fileName: "Profile.png", mimeType: "image/png")
            }
            
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: nil) { (result) in
            
            switch result {
            
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    
                    if let err = response.error{
                        onError?(err)
                        return
                    }
                    objActivity.stopActivity()
                    debugPrint(response.result.value!)
                    onCompletion?(nil)
                    self.showAlert(title: "Perfil actualizado", strMessage: "¡Tu datos se han guardado!")
                    
                }
                
                objActivity.stopActivity()
            case .failure(let error):
                objActivity.stopActivity()
                print("Error in upload: \(error.localizedDescription)")
                onError?(error)
            }
        }
    }
    
    func requestUserAD(videoData: Data?, parameters: [String : Any], onCompletion: ((JSON?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
        objActivity.startActivityIndicator()
        let url = "\(WebURL.BaseUrl)\(WebURL.editProfile)"
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if let data = videoData{
                multipartFormData.append(data,withName:"adsImage", fileName: "\(self.UserADimages)", mimeType: "image/png")
                
                //  multipartFormData.append(data,withName:"profileImage", fileName: "Profile.png", mimeType: "image/png")
            }
            
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: nil) { (result) in
            
            switch result {
            
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    
                    if let err = response.error{
                        onError?(err)
                        return
                    }
                    objActivity.stopActivity()
                    debugPrint(response.result.value!)
                    onCompletion?(nil)
                    self.showAlert(title: "Perfil actualizado", strMessage: "¡Tu datos se han guardado!")
                    
                }
                
                objActivity.stopActivity()
            case .failure(let error):
                objActivity.stopActivity()
                print("Error in upload: \(error.localizedDescription)")
                onError?(error)
            }
        }
    }
    
    
    
    
    
    func showAlert(title: String = "Mensaje", strMessage:String) ->() {
        let actionSheetController: UIAlertController = UIAlertController(title: title, message: strMessage, preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func CallWebserviceGetProfile(){
        let Para =
            ["userid":"\(UserID!)","login_userid":"\(UserID!)"
            ] as [String : Any]
        
        print(Para)
        let myService:String = "\(WebURL.BaseUrl)\(WebURL.getProfile)"
        
        objActivity.startActivityIndicator()
        Alamofire.request(myService, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [[String:Any]]{
                            self.arrayProfile = arr
                            
                            self.OnProfie()
                            
                        }
                        
                        
                        objActivity.stopActivity()
                        DispatchQueue.main.async {
                            
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

extension AccountViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == textfieldFullName {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else {return false}
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count < 16
        }
        return true
    }
}
