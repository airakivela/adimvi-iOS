//
//  MembersPublicationTableViewCell.swift
//  adimvi
//
//  Created by javed carear  on 03/02/20.
//  Copyright © 2020 webdesky.com. All rights reserved.
//

import UIKit

class MembersPublicationTableViewCell: UITableViewCell {
     @IBOutlet weak var buttonTime: UIButton!
        @IBOutlet weak var buttonTap: UIButton!
       @IBOutlet weak var labelPrice: UILabel!
       @IBOutlet weak var imgProfilePic: UIImageView!
       @IBOutlet weak var labelusName: UILabel!
       @IBOutlet weak var buttonCategoriesName: DesignableButton!
       @IBOutlet weak var imageFollowers: UIImageView!
       @IBOutlet weak var labelTitle: UILabel!
       @IBOutlet weak var buttonlike: UIButton!
       @IBOutlet weak var buttonSeenTime: UIButton!
       @IBOutlet weak var buttonMessageCount: UIButton!
       @IBOutlet weak var buttonSeen: UIButton!
       @IBOutlet weak var labeldescription: UILabel!
       @IBOutlet weak var buttonProfile: UIButton!
    @IBOutlet weak var recentWallUV: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
