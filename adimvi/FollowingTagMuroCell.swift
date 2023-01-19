//
//  FollowingTagMuroCell.swift
//  adimvi
//
//  Created by Aira on 6.07.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit
import TagListView

protocol FollowingTagMuroCellDelegate {
    func onTapTag(tag: TagModel)
}

class FollowingTagMuroCell: UITableViewCell {
    
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var verifyMarker: UIImageView!
    @IBOutlet weak var buttonUnFavourite: UIButton!
    @IBOutlet weak var buttonFavourite: UIButton!
    @IBOutlet weak var buttonmassageCount: UIButton!
    @IBOutlet weak var buttonUserProfile: UIButton!
    @IBOutlet weak var labelComments: UILabel!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgWallPost: UIImageView!
    @IBOutlet weak var htImages: NSLayoutConstraint!
    @IBOutlet weak var remuroUB: UIButton!
    @IBOutlet weak var originWallUV: DesignableView!
    @IBOutlet weak var originWallUserAvatar: UIImageView!
    @IBOutlet weak var originWallUserName: UILabel!
    @IBOutlet weak var originWallContent: UILabel!
    @IBOutlet weak var originWallCreated: UILabel!
    @IBOutlet weak var originWallUserVerify: UIImageView!
    @IBOutlet weak var originWallExtra: UIImageView!
    @IBOutlet weak var originWallExtraUB: UIButton!
    @IBOutlet weak var originWallExtraHeight: NSLayoutConstraint!
    @IBOutlet weak var originPostUV: UIView!
    @IBOutlet weak var originPostExtra: UIImageView!
    @IBOutlet weak var originPostTitle: UILabel!
    @IBOutlet weak var originPostCreated: UILabel!
    @IBOutlet weak var originPostActionUB: UIButton!
    @IBOutlet weak var stackUV: UIStackView!
    @IBOutlet weak var trailofStackUV: NSLayoutConstraint!
    @IBOutlet weak var tagListUV: TagListView!
    @IBOutlet weak var recentWallUV: UIView!
    
    var tagArr: [TagModel] = [TagModel]()
    
    var delegate: FollowingTagMuroCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let deviceHeight: CGFloat = UIScreen.main.bounds.height
        trailofStackUV.constant = deviceHeight > 700 ? 180.0 : 150.0
        
        tagListUV.textFont = .systemFont(ofSize: 14.0)
        tagListUV.tagBackgroundColor = .clear
        tagListUV.textColor = UIColor(named: "lighter_gray")!
        
        tagListUV.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initTag(tags: [[String: Any]]) {
        tagArr.removeAll()
        tagListUV.removeAllTags()
        for tag in tags {
            let tagModel: TagModel = TagModel()
            tagModel.initTag(tag: tag)
            if let id = tagModel.tagID, !id.isEmpty {
                if let tagName = tagModel.tags, !tagName.isEmpty, tagName != " " {
                    tagArr.append(tagModel)
                    tagListUV.addTag(tagName)
                }
            }
        }
    }

}

extension FollowingTagMuroCell: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        var selectedTag = TagModel()
        for tag in tagArr {
            if tag.tags == title {
                selectedTag = tag
                break
            }
        }
        delegate?.onTapTag(tag: selectedTag)
    }
}
