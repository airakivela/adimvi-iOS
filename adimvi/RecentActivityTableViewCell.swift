
//  RecentActivityTableViewCell.swift
//  adimvi
//  Created by javed carear  on 15/11/19.
//  Copyright © 2019 webdesky.com. All rights reserved.

import UIKit
class RecentActivityTableViewCell: UITableViewCell {
    @IBOutlet weak var labelActivityTitle: UILabel!
    @IBOutlet weak var LabelTime: UILabel!
    @IBOutlet weak var buttonPostDetail: UIButton!
    @IBOutlet weak var buttonActivityName: DesignableButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
