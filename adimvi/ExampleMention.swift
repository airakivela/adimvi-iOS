//
//  ExampleMention.swift
//  SZMentionsExample
//
//  Created by Steven Zweier on 1/12/16.
//  Copyright © 2016 Steven Zweier. All rights reserved.
//

import SZMentionsSwift
import UIKit
import SwiftyJSON

class ExampleMention: CreateMention {
    var name: String = ""
    var userid: Int = 0
    var userAvatar: String = ""
    
    func initWithJSON(data: JSON) {
        userid = data["id"].intValue
        name = data["name"].stringValue
        userAvatar = data["avatarblobid"].stringValue
    }
}
