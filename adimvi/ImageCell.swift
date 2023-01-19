//
//  ImageCell.swift
//  FAPaginationLayout
//
//  Created by Fahid Attique on 14/06/2017.
//  Copyright © 2017 Fahid Attique. All rights reserved.

import UIKit

class ImageCell: UICollectionViewCell {
    
     @IBOutlet weak var buttonTap: UIButton!
     @IBOutlet weak var buttonNext: UIButton!
     @IBOutlet weak var buttonback: UIButton!
    @IBOutlet weak var LabelName: UILabel!
    @IBOutlet weak var LabelTitle: UILabel!
    @IBOutlet var wallpaperImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
