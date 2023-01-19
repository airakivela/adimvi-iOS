//
//  FollowersViewCell.swift
//  adimvi
//
//  Created by javed carear  on 10/07/19.
//  Copyright © 2019 webdesky.com. All rights reserved.
//

import UIKit

class FollowersViewCell: UITableViewCell {
    @IBOutlet weak var buttonFollow: UIButton!
    @IBOutlet weak var buttonUnFollow: UIButton!
    @IBOutlet weak var buttonTime: UIButton!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var labelusName: UILabel!
    @IBOutlet weak var buttonCategoriesName: DesignableButton!
    @IBOutlet weak var imageFollowers: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var buttonlike: UIButton!
    @IBOutlet weak var buttonSeenTime: UIButton!
    @IBOutlet weak var buttonShare: UIButton!
    @IBOutlet weak var buttonMessageCount: UIButton!
    @IBOutlet weak var buttonSeen: UIButton!
    @IBOutlet weak var buttonTab: UIButton!
    @IBOutlet weak var buttonUsersTab: UIButton!
    @IBOutlet weak var labeldescription: UILabel!
    @IBOutlet weak var webviewContent: UIWebView!
    @IBOutlet var RatingView: FloatRatingView!
    @IBOutlet weak var labelVotes: UILabel!
    @IBOutlet weak var verifiedMarker: UIImageView!
    @IBOutlet weak var remuroUB: UIButton!
    @IBOutlet weak var recentWallUV: UIView!
    @IBOutlet weak var gradientUV: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        labelPrice.layer.cornerRadius = 8.0
        labelPrice.layer.masksToBounds = true
//        gradientUV.setGradient()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}

extension UIView {
    func setGradient(for bottom: UIColor = UIColor.black.withAlphaComponent(0.9)) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [UIColor.clear.cgColor, bottom.cgColor]
        self.layer.addSublayer(gradient)
    }
}
