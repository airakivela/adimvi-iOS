//
//  AddPostDialogVC.swift
//  adimvi
//
//  Created by Aira on 24.11.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit

class AddPostDialogVC: UIViewController {

    var callback: (() -> Void)!
    
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

    @IBAction func didTapCloseUB(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapGoPostUB(_ sender: Any) {
        self.dismiss(animated: true) {
            self.callback()
        }
    }
}
