//
//  MentionUserCell.swift
//  adimvi
//
//  Created by Aira on 7.09.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit
import DropDown

class MentionUserCell: DropDownCell {

    @IBOutlet weak var userImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
