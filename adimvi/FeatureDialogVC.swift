//
//  FeatureDialogVC.swift
//  adimvi
//
//  Created by Aira on 12.12.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit

class FeatureDialogVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func didTapOKUB(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
