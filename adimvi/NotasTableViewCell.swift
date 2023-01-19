//
//  NotasTableViewCell.swift
//  adimvi
//
//  Created by javed carear  on 10/05/1942 Saka.
//  Copyright © 1942 webdesky.com. All rights reserved.
//

import UIKit

class NotasTableViewCell: UITableViewCell {
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var buttonDescription: UILabel!
    @IBOutlet weak var labeltitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }

}
