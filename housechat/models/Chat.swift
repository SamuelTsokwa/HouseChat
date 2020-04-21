//
//  Chat.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-03-05.
//  Copyright © 2020 Samuel Tsokwa. All rights reserved.
//

import Foundation

class Chat: NSObject {
    var chatpartner1 : String?
    var chatpartner2 : String?
    var sender_name : String?
    var receiver_name : String?
    var chat_id : String?
    var chat_time : String?
    var senderisinchat : String?
    var receiverisinchat : String?
    var istypin : String?
    var messages = [Message]()
    
    func getuser( user: User)
    {
        let userinchat = [User]()
        
        
    }
}



