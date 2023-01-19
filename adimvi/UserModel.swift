//
//  UserModel.swift
//  adimvi
//
//  Created by Aira on 7.09.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import Foundation
import SwiftyJSON

public class UserModel {
    public var name: String = ""
    public var imageAvatar: String = ""
    public var id: Int = 0
    
    func initWithJSON(data: JSON) {
        name = data["name"].stringValue
        id = data["id"].intValue
        imageAvatar = data["avatarblobid"].stringValue
    }
}
