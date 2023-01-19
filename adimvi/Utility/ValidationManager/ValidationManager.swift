//  validationManager.swift
//  MualabBusiness
//  Created by Mac on 27/12/2017 .
//  Copyright © 2017 Mindiii. All rights reserved.

import Foundation
let objValidationManager = ValidationManager.sharedObject()
class ValidationManager {
    
    private static var sharedValidationManager: ValidationManager = {
        let validation = ValidationManager()
        return validation
    }()
    // MARK: - Accessors
    class func sharedObject() -> ValidationManager {
        return sharedValidationManager
    }
    
}

//MARK: - Validations
extension ValidationManager{
    func isValidateEmail(strEmail: String) -> Bool {
        let REGEX: String
        REGEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", REGEX).evaluate(with: strEmail)
    }
    
    
    func isValidateName(strFullname: String) -> Bool {
        if strFullname.count < 4{
            let nameRegEx = "^([A-Za-z](\\.)?+(\\s)?[A-Za-z|\\'|\\.]*){1,7}$"
            let nameTest = NSPredicate (format:"SELF MATCHES %@",nameRegEx)
            let result = nameTest.evaluate(with: strFullname)
            return result
        }else{
            return false
        }
    }
    func isValidPhone(value: String) -> Bool {
        let PHONE_REGEX = "^([0-9]{3}(-)?[0-9]{3}(-)?[0-9]{2,4})$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    //MARK : - Password validation
    func isPasswordValid(_ password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{6,}")
        return passwordTest.evaluate(with: password)
    }
    
    func isPasswordContainsCap(_ password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@",".*[A-Z]+.*")
        return passwordTest.evaluate(with: password)
    }
    
    func isPasswordContainsNum(_ password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@",".*[0-9]+.*")
        return passwordTest.evaluate(with: password)
    }
    
    func validatePassword(_ numString: String) -> Bool {
        var isFound: Bool
        let `set` = CharacterSet(charactersIn: "/@%+\'!#$^?:,(){}[]~-_")
        let range: NSRange = (numString as NSString).rangeOfCharacter(from: `set`)
        if range.location == NSNotFound {
            isFound = false
        }else {
            isFound = true
        }
        return isFound
    }
    
    func isPasswordSame(password: String , confirmPassword : String) -> Bool {
        if password == confirmPassword{
            return true
        }else{
            return false
        }
    }
    
    func validateUserName(_ candidate: String) -> Bool{
        let whiteSpaceRange: NSRange = (candidate as NSString).rangeOfCharacter(from: CharacterSet.whitespaces)
        if whiteSpaceRange.location != NSNotFound {
            return true
        }else{
            return false
        }
    }
    
}
