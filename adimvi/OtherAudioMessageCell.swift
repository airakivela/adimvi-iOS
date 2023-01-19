//
//  OtherAudioMessageCell.swift
//  adimvi
//
//  Created by Aira on 23.11.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit

class OtherAudioMessageCell: UITableViewCell {

    var callback: ((RoomMessageModel)->Void)!
    
    var model  = RoomMessageModel() {
        didSet {
            if model.senderAvatar.isEmpty {
                avatarUIMG.image = UIImage(named: "Splaceicon")
            } else {
                avatarUIMG.sd_setImage(with: URL(string: model.senderAvatar), placeholderImage: UIImage(named: "Splaceicon"))
            }
        }
    }
    
    @IBOutlet weak var avatarUIMG: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarUIMG.image = UIImage(named: "Splaceicon.png")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCell)))
    }
    
    @objc func didTapCell() {
        callback(model)
    }
    
}
