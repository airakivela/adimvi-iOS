//
//  BaseViewController.swift
//  adimvi
//
//  Created by javed carear  on 17/06/19.
//  Copyright © 2019 webdesky.com. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setNavigationTitleView() -> UIImageView {
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let image = UIImage(named: "newLogo.png")
        imgView.image = image
        imgView.contentMode = .scaleAspectFit
        imgView.setImageColor(color: #colorLiteral(red: 1, green: 0.3725490196, blue: 0.06666666667, alpha: 1))
        return imgView
    }
  
}

extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}
