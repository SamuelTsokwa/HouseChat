//
//  chatControllerMethods.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-03-26.
//  Copyright © 2020 Samuel Tsokwa. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import ProgressHUD
import Kingfisher
import AVFoundation


class ChatControllerMethods
{
    var imtyping = false
    var timer : Timer?
    var chatMessageController : ChatMessageControllerViewController?
    lazy var chat = chatMessageController?.chat
    
    @objc func textFieldDidChange(textField: UITextField) {

          print("txtfieldchane")
           self.timer?.invalidate()
           timer = Timer.scheduledTimer(timeInterval: 0.48, target: self, selector: #selector(textFieldStopEditing), userInfo: nil, repeats: false)
           
       
           didStartTyping()
           
       }

    @objc func textFieldStopEditing(sender: Timer)
    {

        didStopTyping()
    }
    
    func didStartTyping()
    {
        if chat?.chat_id == "No chat yet"
       {return}
       let uid = Auth.auth().currentUser?.uid
        let chatatid = GlobalReferences().databaseSpecificChatReference(chatid: (chat?.chat_id!)!)
       let uidistyping = [uid!:"typing"]
       print("is typing ")
       imtyping = true
       chatatid.updateChildValues(uidistyping)
    }
    func didStopTyping()
    {
        if chat!.chat_id == "No chat yet"
       {return}
       let uid = Auth.auth().currentUser?.uid
        let chatatid = GlobalReferences().databaseSpecificChatReference(chatid: (chat?.chat_id!)!)
       let uidistyping = [uid!:"stopped typing"]
       print("stopped typing")
       chatatid.updateChildValues(uidistyping)
    }
}
