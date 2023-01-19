

import Foundation
import UIKit

//MARK: - UIColor
extension UIColor{
    enum theameColors {
        static let pinkColor = UIColor.init(red: 248.0/255.0, green: 50.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        static let orange = UIColor(red: 236/255, green: 89/255, blue: 32/255, alpha: 1.0)
        static let darkColor = UIColor.init(red: 76.0/255.0, green: 53.0/255.0, blue: 73.0/255.0, alpha: 1.0)
         static let grayColor = UIColor.init(red: 86.0/255.0, green: 86.0/255.0, blue: 86.0/255.0, alpha: 1.0)
        static let blueColor = UIColor.init(red: 63.0/255.0, green: 142.0/255.0, blue: 252.0/255.0, alpha: 1.0)
        static let greenColor = UIColor.init(red: 78.0/255.0, green: 205.0/255.0, blue: 49.0/255.0, alpha: 1.0)
        static let backgroundColor = UIColor.init(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        
        static let greenCalendar = UIColor.init(red: 0.0/255.0, green: 187.0/255.0, blue: 39.0/255.0, alpha: 1.0)
        
    }
}
let userDefault = UserDefaults.standard

//MARK: - Alert Type
struct alertType {
    static let noNetwork = "noNetwork"
    static let error = "error"
    static let banner = "banner"
    static let question = "question"
    static let bannerDark = "bannerDark"
    static let sessionExpire = "sessionExpire"
}

//MARK: - Userdeafults
extension UserDefaults{
    enum keys {
        static let userId = "UserID"
        static let userName = "userName"
        static let userInfo = "userInfo"
        static let authToken = "authToken"
        static let instituteName = "instituteName"
         static let instituteImgUrl = "InstituteLogo"
        static let  instituteId = "instituteId"
        static let  userRoleId = "UserRoleID"
        static let  userRoleType = "RoleUserType"
        static let  userPic = "userPhoto"
        static let  sessionId = "SessionId"
        static let  studentId = "SID"
        static let studentClassId = "studentClassId"
         static let studentSectionId = "studentSectionId"
        static let  userRole = "UserRole"
    }
}

//MARK: - notification key
struct NotificationKey {
   static let menuReload = "menuReload"
}


//MARK: - validation message
struct MessageFields {
    static let name = "name"
    static let text = "text"
    static let email = "email"
    static let photoURL = "photoURL"
    static let imageURL = "imageURL"
}

struct message {
    static let sessionExpire = "Your session has been expired. Please re-login to renew your session."
    static let invalidToken = "Invalid Auth Token"
    static let noNetwork = "Please check your network connection"
    enum validation{
        static let required = "Please enter required field."
        static let email = "Please enter a valid email address."
        static let invalidOTP = "Please enter valid OTP."
        static let genderSelection = "Please select gender."
        static let userNameLength = "Username must be at least 4 characters long."
        static let userNameSpace = "User name cannot contains blank space."
         static let validPhoneNumber = "Please enter valid phone number"
        static let validPassword = "Use at least 6 character"
        static let notSamePwdInBothField = "New password and Confirm password are not same."
        static let passwordLength = "Passwords must be at least 6 characters long."
    }
    enum error {
        static let title = "Error"
        static let wrong = "Something went wrong, please try after some time."
    }
}

//MARK: - Alert Type
struct AlertType {
    static let noNetwork = "noNetwork"
    static let error = "error"
    static let banner = "banner"
    static let bannerDark = "bannerDark"
    static let sessionExpire = "sessionExpire"
}
//Notification names
struct NotificationName {
    static let postFeedSuccess = "postFeedSuccess"
    static let sideMenuToggleKey = "toggleMenu"
    static let gotoDashboard   = "gotoDashboard"
    static let notifyForUserName   = "notifyForUserName"
}
//MARK: - UIImage
extension UIImage{
    enum customImage {
        static let error = UIImage(named:"worried-emoji")
        static let noNetwork = UIImage(named:"wifi")
        static let sessionExpire = UIImage(named:"sessionExpire")
        static let flashOn = UIImage(named:"flash_on")
        static let flashOff = UIImage(named:"flash_off")
        static let flashAuto = UIImage(named:"flash_automatic")
        static let camera = UIImage(named:"ico_camera")
        static let video = UIImage(named:"icoVideoRec")
        static let user = UIImage(named:"cellBackground")
    }
}


//MARK: - Keys
struct Keys {
    enum user {
        
        static let address = "address"
        static let type = "userType"
        static let email = "email"
        static let countryCode = "countryCode"
        static let contactNumber = "contactNumber"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let businessName = "businessName"
        static let userName = "userName"
        static let DOB = "dob"
        static let gender = "gender"
        
        enum addressComponent {
            static let fullAddress = "fullAddress"
            static let locality = "locality"
            static let address2 = "address2"
            static let city = "city"
            static let state = "state"
            static let postalCode = "postalCode"
            static let country = "country"
            static let placeName = "placeName"
            static let latitude = "latitude"
            static let longitude = "longitude"
        }
    }
}


