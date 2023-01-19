//
//  NormalRoomCell.swift
//  adimvi
//
//  Created by Aira on 23.10.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit

class NormalRoomCell: UITableViewCell {

    @IBOutlet weak var userUIMG: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var verifyUIMG: UIImageView!
    @IBOutlet weak var memberCntLB: UILabel!
    @IBOutlet weak var titleLB: UILabel!
    
    var room = RoomModel() {
        didSet {
            nameLB.text = room.adminName
            if room.adminAvatar.isEmpty {
                userUIMG.image = UIImage(named: "Splaceicon")
            } else {
                let imageURl = "\(room.adminAvatar)"
                userUIMG.sd_setImage(with: URL(string: imageURl), placeholderImage: UIImage(named: "Splaceicon"))
            }
            titleLB.text = room.title
            if room.adminVerify == 1 {
                verifyUIMG.isHidden = false
            } else {
                verifyUIMG.isHidden = true
            }
            memberCntLB.text = getThousandWithK(value: room.memberCnt)
        }
    }
    
    var callBack: (() -> Void)!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapRoomCell)))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func didTapRoomCell() {
        callBack()
    }
    
}
