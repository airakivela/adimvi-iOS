//
//  RoomBGCell.swift
//  adimvi
//
//  Created by Aira on 24.10.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit

class RoomBGCell: UICollectionViewCell {

    @IBOutlet weak var bgUIMG: UIImageView!
    
    var bgItem: RoomBGModel! {
        didSet {
            if bgItem.isSelected {
                bgUIMG.layer.borderWidth = 4.0
            } else {
                bgUIMG.layer.borderWidth = 0.0
            }
            bgUIMG.image = bgItem.image
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgUIMG.layer.cornerRadius = 6.0
        bgUIMG.layer.borderColor = UIColor(named: "mainGreen")?.cgColor
    }

}
