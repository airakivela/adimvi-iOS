
//  TOPostVC.swift
//  adimvi
//  Created by javed carear  on 20/06/19.
//  Copyright © 2019 webdesky.com. All rights reserved.

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import GrowingTextView

class ToPostVC: BaseViewController,UITextFieldDelegate {
    @IBOutlet weak var imageLogo: UIImageView!
    @IBOutlet weak var categoriesView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var htMainView: NSLayoutConstraint!
    @IBOutlet weak var htPromotionImage: NSLayoutConstraint!
    @IBOutlet weak var uploadImage: UIImageView!
    @IBOutlet weak var buttonUncheckEliminate: UIButton!
    @IBOutlet weak var buttonCheckEliminate: UIButton!
    @IBOutlet weak var buttonUnchekintroduce: UIButton!
    @IBOutlet weak var buttoncheckintroduce: UIButton!
    @IBOutlet weak var buttonUncheckNotify: UIButton!
    @IBOutlet weak var buttonCheckNotify: UIButton!
    
    @IBOutlet weak var buttonUncheckCondition: UIButton!
    @IBOutlet weak var buttonCheckCondition: UIButton!
    @IBOutlet weak var labelemailAddress: UILabel!
    @IBOutlet weak var htTopImageView: NSLayoutConstraint!
    
    @IBOutlet weak var textfieldTitleOfPublication: GrowingTextView!
    @IBOutlet weak var buttonFree: UIButton!
    @IBOutlet weak var htPublication: NSLayoutConstraint!
    @IBOutlet weak var buttonPayment: UIButton!
    @IBOutlet weak var buttonIntroduceMyPromotion: UIButton!
    @IBOutlet weak var textfieldTeg: GrowingTextView!
    @IBOutlet weak var paymentView: UIView!
    @IBOutlet weak var buttonVideo: DesignableButton!
    @IBOutlet weak var buttonImage: DesignableButton!
    @IBOutlet weak var textfieldCatgories:UITextField!
    @IBOutlet weak var htTitle: NSLayoutConstraint!
    @IBOutlet weak var imgData: UIImageView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var textfieldPostPrice: UITextField!
    @IBOutlet weak var textfieldvideoUrl: UITextField!
    @IBOutlet weak var labelUserPoints: UILabel!
    @IBOutlet weak var tableDraftList: UITableView!
    @IBOutlet weak var labelDraftName: UILabel!
    @IBOutlet weak var htTableDrafts: NSLayoutConstraint!
    @IBOutlet weak var richEditorUV: UIView!
    
    @IBOutlet weak var leftAlignUB: UIButton!
    @IBOutlet weak var rightAlignUB: UIButton!
    @IBOutlet weak var centerAlignUB: UIButton!
    @IBOutlet weak var htPostContent: NSLayoutConstraint!
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = [RichEditorDefaultOption.done]
        return toolbar
    }()
    
    
    let textviewPostContent: RichEditorView = {
        let richEditor = RichEditorView()
        richEditor.placeholder = "Empieza a escribir aquí"
        richEditor.editingEnabled = true
        return richEditor
    }()
    
    var isImaggeforContent: Bool = false
    
    var arrayCaregories =  [[String: Any]]()
    var arrayDraft =  [String: Any]()
    var arrayDraftList =  [[String: Any]]()
    var CategoriesName:String!
    var imagePicker = UIImagePickerController()
    var PostImages = [String]()
    var Catgoriesid:String!
    
    var Imagename:UIImage!
    var DraftImage:String!
    var uploadImages = [String]()
    var UserID:String!
    var UploadType:String!
    var UploadTypeDraftList:String?
    var PointsStatus:String!
    var PromotionImageStatus:String!
    var Postid:String!
    var userad = "0"
    var adimviad = "0"
    var type = "publish"
    var DraftType = "draft_edit"
    var Notify = "0"
    var termsCondition = "0"
    var DraftPostId:String!
    var DraftStatus:String!
    var UpdatePost:String!
    var UpdatePostType:String!
    var SelectCatId:String!
    
    @IBOutlet weak var htTextview: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolbar.delegate = self
        toolbar.editor = textviewPostContent
        toolbar.editor?.isScrollEnabled = false
        textviewPostContent.inputAccessoryView = toolbar
        textviewPostContent.delegate = self
        textviewPostContent.translatesAutoresizingMaskIntoConstraints = false
        self.richEditorUV.addSubview(textviewPostContent)
        textviewPostContent.topAnchor.constraint(equalTo: self.richEditorUV.topAnchor).isActive = true
        textviewPostContent.bottomAnchor.constraint(equalTo: self.richEditorUV.bottomAnchor).isActive = true
        textviewPostContent.rightAnchor.constraint(equalTo: self.richEditorUV.rightAnchor).isActive = true
        textviewPostContent.leftAnchor.constraint(equalTo: self.richEditorUV.leftAnchor).isActive = true
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.darkGray]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        UserID = UserDefaults.standard.string(forKey: "ID")
        CallWebserviceDraft()
        htPublication.constant = 50
        CallWebserviceCategoriesList()
        textfieldCatgories.delegate = self
        if let pointstatus =  SharedManager.sharedInstance.dictUserInfo()["point_status"] as? String{
            PointsStatus = pointstatus
            
        }
        if UpdatePost == "1"{
            DraftPostId = Postid
            UpdatePostType = "publish"
            DraftType = "publish_edit"
            CallWebserviceDraftDetail()
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
        
//        textfieldTitleOfPublication.sizeToFit()
//        textfieldTitleOfPublication.delegate = self
//        textfieldTitleOfPublication.text = ""
//        textfieldTitleOfPublication.textColor = UIColor.lightGray
//        textfieldTitleOfPublication.selectedTextRange = textfieldTitleOfPublication.textRange(from: textfieldTitleOfPublication.beginningOfDocument, to: textfieldTitleOfPublication.beginningOfDocument)
        
//        textfieldTeg.sizeToFit()
//        textfieldTeg.delegate = self
//        textfieldTeg.text = "Etiquetas: utiliza # al comienzo de cada etiqueta"
//        textfieldTeg.textColor = UIColor.lightGray
//        textfieldTeg.selectedTextRange = textfieldTeg.textRange(from: textfieldTeg.beginningOfDocument, to: textfieldTeg.beginningOfDocument)
        
        
    }
    
    @IBAction func onTapBoldUB(_ sender: UIButton) {
        if sender.backgroundColor != UIColor(named: "lighter_gray") {
            sender.backgroundColor = UIColor(named: "lighter_gray")
        } else {
            sender.backgroundColor = .clear
        }
        toolbar.editor?.bold()
    }
    
    
    @IBAction func onTapItalicUB(_ sender: UIButton) {
        if sender.backgroundColor != UIColor(named: "lighter_gray") {
            sender.backgroundColor = UIColor(named: "lighter_gray")
        } else {
            sender.backgroundColor = .clear
        }
        toolbar.editor?.italic()
    }
    
    @IBAction func onTapUnderlineUB(_ sender: UIButton) {
        if sender.backgroundColor != UIColor(named: "lighter_gray") {
            sender.backgroundColor = UIColor(named: "lighter_gray")
        } else {
            sender.backgroundColor = .clear
        }
        toolbar.editor?.underline()
    }
    
    @IBAction func onTapLeftAlignUB(_ sender: UIButton) {
        sender.backgroundColor = UIColor(named: "lighter_gray")
        centerAlignUB.backgroundColor = .clear
        rightAlignUB.backgroundColor = .clear
        toolbar.editor?.alignLeft()
    }
    
    @IBAction func onTapCenterAlignUB(_ sender: UIButton) {
        sender.backgroundColor = UIColor(named: "lighter_gray")
        leftAlignUB.backgroundColor = .clear
        rightAlignUB.backgroundColor = .clear
        toolbar.editor?.alignCenter()
    }
    
    @IBAction func onTapRightAlignUB(_ sender: UIButton) {
        sender.backgroundColor = UIColor(named: "lighter_gray")
        centerAlignUB.backgroundColor = .clear
        leftAlignUB.backgroundColor = .clear
        toolbar.editor?.alignRight()
    }
    
    @IBAction func onTapCameraUB(_ sender: Any) {
        isImaggeforContent = true
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
    
    @IBAction func OnLinkTermsAndCondition(_ sender: Any) {
        let vc:WebviewTabController = self.storyboard?.instantiateViewController(withIdentifier: "WebviewTabController") as! WebviewTabController
        vc.UrlLink  = "https://www.adimvi.com/appAPI/index.php/front/terms"
        vc.Title = "Información"
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func OnSaveDrafts(_ sender: Any) {
        type = "draft"
        if UploadTypeDraftList != nil {
            DraftType = "draft_update"
            if UploadType == "1"{
                UploadingImageInDraft()
            }
            if UploadType == "2"{
                WebserviceUploadVideoInDraftPost()
            }
        } else {
            if UploadType == "1"{
                UploadingImage()
            }
            if UploadType == "2"{
                WebserviceUploadVideo()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func OnEliminateAdmin(_ sender: UIButton) {
        if sender.tag == 1 && PointsStatus == "1" {
            buttonCheckEliminate.isHidden = false
            buttonUncheckEliminate.isHidden = true
            adimviad = "1"
        }
        if sender.tag == 2 && PointsStatus == "1"{
            buttonCheckEliminate.isHidden = true
            buttonUncheckEliminate.isHidden = false
            adimviad = "0"
        }
    }
    
    @IBAction func Onintroduce(_ sender: UIButton) {
        if let isEditableUserAD = UserDefaults.standard.value(forKey: "USERAD") as? String {
            if isEditableUserAD == "0" {
                return
            }
        }
        if sender.tag == 1 {
            buttoncheckintroduce.isHidden = false
            buttonUnchekintroduce.isHidden = true
            userad = "1"
            buttonCheckEliminate.isHidden = false
            buttonUncheckEliminate.isHidden = true
            adimviad = "1"
        }
        if sender.tag == 2 {
            buttoncheckintroduce.isHidden = true
            buttonUnchekintroduce.isHidden = false
            userad = "0"
        }
    }
    
    @IBAction func OnNotify(_ sender: UIButton) {
        if sender.tag == 1{
            buttonCheckNotify.isHidden = false
            buttonUncheckNotify.isHidden = true
            Notify = "1"
        }
        if sender.tag == 2{
            buttonCheckNotify.isHidden = true
            buttonUncheckNotify.isHidden = false
            Notify = "0"
        }
    }
    
    @IBAction func OntermsAndCondition(_ sender: UIButton) {
        if sender.tag == 1{
            buttonCheckCondition.isHidden = false
            buttonUncheckCondition.isHidden = true
            termsCondition = "1"
        }
        if sender.tag == 2{
            buttonCheckCondition.isHidden = true
            buttonUncheckCondition.isHidden = false
            termsCondition = "0"
        }
    }
    
    @IBAction func OnPayment(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.htPublication.constant = 100
            self.view.layoutIfNeeded()
        })
        paymentView.isHidden = false
        buttonPayment.setImage(#imageLiteral(resourceName: "imgRadioSelected"), for: UIControl.State.normal)
        buttonFree.setImage(#imageLiteral(resourceName: "imgRadioNormal"), for: UIControl.State.normal)
    }
    
    @IBAction func OnFree(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.htPublication.constant = 50
            self.view.layoutIfNeeded()
        })
        paymentView.isHidden = true
        buttonPayment.setImage(#imageLiteral(resourceName: "imgRadioNormal"), for: UIControl.State.normal)
        buttonFree.setImage(#imageLiteral(resourceName: "imgRadioSelected"), for: UIControl.State.normal)
        textfieldPostPrice.text = "0"
    }
    
    @IBAction func OnVideo(_ sender: Any) {
        buttonVideo.backgroundColor = UIColor.init(named: "Light grey (Dark mode)")
        buttonImage.backgroundColor = UIColor.init(named: "White (dark mode)")
        buttonImage.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
        buttonVideo.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        videoView.isHidden = false
        imageView.isHidden = true
        UploadType = "2"
        htTopImageView.constant = 5
        self.htPublication.constant = 50
        paymentView.isHidden = true
        buttonPayment.setImage(#imageLiteral(resourceName: "imgRadioNormal"), for: UIControl.State.normal)
        buttonFree.setImage(#imageLiteral(resourceName: "imgRadioSelected"), for: UIControl.State.normal)
    }
    
    @IBAction func OnPost(_ sender: Any) {
        let title = textfieldTitleOfPublication.text!
        let Tag = textfieldTeg.text!
        if (title.isEmpty) {
            self.showNormalAlert(strMessage: "Introduce el título de tu post")
            return
        }
        if textviewPostContent.contentHTML.isEmpty {
            self.showNormalAlert(strMessage: "Tu comentario se ha añadido.")
            return
        }
        if (Tag.isEmpty) {
            self.showNormalAlert(strMessage: "Por favor, introduce  etiquetas en tu post.")
            return
        }
        if termsCondition == "0"{
            self.showNormalAlert(strMessage: "Por favor, lee y verifica los términos y condiciones")
            return
        }
        type = "publish"
        if UploadTypeDraftList != nil {
            DraftType = "publish_edit"
            if UploadType == "1"{
                UploadingImageInDraft()
            }
            if UploadType == "2"{
                WebserviceUploadVideoInDraftPost()
            }
        } else {
            if UploadType == "1"{
                UploadingImage()
            }
            if UploadType == "2"{
                WebserviceUploadVideo()
            }
        }
    }
    
    @IBAction func onTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func CallWebserviceCategoriesList(){
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.categoryList)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method:.post,parameters:nil)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["categories"]as? [[String:Any]]{
                                self.arrayCaregories = Data
                                _  = self.arrayCaregories[0]
                                for ArrayData in self.arrayCaregories{
                                    let CatName = ArrayData["categoryName"] as! String
                                    self.PostImages.append(CatName)
                                }
                            }
                        }
                        objActivity.stopActivity()
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
    
    func CallWebserviceDraftDetail(){
        let Para = ["postid":"\(Postid!)","type":"\(UpdatePostType!)"] as [String : Any]
        print(Para)
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.draftPostDetail)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["response"] as? [String:Any]{
                            if let Data = arr["drafPost"]as? [String:Any]{
                                self.arrayDraft = Data
                                if let title = self.arrayDraft["post_title"] as? String {
                                    self.textfieldTitleOfPublication.text = title
                                }
                                if let Categories = self.arrayDraft["category_name"] as? String {
                                    self.textfieldCatgories.text = Categories
                                }
                                if let Categories = self.arrayDraft["categoryid"] as? String {
                                    self.Catgoriesid = "\(Categories)"
                                }
                                if let Price = self.arrayDraft["price"] as? String {
                                    self.textfieldPostPrice.text = Price
                                }
                                if let Type = self.arrayDraft["file_type"] as? String {
                                    self.UploadTypeDraftList = Type
                                    if Type == "Video"{
                                        self.htTopImageView.constant = 8
                                        if  let PostImage = self.arrayDraft["post_image"] as? String{
                                            self.uploadImage.sd_setImage(with: URL(string: PostImage))
                                            self.imageLogo.isHidden = false
                                        }
                                        if let VideoUrl = self.arrayDraft["post_image"] as? String {
                                            self.textfieldvideoUrl.text =  " \(VideoUrl)"
                                        }
                                        self.buttonVideo.backgroundColor = UIColor.init(named: "Light grey (Dark mode)")
                                        self.buttonImage.backgroundColor = UIColor.init(named: "White (dark mode)")
                                        self.videoView.isHidden = false
                                        self.imageView.isHidden = true
                                        self.UploadType = "2"
                                    } else {
                                        self.htTopImageView.constant = -40
                                        self.buttonVideo.backgroundColor = UIColor.init(named: "White (dark mode)")
                                        self.buttonImage.backgroundColor = UIColor.init(named: "Light grey (Dark mode)")
                                        self.videoView.isHidden = true
                                        self.imageView.isHidden = false
                                        self.UploadType = "1"
                                        if  let PostImage = self.arrayDraft["post_image"] as? String{
                                            self.uploadImage.sd_setImage(with: URL(string: PostImage))
                                            self.imageLogo.isHidden = true
                                        }
                                    }
                                }
                                let Pricer = self.arrayDraft["pricer"] as! String
                                if Pricer == "1"{
                                    self.htPublication.constant = 100
                                    self.paymentView.isHidden = false
                                    self.buttonPayment.setImage(#imageLiteral(resourceName: "imgRadioSelected"), for: UIControl.State.normal)
                                    self.buttonFree.setImage(#imageLiteral(resourceName: "imgRadioNormal"), for: UIControl.State.normal)
                                    
                                    
                                } else {
                                    self.htPublication.constant = 50
                                    self.paymentView.isHidden = true
                                    self.buttonPayment.setImage(#imageLiteral(resourceName: "imgRadioNormal"), for: UIControl.State.normal)
                                    self.buttonFree.setImage(#imageLiteral(resourceName: "imgRadioSelected"), for: UIControl.State.normal)
                                }
                                let notification = self.arrayDraft["notify"] as! String
                                if notification == "1"{
                                    self.buttonCheckNotify.isHidden = false
                                    self.buttonUncheckNotify.isHidden = true
                                    self.Notify = "1"
                                } else {
                                    self.buttonCheckNotify.isHidden = true
                                    self.buttonUncheckNotify.isHidden = false
                                    self.Notify = "0"
                                }
                                let Promotion = self.arrayDraft["promotional_image"] as! String
                                if Promotion == "1"{
                                    self.buttoncheckintroduce.isHidden = false
                                    self.buttonUnchekintroduce.isHidden = true
                                    self.userad = "1"
                                } else {
                                    self.buttoncheckintroduce.isHidden = true
                                    self.buttonUnchekintroduce.isHidden = false
                                    self.userad = "0"
                                }
                                let UserPoint = self.arrayDraft["adimvi_promotions"] as! String
                                if UserPoint == "1"{
                                    self.buttonCheckEliminate.isHidden = false
                                    self.buttonUncheckEliminate.isHidden = true
                                    self.adimviad = "1"
                                } else {
                                    self.buttonCheckEliminate.isHidden = true
                                    self.buttonUncheckEliminate.isHidden = false
                                    self.adimviad = "0"
                                }
                                if let PostContent = self.arrayDraft["post_description"] as? String {
                                    self.textviewPostContent.html = PostContent
                                }
                                if let tag = self.arrayDraft["tags"] as? String {
                                    self.textfieldTeg.text = tag
                                }
                            }
                        }
                        objActivity.stopActivity()
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
    
    @IBAction func OnImage(_ sender: Any) {
        buttonVideo.backgroundColor = UIColor.init(named: "White (dark mode)")
        buttonImage.backgroundColor = UIColor.init(named: "Light grey (Dark mode)")
        buttonImage.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        buttonVideo.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
        videoView.isHidden = true
        imageView.isHidden = false
        htTopImageView.constant = -40
        self.htPublication.constant = 50
        paymentView.isHidden = true
        buttonPayment.setImage(#imageLiteral(resourceName: "imgRadioNormal"), for: UIControl.State.normal)
        buttonFree.setImage(#imageLiteral(resourceName: "imgRadioSelected"), for: UIControl.State.normal)
    }
    
    @IBAction func btnChooseImageOnClick(_ sender: UIButton) {
        UploadType = "1"
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
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Choose image from camera roll
    
    func openGallary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
}

//MARK: - UIImagePickerControllerDelegate

extension ToPostVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            if isImaggeforContent {
                picker.dismiss(animated: true) {
                    self.uploadContentImage(image: editedImage)
                }
            } else {
                Imagename = editedImage
                uploadImage.image = editedImage
                imageLogo.isHidden = true
                picker.dismiss(animated: true, completion: nil)
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.isNavigationBarHidden = false
            self.dismiss(animated: true, completion: nil)
        }
    }
    /// upload content Image ///
    func uploadContentImage(image: UIImage) {
        objActivity.startActivityIndicator()
        let imageData: NSData = image.pngData()! as NSData
        let url = "https://www.adimvi.com/appAPI/index.php/api/uploadPostContentImage"
        Alamofire.upload(multipartFormData: { (data) in
            data.append(imageData as Data, withName: "imageUrl", fileName: "postData.png", mimeType: "image/png")
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: nil) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { (response) in
                    if response.error != nil {
                        return
                    }
                    let myData = response.result.value as! [String :Any]
                    self.isImaggeforContent = false
                    objActivity.stopActivity()
                    if let url = myData["url"] as? String {
                        self.toolbar.editor?.insertImage(url, alt: "Image")
                    }
                }
                break
            case .failure(_):
                objActivity.stopActivity()
                break
            }
        }
    }
    
    //Multipart Image
    func UploadingImage(){
        let tags: String = textfieldTeg.text!
        let tagArr = tags.replacingOccurrences(of: " ", with: ",")
        objActivity.startActivityIndicator()
        let imageData: NSData = uploadImage.image!.pngData()! as NSData
        //PostImages.append(imageData)
        let Para: [String: Any] = [
            "userid":"\(UserID!)",
            "title":"\(textfieldTitleOfPublication.text!)",
            "categoryid":"\(Catgoriesid!)",
            "tags":"\(tagArr)",
            "description":"\(textviewPostContent.contentHTML)",
            "notify":"\(Notify)",
            "adimviad":"\(adimviad)",
            "userad":"\(userad)",
            "price":"\(textfieldPostPrice.text!)",
            "type":"\(type)"
        ]
        requestWith(videoData: imageData as Data, parameters: Para, onCompletion: { (response) in
            
        }) { (error) in
            
        }
    }
    
    //Mark:- Upload video with multipart
    func requestWith(videoData: Data?, parameters: [String : Any], onCompletion: ((JSON?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
        let url = "https://www.adimvi.com/appAPI/index.php/api/addNewPost"
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if let data = videoData{
                multipartFormData.append(data,withName:"imageUrl[]", fileName:"postData.png",mimeType:"image/png")
            }
            
        }, usingThreshold: UInt64.init(), to: url, method:.post, headers: nil) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let err = response.error{
                        onError?(err)
                        return
                    }
                    debugPrint(response.result.value!)
                    onCompletion?(nil)
                    let myData = response.result.value as! [String :Any]
                    var newPostID = ""
                    if let postID = myData["postID"] as? Int {
                        newPostID = "\(postID)"
                    }
                    if self.type != "publish" {
                        self.showNormalAlert(strMessage: "Publicacion guardada en borrador.")
                    } else {
                        self.showAlert(strMessage: "¡Tu publicación se ha subido con éxito! Ve y échale un vistazo.", postID: "\(newPostID)")
                    }
                    objActivity.stopActivity()
                    self.textfieldTeg.text = ""
                    self.textfieldTitleOfPublication.text = ""
                    self.textviewPostContent.html = ""
                    self.htPostContent.constant = 320
                    self.uploadImage.image =  UIImage(named:"")
                    self.imageLogo.isHidden = false
                    self.textfieldCatgories.text = ""
                    self.CallWebserviceDraft()
                }
                
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                onError?(error)
            }
        }
    }
    
    
    //Publish Image Post in Draft List
    func UploadingImageInDraft(){
        let tags: String = textfieldTeg.text!
        let tagArr = tags.replacingOccurrences(of: " ", with: ",")
        let imageData: NSData = uploadImage.image!.pngData()! as NSData
        let Para: [String: Any] = [
            "userid":"\(UserID!)",
            "title":"\(textfieldTitleOfPublication.text!)",
            "categoryid":"\(Catgoriesid!)",
            "tags":"\(tagArr)",
            "description":"\(textviewPostContent.contentHTML)",
            "notify":"\(Notify)",
            "adimviad":"\(adimviad)",
            "userad":"\(userad)",
            "price":"\(textfieldPostPrice.text!)",
            "type":"\(DraftType)",
            "postid":"\(DraftPostId!)"
        ]
        print(Para)
        
        requestDraft(videoData:imageData as Data,parameters: Para, onCompletion: { (response) in
            
        }) { (error) in
            
        }
    }
    
    //Mark:- Upload video with multipart
    func requestDraft(videoData: Data?, parameters: [String : Any], onCompletion: ((JSON?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
        let url = "https://www.adimvi.com/appAPI/index.php/api/updatePost"
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if let data = videoData{
                multipartFormData.append(data,withName:"imageUrl[]", fileName:"Post.png",mimeType:"image/png")
            }
            
        }, usingThreshold: UInt64.init(), to: url, method:.post, headers: nil) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let err = response.error{
                        onError?(err)
                        return
                    }
                    debugPrint(response.result.value!)
                    onCompletion?(nil)
                    if self.type != "publish" {
                        self.showNormalAlert(strMessage: "Publicacion actualizada con exito.")
                    } else {
                        self.showAlert(strMessage: "Publicacion actualizada con exito.", postID: self.DraftPostId)
                    }
                    self.textfieldTeg.text = ""
                    self.textfieldTitleOfPublication.text = ""
                    self.textviewPostContent.html = ""
                    self.uploadImage.image =  UIImage(named:"")
                    self.imageLogo.isHidden = false
                    self.htPostContent.constant = 320
                    self.CallWebserviceDraft()
                }
                
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                onError?(error)
            }
        }
    }
    
    //Publish Video Post in Draft List
    func WebserviceUploadVideoInDraftPost(){
        let tags: String = textfieldTeg.text!
        let tagArr = tags.replacingOccurrences(of: " ", with: ",")
        let Para: [String: Any] = [
            "userid":"\(UserID!)",
            "title":"\(textfieldTitleOfPublication.text!)",
            "categoryid":"\(Catgoriesid!)",
            "tags":"\(tagArr)",
            "description":"\(textviewPostContent.contentHTML)",
            "notify":"\(Notify)",
            "adimviad":"\(adimviad)",
            "userad":"\(userad)",
            "price":"\(textfieldPostPrice.text!)",
            "type":"\(DraftType)",
            "videoUrl":"\(self.textfieldvideoUrl.text!)",
            "postid":"\(DraftPostId!)"
        ]
        
        let myService:String = "https://www.adimvi.com/appAPI/index.php/api/updatePost"
        objActivity.startActivityIndicator()
        Alamofire.request(myService, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        _ = response.result.value as! [String :Any]
                        if self.type != "publish" {
                            self.showNormalAlert(strMessage: "Publicacion actualizada con exito.")
                        } else {
                            self.showAlert(strMessage: "Publicacion actualizada con exito.", postID: self.DraftPostId)
                        }
                        self.textfieldTeg.text = ""
                        self.textfieldTitleOfPublication.text = ""
                        self.textviewPostContent.html = ""
                        self.uploadImage.image =  UIImage(named:"")
                        self.imageLogo.isHidden = false
                        self.textfieldCatgories.text = ""
                        self.textfieldvideoUrl.text = ""
                        objActivity.stopActivity()
                        self.CallWebserviceDraft()
                        self.htPostContent.constant = 320
                    }
                    objActivity.stopActivity()
                    break
                case .failure(_):
                    print(response.result.error as Any)
                    break
                }
            }
    }
    
    func showNormalAlert(strMessage: String) {
        let actionSheetController: UIAlertController = UIAlertController(title: "Mensaje", message: strMessage, preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func showAlert(strMessage:String, postID: String) ->() {
        let alert = self.storyboard?.instantiateViewController(identifier: "AddPostDialogVC") as! AddPostDialogVC
        alert.callback = {
            let vc: PostDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailsViewController") as! PostDetailsViewController
            vc.hidesBottomBarWhenPushed = true
            vc.PostID = postID
            SharedManager.sharedInstance.PostId = postID
            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func WebserviceUploadVideo(){
        let tags: String = textfieldTeg.text!
        let tagArr = tags.replacingOccurrences(of: " ", with: ",")
        let Para: [String: Any] = [
            "userid":"\(UserID!)",
            "title":"\(textfieldTitleOfPublication.text!)",
             "categoryid":"\(Catgoriesid!)",
             "tags":"\(tagArr)",
             "description":"\(textviewPostContent.contentHTML)",
             "notify":"\(Notify)",
             "adimviad":"\(adimviad)",
             "userad":"\(userad)",
             "price":"\(textfieldPostPrice.text!)",
             "type":"\(type)",
             "videoUrl":"\(self.textfieldvideoUrl.text!)"
        ]
        
        let myService:String = "https://www.adimvi.com/appAPI/index.php/api/addNewPost"
        objActivity.startActivityIndicator()
        Alamofire.request(myService, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        var newPostID = ""
                        if let postID = myData["postID"] as? String {
                            newPostID = postID
                        }
                        if self.type != "publish" {
                            self.showNormalAlert(strMessage: "Publicacion actualizada con exito.")
                        } else {
                            self.showAlert(strMessage: "Publicacion actualizada con exito.", postID: newPostID)
                        }
                        self.textfieldTeg.text = ""
                        self.textfieldTitleOfPublication.text = ""
                        self.textfieldCatgories.text = ""
                        self.textfieldvideoUrl.text = ""
                        self.textviewPostContent.html = ""
                        self.uploadImage.image =  UIImage(named:"")
                        self.imageLogo.isHidden = false
                        self.htPostContent.constant = 320
                        objActivity.stopActivity()
                        self.CallWebserviceDraft()
                        DispatchQueue.main.async {
                        }
                    }
                    objActivity.stopActivity()
                    break
                case .failure(_):
                    print(response.result.error as Any)
                    break
                }
            }
    }
    
}
//MARK:- Extension TableView Delegate/DataSource Methods
extension ToPostVC : UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDraftList.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idetifier = "DraftTableViewCell"
        let cell: DraftTableViewCell = tableDraftList.dequeueReusableCell(withIdentifier: idetifier)as!  DraftTableViewCell
        let dictData = self.arrayDraftList[indexPath.row]
        if let Title = dictData["title"] as? String {
            cell.labelTitle.text = Title
        }
        cell.buttonTap.tag = indexPath.row
        cell.buttonTap.addTarget(self, action: #selector(self.OnDetail(_:)), for: UIControl.Event.touchUpInside)
        return cell
    }
    
    @objc func OnDetail(_ sender: UIButton) {
        let dict = self.arrayDraftList[sender.tag]
        let Posid = dict["postid"] as! String
        Postid = Posid
        DraftPostId = Posid
        UpdatePostType = "draft"
        CallWebserviceDraftDetail()
    }
    
    func CallWebserviceDraft(){
        let Para = ["userid":"\(UserID!)"] as [String : Any]
        let Api:String = "\(WebURL.BaseUrl)\(WebURL.draftPostList)"
        objActivity.startActivityIndicator()
        Alamofire.request(Api, method: .post,parameters:Para)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        debugPrint(response.result)
                        let myData = response.result.value as! [String :Any]
                        if let arr = myData["draftPost"] as? [[String:Any]]{
                            self.arrayDraftList = arr
                            self.tableDraftList.reloadData()
                            if(self.arrayDraftList.count>0){
                                if(self.arrayDraftList.count == 1){
                                    self.htTableDrafts.constant = 50
                                    self.htTitle.constant = 18
                                }else{
                                    self.htTableDrafts.constant = 90
                                }
                            } else {
                                self.htTableDrafts.constant = 0
                                self.htTitle.constant = 0
                            }
                        }
                        objActivity.stopActivity()
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

// MARK:- Custom Methods
extension ToPostVC:UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayCaregories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PostImages[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.textfieldCatgories.text = PostImages[row]
        let Categories = arrayCaregories[row]
        let CatId = Categories["categoryid"] as! String
        Catgoriesid = "\(CatId)"
    }
    
    @IBAction func OnSelectCategories(_ sender: Any) {
        pickerView.delegate = self
        pickerView.dataSource = self
        categoriesView.isHidden = false
    }
    
    @IBAction func OnCancel(_ sender: Any) {
        categoriesView.isHidden = true
        self.textfieldCatgories.text = ""
    }
    
    @IBAction func OnOkay(_ sender: Any) {
        categoriesView.isHidden = true
    }
}

//extension ToPostVC: UITextViewDelegate {
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if textView == textfieldTitleOfPublication {
//            let currentText: NSString = textView.text as NSString
//            let updatedText = currentText.replacingCharacters(in: range, with:text)
//            if updatedText.isEmpty {
//                textView.text = "Título"
//                textView.textColor = UIColor.lightGray
//                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
//                return false
//            } else if textView.textColor == UIColor.lightGray && !text.isEmpty {
//                textView.text = nil
//                textView.textColor = UIColor.init(named: "Dark grey (Dark mode)")
//            }
//        }
//        if textView == textfieldTeg {
//            let currentText: NSString = textView.text as NSString
//            let updatedText = currentText.replacingCharacters(in: range, with:text)
//            if updatedText.isEmpty {
//                textView.text = "Etiquetas: utiliza # al comienzo de cada etiqueta"
//                textView.textColor = UIColor.lightGray
//                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
//                return false
//            } else if textView.textColor == UIColor.lightGray && !text.isEmpty {
//                textView.text = nil
//                textView.textColor = UIColor.init(named: "Dark grey (Dark mode)")
//            }
//        }
//        return true
//    }
//
//    func textViewDidChangeSelection(_ textView: UITextView) {
//        if self.view.window != nil {
//            if textView == textfieldTitleOfPublication {
//                if textView.textColor == UIColor.lightGray {
//                    textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
//                }
//            }
//            if textView == textfieldTeg {
//                if textView.textColor == UIColor.lightGray {
//                    textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
//                }
//            }
//        }
//    }
//
//    func textViewDidChange(_ textView: UITextView) {
//        if textView == textfieldTitleOfPublication {
//            let size = CGSize(width: textView.frame.width, height: .infinity)
//            let estimatedSize = textView.sizeThatFits(size)
//            textView.constraints.forEach { (constraint) in
//                if constraint.firstAttribute == .height {
//                    constraint.constant = estimatedSize.height
//                }
//            }
//        }
//        if textView == textfieldTeg {
//            let size = CGSize(width: textView.frame.width, height: .infinity)
//            let estimatedSize = textView.sizeThatFits(size)
//            textView.constraints.forEach { (constraint) in
//                if constraint.firstAttribute == .height {
//                    constraint.constant = estimatedSize.height
//                }
//            }
//        }
//    }
//
//    @IBAction func didTapButton() {
//        showAlert()
//    }
//
//    func showAlert() {
//        let alert = UIAlertController (title: "Información", message: "Adimvi colabora con varias cadenas y marcas que promocionan sus productos y/o servicios con nosotros. Debido a esta colaboración, es posible que veas algunos anuncios en algún fragmento de tu publicación. El sistema de monetizado por visualizaciones de la plataforma solo funciona cuando esta opción no se encuentra seleccionada. Si decides seleccionar esta opción, la cantidad monetaria acumulada por esta publicación no será añadida a tu cuenta.", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: {action in
//
//        }))
//        present (alert, animated: true)
//    }
//
//    func actionSheet() {
//
//    }
//
//    @IBAction func didTapButton2() {
//        showAlert2()
//    }
//
//    func showAlert2() {
//        let alert = UIAlertController (title: "Información", message: "Adimvi te proporciona la posibilidad de introducir tus propias imágenes promocionales en tus posts. Puedes configurar esta opción desde tu cuenta. El sistema de monetizado por visualizaciones de la plataforma solo funciona cuando esta opción no se encuentra seleccionada. Si decides seleccionar esta opción, la cantidad monetaria acumulada por esta publicación no será añadida a tu cuenta.", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: {action in
//            print ("tapped Okay")
//
//        }))
//        present (alert, animated: true)
//    }
//
//    func actionSheet2() {
//
//    }
//}

extension ToPostVC: RichEditorDelegate {
    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        print(content)
    }
    
    func richEditor(_ editor: RichEditorView, heightDidChange height: Int) {
        if CGFloat(height) > htPostContent.constant {
            htPostContent.constant += CGFloat(height) - htPostContent.constant
        }
        if height == 0 {
            htPostContent.constant = 320
        }
    }
}

extension ToPostVC: RichEditorToolbarDelegate {
    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        
    }
}
