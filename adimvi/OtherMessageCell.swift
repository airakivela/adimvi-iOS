//
//  OtherMessageCell.swift
//  adimvi
//
//  Created by Aira on 25.10.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit

class OtherMessageCell: UITableViewCell {

    @IBOutlet weak var userUIMG: UIImageView!
    @IBOutlet weak var userNameLB: UILabel!
    @IBOutlet weak var userVerifyUIMG: UIImageView!
    @IBOutlet weak var msgLB: UILabel!
    @IBOutlet weak var extraUIMG: UIImageView!
    
    var cellCallBack: ((UIImage) -> Void)!
    
    var message = RoomMessageModel() {
        didSet {
            if message.senderAvatar.isEmpty {
                userUIMG.image = UIImage(named: "Splaceicon")
            } else {
                userUIMG.sd_setImage(with: URL(string: message.senderAvatar), placeholderImage: UIImage(named: "Splaceicon"))
            }
            userNameLB.text = message.userName
            userVerifyUIMG.isHidden = (message.senderVerify == 0)
            msgLB.text = message.content
            if message.extra.isEmpty {
                extraUIMG.isHidden = true
            } else {
                extraUIMG.isHidden = false
                extraUIMG.sd_setImage(with: URL(string: message.extra), placeholderImage: UIImage(named: "Place.png"))
            }
            if message.format == "0" {
                msgLB.textColor = UIColor(named: "blackwhite")
            } else if message.format == "1" {
                msgLB.textColor = UIColor(named: "mainGreen")
            } else if message.format == "2" {
                msgLB.textColor = UIColor(named: "labelPrice")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCell)))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func didTapCell() {
        if message.extra.isEmpty {
            return
        }
        cellCallBack(extraUIMG.image!)
    }
    
}
