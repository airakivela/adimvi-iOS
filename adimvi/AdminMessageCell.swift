//
//  AdminMessageCell.swift
//  adimvi
//
//  Created by Aira on 25.10.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit

class AdminMessageCell: UITableViewCell {
    
    @IBOutlet weak var txtMessage: UILabel!
    @IBOutlet weak var extraUIMG: UIImageView!
    
    var cellCallBack: ((UIImage) -> Void)!
    
    var message = RoomMessageModel() {
        didSet {
            txtMessage.text = message.content
            if message.extra.isEmpty {
                extraUIMG.isHidden = true
            } else {
                extraUIMG.isHidden = false
                extraUIMG.sd_setImage(with: URL(string: message.extra), placeholderImage: UIImage(named: "Place.png"))
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
