//
//  FavouriteViewCell.swift
//  adimvi
//
//  Created by javed carear  on 15/07/19.
//  Copyright © 2019 webdesky.com. All rights reserved.
//

import UIKit

class FavouriteViewCell: UITableViewCell {
    @IBOutlet weak var buttonMessage: UIButton!
    @IBOutlet weak var buttonFollow: UIButton!
    @IBOutlet weak var buttonUnFollow: UIButton!
    @IBOutlet weak var imgFavourite: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var buttonMessageCount: UIButton!
    @IBOutlet weak var buttonLike: UIButton!
    @IBOutlet weak var buttonTime: UIButton!
    @IBOutlet weak var ButtonViewCount: UIButton!
    @IBOutlet weak var buttonCategoriesName: DesignableButton!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var buttonUserTab: UIButton!
    @IBOutlet weak var buttonPostDetail: UIButton!
    @IBOutlet weak var buttonShare: UIButton!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var webviewContent: UIWebView!
    @IBOutlet var RatingView: FloatRatingView!
    @IBOutlet weak var labelVotes: UILabel!
    @IBOutlet weak var verifiedMarker: UIImageView!
    @IBOutlet weak var remuroUB: UIButton!
    @IBOutlet weak var recentWallUV: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
