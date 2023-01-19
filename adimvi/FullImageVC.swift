//
//  FullImageVC.swift
//  adimvi
//
//  Created by Aira on 4.05.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit

class FullImageVC: UIViewController {

    @IBOutlet weak var imageUV: UIImageView!
    
    var image: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()

        imageUV.isUserInteractionEnabled = true
        imageUV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapDismiss)))
        imageUV.image = image
        imageUV.contentMode = .scaleAspectFit
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func onTapDismiss() {
        self.dismiss(animated: true, completion: nil)
    }

}
