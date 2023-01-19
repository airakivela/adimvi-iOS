//
//  GuideCell.swift
//  adimvi
//
//  Created by Aira on 29.11.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit

class GuideCell: UICollectionViewCell {

    @IBOutlet weak var guideUIMG: UIImageView!
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var contentLB: UILabel!
    @IBOutlet weak var subContentLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configCell(model: GuideModel) {
        guideUIMG.image = model.imgRes
        titleLB.text = model.title
        contentLB.text = model.content
        subContentLB.text = model.subContent
        subContentLB.isHidden = model.subContent.isEmpty
    }

}
