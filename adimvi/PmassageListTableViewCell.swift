//
//  PmassageListTableViewCell.swift
//  adimvi
//
//  Created by javed carear  on 01/02/20.
//  Copyright © 2020 webdesky.com. All rights reserved.
//

import UIKit

class PmassageListTableViewCell: UITableViewCell {
    @IBOutlet weak var buttonProfile: UIButton!
    @IBOutlet weak var labelUserName: UILabel!
     @IBOutlet weak var labelMassage: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lastMsgTime: UILabel!
    @IBOutlet weak var verifiedMarker: UIImageView!
    @IBOutlet weak var recentWallUV: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }

}
