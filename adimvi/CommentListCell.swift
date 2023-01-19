//
//  CommentListCell.swift
//  adimvi
//
//  Created by Aira on 4.01.2022.
//  Copyright © 2022 webdesky.com. All rights reserved.
//

import UIKit

protocol CommentListCellDelegate {
    func didTapMentionsUser(userID: String)
}

class CommentListCell: UITableViewCell {

    @IBOutlet weak var labelUserPoint: UILabel!
    @IBOutlet weak var buttonComment: UIButton!
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var buttonProfile: UIButton!
    @IBOutlet weak var labelCommentTime: UILabel!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var labelComments: UILabel!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var labelNetVote: UILabel!
    @IBOutlet weak var recentWallUV: UIView!
    
    
    @IBOutlet weak var buttonSelectDislike: UIButton!
    @IBOutlet weak var buttonSelectLike: UIButton!
    @IBOutlet weak var buttonUnlikeDisable: UIButton!
    @IBOutlet weak var buttonlikeDisable: UIButton!
    @IBOutlet weak var ButtonLike: UIButton!
    @IBOutlet weak var DisLike: UIButton!
    @IBOutlet weak var verifiedMarker: UIImageView!
    @IBOutlet weak var verifiedMarkerWidth: NSLayoutConstraint!
    @IBOutlet weak var lastCommentUV: UIView!
    @IBOutlet weak var lastCommentUserUIMG: UIImageView!
    @IBOutlet weak var answerCntLB: UIButton!
    
    var delegate: CommentListCellDelegate?
    
    var mentionUserInfo: [String: String] = [String: String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    func handleMention(mentionInfo: [String: String]) {
        mentionUserInfo = mentionInfo
        labelComments.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMention))
        labelComments.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTapMention(gesture: UITapGestureRecognizer) {
        let text = labelComments.text!
        var rects: [CGRect] = [CGRect]()
        for item in mentionUserInfo {
            let range = (text as NSString).range(of: item.key)
            rects.append(labelComments.getRect(range: range))
        }
        
        for i in 0..<rects.count {
            if rects[i].contains(gesture.location(in: gesture.view)) {
                let index = mentionUserInfo.index(mentionUserInfo.startIndex, offsetBy: i)
                delegate?.didTapMentionsUser(userID: mentionUserInfo.values[index])
                break
            }
        }
    }
    
}
