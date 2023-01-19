//
//  RoomMessageModel.swift
//  adimvi
//
//  Created by Aira on 25.10.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import Foundation
import SwiftyJSON

class RoomMessageModel {
    var userID: Int = 0
    var userName: String = ""
    var senderAvatar: String = ""
    var senderVerify: Int = 0
    var content: String = ""
    var extra: String = ""
    var format: String = ""
    
    func initWithJSON(jsonObject: JSON) {
        userID = jsonObject["userID"].intValue
        userName = jsonObject["userName"].stringValue
        senderAvatar = jsonObject["senderAvatar"].stringValue.isEmpty ? "" : (WebURL.ImageUrl + jsonObject["senderAvatar"].stringValue);
        senderVerify = jsonObject["senderVerify"].intValue
        content = jsonObject["content"].stringValue
        extra = jsonObject["extra"].stringValue
        format = jsonObject["format"].stringValue
    }
}
