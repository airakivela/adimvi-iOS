//
//  SalesViewCell.swift
//  adimvi
//
//  Created by javed carear  on 12/07/19.
//  Copyright © 2019 webdesky.com. All rights reserved.
//

import UIKit

class SalesViewCell: UITableViewCell {
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblPostID: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblCreatedDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
