//
//  CategoriesDatailViewCell.swift
//  adimvi
//
//  Created by javed carear  on 20/07/19.
//  Copyright © 2019 webdesky.com. All rights reserved.
//

import UIKit

class CategoriesDatailViewCell: UITableViewCell {
    @IBOutlet weak var webviewContent: UIWebView!
    @IBOutlet weak var buttonFollow: UIButton!
    @IBOutlet weak var buttonUnFollow: UIButton!
    @IBOutlet weak var buttonPostDetail: UIButton!
    @IBOutlet weak var imageCategories: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var ProfilePic: UIImageView!
    @IBOutlet weak var buttonSeen: UIButton!
    @IBOutlet weak var buttonSeenTime: UIButton!
    @IBOutlet weak var buttonLike: UIButton!
    @IBOutlet weak var buttonMessage: UIButton!
    @IBOutlet weak var buttonCategoriesname: UIButton!
    @IBOutlet weak var labelPostContent: UILabel!
    @IBOutlet weak var buttonUser: UIButton!
    @IBOutlet weak var buttonShare: UIButton!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet var RatingView: FloatRatingView!
    @IBOutlet weak var labelVotes: UILabel!
    @IBOutlet weak var verifiedMarker: UIImageView!
    @IBOutlet weak var remuroUB: UIButton!
    @IBOutlet weak var recentWallUV: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelPrice.layer.cornerRadius = 8.0
        labelPrice.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }

}
