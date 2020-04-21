//
//  Notifications.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-03-22.
//  Copyright © 2020 Samuel Tsokwa. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import ProgressHUD
import Kingfisher
import AVFoundation
import MobileCoreServices
import UserNotifications

class Notifications
{
    
    let uid = Auth.auth().currentUser?.uid
    var chat_count = 0
    let userNotificationCenter = UNUserNotificationCenter.current()
    var chatsArray = [Chat]()

    var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func registerBackgroundTask() {
      backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
        self?.endBackgroundTask()
      }
      assert(backgroundTask != .invalid)
    }

    func endBackgroundTask() {
      print("Background task ended.")
      UIApplication.shared.endBackgroundTask(backgroundTask)
      backgroundTask = .invalid
    }
//    @objc func reinstateBackgroundTask() {
//      if updateTimer != nil && backgroundTask ==  .invalid {
//        registerBackgroundTask()
//      }
//    }

    func observeChats()
    {
        
        registerBackgroundTask()
        print("observing")
        GlobalReferences().databaseChat.observe(.value)
        { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                
                
                for data in dictionary
                {
                    let mychat = data.value["chatpartner1"] as? String == self.uid || data.value["chatpartner2"] as? String == self.uid
                    if mychat
                    {
                        
                        let chatitem = Chat()
                        chatitem.chat_id = data.value["chatid"] as? String
                        chatitem.sender_name = data.value["sendername"] as? String
                        chatitem.receiver_name = data.value["receiver"] as? String
                        chatitem.chatpartner1 = data.value["chatpartner1"] as? String
                        chatitem.chatpartner2 = data.value["chatpartner2"] as? String
                        chatitem.chat_time = data.value["chattime"] as? String

                        
                        for messages in (data.value["Messages"] as? [String:Any])!
                        {
                            if (messages.value as! [String:Any])["imageurl"] == nil
                            {
                                
                            }
                            let messobj = Message()
                            messobj.receiver_uid = (messages.value as! [String:Any])["receiver_uid"] as? String
                            messobj.sender_uid = (messages.value as! [String:Any])["sender_uid"] as? String
                            messobj.text = (messages.value as! [String:Any])["text"] as? String
                            messobj.time = (messages.value as! [String:Any])["time"] as? String
                            messobj.seenstatus = (messages.value as! [String:Any])["seenstatus"] as? String
                            messobj.messageid = (messages.value as! [String:Any])["messageid"] as? String
                            chatitem.messages.append(messobj)
                        }
                        
                        
                        chatitem.messages.sort { (Message1, Message2) -> Bool in
                                   let formatterGet = DateFormatter()
                                   formatterGet.dateStyle = .short
                                   formatterGet.timeStyle = .medium
                                   formatterGet.locale = Locale(identifier: "en_US_POSIX")

                                   let date1FromString = formatterGet.date(from: Message1.time!)!
                                   let date2FromString = formatterGet.date(from: Message2.time!)!
                           
                           
                                   return date1FromString < date2FromString
                               }
                        self.chatsArray.append(chatitem)
                        if self.chatsArray.contains(where: { (chat) -> Bool in
                            chat.chat_id != chatitem.chat_id!
                        }) == false
                        {
                            print("chat")
                            self.chat_count += 1
                            self.sendNotification(chatitem: chatitem)
                        
                        }
                    }
                    else{return}
                    
                }
            }
            
        }
//        registerBackgroundTask()
        
          endBackgroundTask()
        
    }
    func sendNotification(chatitem : Chat)
    {
        
            let notificationContent = UNMutableNotificationContent()

            notificationContent.title = chatitem.sender_name!
            notificationContent.badge = NSNumber(integerLiteral: self.chat_count)
            notificationContent.body = chatitem.messages[chatitem.messages.count-1].text!
            notificationContent.sound = UNNotificationSound.default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10,
            repeats: false)
            let request = UNNotificationRequest(identifier: "testNotification",
            content: notificationContent,
            trigger: trigger)
            self.userNotificationCenter.add(request) { (error) in
                if let error = error {
                    print("Notification Error: ", error)
                }
                else{print("success")}
            }
    }
}
