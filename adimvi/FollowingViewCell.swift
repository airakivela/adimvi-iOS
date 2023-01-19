//
//  FollowingViewCell.swift
//  adimvi
//
//  Created by javed carear  on 27/08/19.
//  Copyright © 2019 webdesky.com. All rights reserved.
//

import UIKit

class FollowingViewCell: UITableViewCell {
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var buttonProfile: UIButton!
    @IBOutlet weak var verifiedMarker: UIImageView!
    @IBOutlet weak var recentWallUV: UIView!
    @IBOutlet weak var seguirUB: UIButton!
    @IBOutlet weak var seguirLB: UILabel!
    @IBOutlet weak var siguiendoUB: UIButton!
    @IBOutlet weak var siguiendoLB: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
