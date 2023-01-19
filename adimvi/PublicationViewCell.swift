//
//  PublicationViewCell.swift
//  adimvi
//
//  Created by javed carear  on 27/08/19.
//  Copyright © 2019 webdesky.com. All rights reserved.
//

import UIKit

class PublicationViewCell: UITableViewCell {
    @IBOutlet weak var webviewContent: UIWebView!
    @IBOutlet weak var buttonFollow: UIButton!
    @IBOutlet weak var buttonUnFollow: UIButton!
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
    @IBOutlet weak var buttonShare: UIButton!
    @IBOutlet weak var labeldescription: UILabel!
    @IBOutlet weak var buttonProfile: UIButton!
    @IBOutlet var RatingView: FloatRatingView!
    @IBOutlet weak var labelVotes: UILabel!
    @IBOutlet weak var verifiedMarker: UIImageView!
    @IBOutlet weak var remuroUB: UIButton!
    @IBOutlet weak var recentWallUV: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        verifiedMarker.isHidden = isVerifiedUser ? false : true
        labelPrice.layer.cornerRadius = 8.0
        labelPrice.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}
