//
//  SearchViewCell.swift
//  adimvi
//
//  Created by javed carear  on 30/09/19.
//  Copyright © 2019 webdesky.com. All rights reserved.
//

import UIKit

class SearchViewCell: UITableViewCell {
    @IBOutlet weak var labelSearchTitle: UILabel!
     @IBOutlet weak var buttonTab: UIButton!
    @IBOutlet weak var imageUsers: UIImageView!
    @IBOutlet weak var WtImage: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }

}
