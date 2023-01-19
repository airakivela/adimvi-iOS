
import UIKit

fileprivate enum type:String {
    case noNetwork,
    error,
    banner,
    question,
    bannerDark,
    sessionExpire
}
@objc  protocol AlertVCDelegate {
    @objc optional func alertOkAction()
}

class alertVC: UIViewController {
    
    var alertMessage:String?
    var alertType:String?
    weak var delegate : AlertVCDelegate?
    
    @IBOutlet weak var vwQues: UIView!
    @IBOutlet weak var lblSure: UILabel!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var visualView: UIVisualEffectView!
    @IBOutlet weak var topConstraintsAlert: NSLayoutConstraint!
    @IBOutlet weak var lblQueTitle: UILabel!
    @IBOutlet weak var lblMessage:UILabel!
    @IBOutlet weak var lblNotiMessage:UILabel!
    @IBOutlet weak var lblBannerTitle:UILabel?
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var imgWarring:UIImageView!
    @IBOutlet weak var vwSubAlert: UIView!
    @IBOutlet weak var alertBigView:UIView!
    @IBOutlet weak var alertBannerView:UIView!
    @IBOutlet weak var alert1Top : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblNotiMessage.text = alertMessage ?? ""
     //   objWebserviceManager.StopIndicator()
        showAlert()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
 
    
}
fileprivate extension alertVC{
    func addBlurEffect()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.alertBannerView.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.alertBannerView.addSubview(blurEffectView)
    }
    
    @IBAction func actnOkAlert(_ sender: Any) {
          self.dismiss(animated: false, completion: nil)
    }
    
    func showAlert(){
        switch self.alertType {
        case type.noNetwork.rawValue?:do{
            self.alertBannerView.isHidden = true
            self.alertBigView.isHidden = false
            self.vwQues.isHidden = true
            self.lblTitle.text = "No Network"
            self.lblMessage.text = message.noNetwork
            self.imgWarring.image = UIImage.customImage.noNetwork
            self.btnOk.setTitle("Retry", for: UIControl.State.normal)
            }
            
        case type.error.rawValue?:do{
             self.alertBannerView.isHidden = true
            self.alertBigView.isHidden = false
            self.vwQues.isHidden = true
            self.lblTitle.text = "Oops"
            self.lblMessage.text = message.error.wrong
            self.imgWarring.image = UIImage.customImage.error
            self.btnOk.setTitle("Retry", for: UIControl.State.normal)

            }
            
        case type.banner.rawValue?:do{
            btnOk.isHidden = true
            self.alertBigView.isHidden = true
            self.vwQues.isHidden = true
            self.alertBannerView.isHidden = false
            self.visualView.isHidden = true
           UIView.animate(withDuration: 0.5) {
            self.topConstraintsAlert.constant = -self.vwSubAlert.frame.size.height
                self.view.layoutIfNeeded()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
               self.dismiss(animated: false, completion: nil)
            }
            }
        case type.bannerDark.rawValue?:do{
            self.alertBigView.isHidden = true
            self.vwQues.isHidden = true
            UIView.animate(withDuration: 0.5) {
                self.topConstraintsAlert.constant = -self.vwSubAlert.frame.size.height
                self.view.layoutIfNeeded()
            }
        }
        case type.question.rawValue?:do{
            self.alertBigView.isHidden = true
             self.alertBannerView.isHidden = true
             self.lblQueTitle.text = alertMessage
            self.vwQues.isHidden = false
        }
            
        case type.sessionExpire.rawValue?:do{
            self.alertBannerView.isHidden = true
            self.alertBigView.isHidden = false
             self.vwQues.isHidden = true
            self.lblTitle.text = "Session expired"
            self.lblMessage.text = message.sessionExpire
            self.imgWarring.image = UIImage.customImage.sessionExpire
            self.btnOk.setTitle("Ok", for: UIControl.State.normal)
            }
        default:
            do{
                self.alertBannerView.isHidden = true
                self.alertBigView.isHidden = false
                self.vwQues.isHidden = true
                self.lblTitle.text = "Oops"
                self.lblMessage.text = message.error.wrong
                self.imgWarring.image = UIImage.customImage.error
                self.btnOk.setTitle("Retry", for: UIControl.State.normal)
            }
        }
        
    }
}
fileprivate extension alertVC{
    @IBAction func actnOkQue(_ sender: Any) {
         self.dismiss(animated: false, completion: nil)
        self.delegate?.alertOkAction!()
    }
    @IBAction func actnCancelQue(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func btnRetry(_ sender:Any){
        self.dismiss(animated: false, completion: nil)
//        if self.alertType == type.sessionExpire.rawValue{
//            appDelegate.logout()
//        }
    }
}

