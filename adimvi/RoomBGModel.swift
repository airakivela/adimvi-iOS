//
//  RoomBGModel.swift
//  adimvi
//
//  Created by Aira on 23.10.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import Foundation
import UIKit

var BGList: [RoomBGModel] = [
    RoomBGModel(isSelected: true, image: UIImage(named: "1background")),
    RoomBGModel(isSelected: false, image: UIImage(named: "2background")),
    RoomBGModel(isSelected: false, image: UIImage(named: "3background")),
    RoomBGModel(isSelected: false, image: UIImage(named: "4background")),
    RoomBGModel(isSelected: false, image: UIImage(named: "5background")),
    RoomBGModel(isSelected: false, image: UIImage(named: "6background"))
]

class RoomBGModel {
    var isSelected: Bool = false
    var image: UIImage?
    
    init(isSelected: Bool, image: UIImage?) {
        self.isSelected = isSelected
        if let bg = image {
            self.image = bg
        }
    }
}
