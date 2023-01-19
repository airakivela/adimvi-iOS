//
//  PrivateMassageViewCell.swift
//  adimvi
//  Created by javed carear  on 04/09/19.
//  Copyright © 2019 webdesky.com. All rights reserved.


import UIKit
class PrivateMassageViewCell: UITableViewCell {
    @IBOutlet weak var labeTime: UILabel!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var Postimage: UIImageView!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var labelMassage: UILabel!
    @IBOutlet weak var ColorView: UIView!
    @IBOutlet weak var htColorView: NSLayoutConstraint!
    @IBOutlet weak var htLeading: NSLayoutConstraint!
    @IBOutlet weak var htTraling: NSLayoutConstraint!
    @IBOutlet weak var htImages: NSLayoutConstraint!
    @IBOutlet weak var verifiedMarker: UIImageView!
    @IBOutlet weak var recentWallUV: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}
