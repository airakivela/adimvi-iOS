//
//  DateTimePickerVC.swift
//  MualabCustomer
//
//  Created by Mac on 01/02/18.
//  Copyright © 2018 Mindiii. All rights reserved.
//

import UIKit

protocol DateTimePickerVCDelegate {
    func finishDateSectionWithDate(forShow: String, forServer: String)
     func finishDateSectionWithEndDate(forDate: String,EndDate: String)
}



class DateTimePickerVC: UIViewController {
    
    var delegate: DateTimePickerVCDelegate?
    @IBOutlet weak var picker : UIDatePicker!
    @IBOutlet weak var bottomConstraint : NSLayoutConstraint!
    let dateFormator = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.date = Date()
        picker.datePickerMode = .date
        dateFormator.dateFormat = "dd-MM-yyyy"
      // picker.minimumDate = Date()
        picker.maximumDate = Date()
        self.bottomConstraint.constant = -self.view.frame.size.height/2

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.bottomConstraint.constant = 0
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - IBActions
extension DateTimePickerVC{
        
    @IBAction func btnDoneCancleDOBSelection(_ sender:UIButton){
        
        self.bottomConstraint.constant = -self.view.frame.size.height/2
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        var strDOBForToShow = ""
        var strDOBForServer = ""
        var strDOBForDate = ""
        var strDOBEndDate = ""
        
        if sender.tag == 1 {
            strDOBForToShow = dateFormator.string(from: self.picker.date)
            strDOBForServer = dateFormator.string(from: self.picker.date)
            
//            strDOBForToShow = objAppShareData.dateFormatToShow(forAPI: self.picker.date)
//            strDOBForServer = objAppShareData.dateFormat(forAPI: self.picker.date)
        }
        if sender.tag == 2{
            strDOBForDate = dateFormator.string(from: self.picker.date)
            strDOBEndDate  = dateFormator.string(from: self.picker.date)
        }
        print("strDOBForToShow = \(strDOBForToShow)")
        delegate?.finishDateSectionWithDate(forShow: strDOBForToShow, forServer: strDOBForServer)
        delegate?.finishDateSectionWithEndDate(forDate: strDOBForDate, EndDate:strDOBEndDate)
       // dismiss(animated: true, completion: nil)
    }
}
