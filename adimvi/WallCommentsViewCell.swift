//
//  WallCommentsViewCell.swift
//  adimvi
//
//  Created by javed carear  on 26/09/19.
//  Copyright © 2019 webdesky.com. All rights reserved.


import UIKit

class WallCommentsViewCell: UITableViewCell {
    @IBOutlet weak var labelComments: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var buttonProfile: UIButton!
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var verifiedMarker: UIImageView!
    @IBOutlet weak var recentWallUV: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}
