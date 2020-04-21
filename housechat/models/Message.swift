//
//  Messages.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-03-04.
//  Copyright © 2020 Samuel Tsokwa. All rights reserved.
//

import Foundation

class Message: NSObject {
    var sender_uid : String?
    var receiver_uid : String?
    var time : String?
    var text : String?
    var mediaurl : String?
    var videourl : String?
    var messageid: String?
    var seenstatus : String?
    var imagewidth : NSNumber?
    var imageheight : NSNumber?
    
}


