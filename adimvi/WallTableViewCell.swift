//
//  WallTableViewCell.swift
//  adimvi
//  Created by javed carear  on 23/08/19.
//  Copyright © 2019 webdesky.com. All rights reserved.


import UIKit
import TagListView

class TagModel: NSObject {
    var tagID: String?
    var tags: String?
    
    func initTag(tag: [String: Any]) {
        tagID = tag["tagid"] as? String
        tags = tag["tags"] as? String
    }
}

protocol WallTableViewCellDelegate {
    func onTapTag(tag: TagModel)
}

class WallTableViewCell: UITableViewCell {
    @IBOutlet weak var labelfavouriteCount: UILabel!
    @IBOutlet weak var labelComments: UILabel!
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var buttonComments: UIButton!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgWallPost: UIImageView!
    @IBOutlet weak var buttonFavourite: UIButton!
    @IBOutlet weak var buttonUnFavourite: UIButton!
    @IBOutlet weak var htColorView: NSLayoutConstraint!
    @IBOutlet weak var htImages: NSLayoutConstraint!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var RedCorner: UIImageView!
    @IBOutlet weak var buttonProfile: UIButton!
    @IBOutlet weak var htLeading: NSLayoutConstraint!
    @IBOutlet weak var htTraling: NSLayoutConstraint!
    @IBOutlet weak var verifiedMarker: UIImageView!
    @IBOutlet weak var originPostUV: UIView!
    @IBOutlet weak var originPostUVHeight: NSLayoutConstraint!
    @IBOutlet weak var originPostUserAvatar: UIImageView!
    @IBOutlet weak var originPostTitle: UILabel!
    @IBOutlet weak var originPostTime: UILabel!
    @IBOutlet weak var originPostActionUB: UIButton!
    @IBOutlet weak var originWallUV: UIView!
    @IBOutlet weak var originWallUserAvatar: UIImageView!
    @IBOutlet weak var originWallUserName: UILabel!
    @IBOutlet weak var originWallUserVerified: UIImageView!
    @IBOutlet weak var originWallCreatedTime: UILabel!
    @IBOutlet weak var originWallContent: UILabel!
    @IBOutlet weak var originWallExtra: UIImageView!
    @IBOutlet weak var originWallExtraHeight: NSLayoutConstraint!
    @IBOutlet weak var remuroUB: DesignableButton!
    @IBOutlet weak var originWallRemuroUB: UIButton!
    @IBOutlet weak var originWallComentUB: UIButton!
    @IBOutlet weak var originWallExtraUB: UIButton!
    @IBOutlet weak var tagListUV: TagListView!
    @IBOutlet weak var recentWallUV: UIView!
    @IBOutlet weak var viewCntUV: UIView!
    @IBOutlet weak var viewCntLB: UILabel!
    @IBOutlet weak var viewCntLayout: NSLayoutConstraint!
    @IBOutlet weak var lastCommentUV: UIView!
    @IBOutlet weak var lastCommentUserUIMG: UIImageView!
    @IBOutlet weak var answerCntLB: UIButton!
    @IBOutlet weak var destacarUB: UIButton!
    
    var tagArr: [TagModel] = [TagModel]()
    
    var delegate: WallTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tagListUV.textFont = .systemFont(ofSize: 14.0)
        tagListUV.tagBackgroundColor = .clear
        tagListUV.textColor = UIColor(named: "lighter_gray")!
        
        tagListUV.delegate = self
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
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

extension WallTableViewCell: TagListViewDelegate {
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
