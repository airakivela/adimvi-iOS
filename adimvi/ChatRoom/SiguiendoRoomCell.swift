//
//  SiguiendoRoomCell.swift
//  adimvi
//
//  Created by Aira on 23.10.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit

class SiguiendoRoomCell: UICollectionViewCell {

    @IBOutlet weak var userNameLB: UILabel!
    @IBOutlet weak var userUIMG: UIImageView!
    
    var room = RoomModel() {
        didSet {
            userNameLB.text = room.adminName
            if room.adminAvatar.isEmpty {
                userUIMG.image = UIImage(named: "Splaceicon")
            } else {
                let imageURl = "\(room.adminAvatar)"
                userUIMG.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
