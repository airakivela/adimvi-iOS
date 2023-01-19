//
//  RecentPubViewCell.swift
//  adimvi
//
//  Created by javed carear  on 23/08/19.
//  Copyright © 2019 webdesky.com. All rights reserved.
//

import UIKit

class RecentPubViewCell: UITableViewCell {
    
    @IBOutlet weak var imagePost: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var buttonlike: UIButton!
    @IBOutlet weak var buttonSeenTime: UIButton!
    @IBOutlet weak var buttonMessageCount: UIButton!
    @IBOutlet weak var buttonSeen: UIButton!
    @IBOutlet weak var ButtonTap: UIButton!
    @IBOutlet weak var labeldescription: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
