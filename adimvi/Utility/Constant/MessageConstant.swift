

import Foundation
import UIKit


//pragma mark - Field validation
let BlankUsername: String = "Please enter Username."
let UsernameLength: String = "Username must be atleast 4 characters long."
let CorrectUsername: String = "Username cannot contains whitespace."
let BlankEmail: String = "Please enter Email Id."
let InvalidEmail: String = "Please enter valid Email Id."
let BlankPassword: String = "Please enter your Password."
let BlankconfirmPassword: String = "Please enter your Confirm Password."
let LengthPassword: String = "Minimum length 4 characters."
let LengthFirst: String = "Maximum length 30 characters."
let LengthLast: String = "Maximum length 30 characters."
let MismatchPassword: String = "Confirm Password should be same as Password."
let InvalidPassword: String = "Password must be atleast 6 characters long."
let InvalidConfirmPassword: String = "Confirm Password Should be Grater then 6."
let ConfirmPassword: String = "Confirm Password Should be  Same as Password."
let InvalidLastName: String = "Please enter valid last name."
let BlankContact: String = "Please enter Contact No."
let CorrectConnectNo: String = "Please enter  Vaild Contact No."
let BlankAddress: String = "Please enter Address."
let InternetConnection: String = "Please Check internet connection."
let OTPMsg: String = "OTP is not matched."
let alreadyExistUsername: String = "The Username that you've entered is already associated with any Mualab account."
let OTPConfirmMsg: String = "A 4 digit verification code sent to you."
let BlankOTP: String = "Please enter OTP First."
let BlankDOB: String = "Please Select DOB."
let BlankImage: String = "Please Select or take Profile Image."
let BlankGender: String = "Please Select Gender."
let SpicalCharcter: String = "Password should contain at least one special character."
let NoNetwork: String = "No network connection"

//pragma mark -Alert validation
let kAlertMessage: String = "Message"
let kAlertTitle: String = "Alert"
let kErrorMessage: String = "Something went wrong"
//MARK: - Alerts

func showAlertVC(title:String,message:String,controller:UIViewController) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let subView = alertController.view.subviews.first!
    let alertContentView = subView.subviews.first!
    alertContentView.backgroundColor = UIColor.gray
    alertContentView.layer.cornerRadius = 20
    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(OKAction)
    controller.present(alertController, animated: true, completion: nil)
}



func checkForNULL(obj:Any?) -> Any {
    return obj ?? ""
}
