//
//  PostContentTableViewCell.swift
//  adimvi
//
//  Created by javed carear  on 06/02/20.
//  Copyright © 2020 webdesky.com. All rights reserved.


import UIKit

class PostContentTableViewCell: UITableViewCell {
 @IBOutlet weak var labelContent: UILabel!
 @IBOutlet weak var postImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
