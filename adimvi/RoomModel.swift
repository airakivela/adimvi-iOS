//
//  RoomModel.swift
//  adimvi
//
//  Created by Aira on 23.10.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import Foundation
import SwiftyJSON

func getThousandWithK(value: Int) -> String {
    if value < 1000 {
        return "\(value)"
    } else {
        if value % 1000 == 0 {
            return "\(value / 1000) K"
        } else {
            let floatingVal: CGFloat = CGFloat(Double(value) / 1000.0)
            return String(format: "%.1f K", floatingVal)
        }
    }
}

class RoomModel {
    var roomID: Int = 0
    var adminID: Int = 0
    var adminAvatar: String = ""
    var adminName: String = ""
    var background: UIImage?
    var adminVerify: Int = 0
    var memberCnt: Int = 0
    var title: String = ""
    var isSiguiendo: Int = 0
    
    func initWithJSON(object: JSON) {
        roomID = object["roomID"].intValue
        adminID = object["adminID"].intValue
        adminAvatar = ((object["adminAvatar"].stringValue).isEmpty) ? "" : (WebURL.ImageUrl + object["adminAvatar"].stringValue)
        adminName = object["adminName"].stringValue
        adminVerify = object["adminVerify"].intValue
        background = BGList[object["background"].intValue].image
        memberCnt = object["members"].intValue
        title = object["title"].stringValue
        isSiguiendo = object["siguiendo"].intValue
    }
}
