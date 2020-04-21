//
//  LoadData.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-03-25.
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

class LoadData
{
    var Contacts = [User]()
    var users = [User]()
    var Chats = [Chat]()
    var ChatsDictionary = [String: Chat]()
    
    var otheruseristyping = false
    var timer : Timer?
    var currentuser = User()
    var contactsdictionary = [String: User]()
    var usersdictionary = [String: User]()
    //static let shared = LoadData()

    
    
    
    
    func loadChats(chatCompletion : @escaping(([Chat]) -> Void))
    {
        guard let uid = Auth.auth().currentUser?.uid else{ return }
        GlobalReferences().databaseChat.observeSingleEvent(of :.value) { (snapshot) in
             if let dictionary = snapshot.value as? [String: AnyObject]
               {
                   for data in dictionary
                   {
                       if data.value["chatpartner1"] as! String == uid || data.value["chatpartner2"] as! String == uid
                       {
                           if data.value["Messages"] as? [String:Any] == nil
                           {
                               
                               return
                           }
                           let chat = Chat()
                           chat.chat_id = data.value["chatid"] as? String
                           chat.sender_name = data.value["sendername"] as? String
                           chat.receiver_name = data.value["receiver"] as? String
                           chat.chatpartner1 = data.value["chatpartner1"] as? String
                           chat.chatpartner2 = data.value["chatpartner2"] as? String
                           chat.chat_time = data.value["chattime"] as? String

                           
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
                               chat.messages.append(messobj)
                           }
                           
                           
                           chat.messages.sort { (Message1, Message2) -> Bool in
                                      let formatterGet = DateFormatter()
                                      formatterGet.dateStyle = .short
                                      formatterGet.timeStyle = .medium
                                      formatterGet.locale = Locale(identifier: "en_US_POSIX")

                                      let date1FromString = formatterGet.date(from: Message1.time!)!
                                      let date2FromString = formatterGet.date(from: Message2.time!)!
                              
                              
                                      return date1FromString < date2FromString
                                  }
                           
                           self.ChatsDictionary[chat.chat_id!] = chat
                           self.Chats = Array(self.ChatsDictionary.values)
                           self.Chats.sort { (chat1, chat2) -> Bool in
                                      let formatterGet = DateFormatter()
                                      formatterGet.dateStyle = .short
                                      formatterGet.timeStyle = .medium
                                      formatterGet.locale = Locale(identifier: "en_US_POSIX")
                                      let date1FromString = formatterGet.date(from: chat1.messages[chat1.messages.count-1].time!)
                                      let date2FromString = formatterGet.date(from: chat2.messages[chat2.messages.count-1].time!)
                                      return date1FromString! > date2FromString!
                                  }
                           
             
                        DispatchQueue.main.async {
                            self.reloadofTable()
                            chatCompletion(self.Chats)
                        }
                        
                             
                           
                       }
                       
                   }
                   
               }
            
            
        }
        
  
    }
    
    func loadContacts(contactCompletion : @escaping(([User]) -> Void))
    {
                
        guard let uid = Auth.auth().currentUser?.uid else{return}
        
//        GlobalReferences().databaseSpecificUserReference(uid: uid).observe(.value)
//        { (snapshot) in
//
//            if let dictionary = snapshot.value as? [String: AnyObject]
//            {
//                self.currentuser.email = dictionary["email"] as? String
//                self.currentuser.username = dictionary["username"] as? String
//                self.currentuser.profileImageUrl = dictionary["profileImageUrl"] as? String
//                self.currentuser.uid = dictionary["uid"] as? String
//                if dictionary["Contacts"] == nil{return}
//                for user in (dictionary["Contacts"] as? [String: AnyObject])!.values
//                {
//                    GlobalReferences().databaseSpecificUserReference(uid: user["uid"] as! String).observeSingleEvent(of: .value)
//                    { (snapshot) in
//                        if let dictionary = snapshot.value as? [String: AnyObject]
//                        {
//                            let user = User()
//                            user.email = dictionary["email"] as? String
//                            user.username = dictionary["username"] as? String
//                            user.profileImageUrl = dictionary["profileImageUrl"] as? String
//                            user.uid = dictionary["uid"] as? String
//                            self.contactsdictionary[user.uid!] = user
//                        }
//                        self.Contacts = Array(self.contactsdictionary.values)
//
//                        print("from",Array(self.contactsdictionary.values))
//                        //let contains = self.Contacts.contains(Array(self.contactsdictionary.values))
//                            contactCompletion(self.Contacts)
//
//                    }
//
//                }
//            }
//
//        }
        GlobalReferences().databaseSpecificUserReference(uid: uid).child("Contacts").observe( .value) { (snapshot) in
                   if let dictionary = snapshot.value as? [String: AnyObject]
                   {
                        for data in  dictionary
                        {
                            let user = User()
                            user.email =  data.value["email"]  as? String
                            user.username = data.value["username"]  as? String
                            user.profileImageUrl = data.value["profileImageUrl"]  as? String
                            user.uid = data.value["uid"]  as? String
                            self.contactsdictionary[user.email!] = user
                           //self.printc(user: Array(self.contactsdictionary.values))
                        }
                    
                        self.Contacts = Array(self.contactsdictionary.values)
                        contactCompletion(self.Contacts)
                        

                   }
           
               }
        
    }
    func checkdup(user : User) -> Bool
    {
        for u in self.Contacts
        {
            if u.uid == user.uid
            {return true}
        }
        return false
    }
   
    func loadAllUsers(usersCompletion : @escaping(([User]) -> Void))
    {
        GlobalReferences().databaseUsers.observeSingleEvent( of:  .value) { (snapshot) in
            

            if let dictionary = snapshot.value as? [String: AnyObject]
            {

                for users in dictionary.values
                {
                    let user = User()
                    user.email = users["email"] as? String
                    user.username = users["username"] as? String
                    user.profileImageUrl = users["profileImageUrl"] as? String
                    user.uid = users["uid"] as? String
                    self.usersdictionary[user.uid!] = user
                    self.users = Array(self.usersdictionary.values)
                    
                    usersCompletion(self.users)
                }
            }
            
        }
        
    }
    func reloadofTable()
    {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleReload), userInfo: nil, repeats: false)
    }
    
    @objc func handleReload()
    {
        self.Contacts = Array(self.contactsdictionary.values)
//        self.Chats = Array(self.ChatsDictionary.values)
//        Chats.sort { (chat1, chat2) -> Bool in
//                   let formatterGet = DateFormatter()
//                   formatterGet.dateStyle = .short
//                   formatterGet.timeStyle = .medium
//                   formatterGet.locale = Locale(identifier: "en_US_POSIX")
//                   let date1FromString = formatterGet.date(from: chat1.messages[chat1.messages.count-1].time!)
//                   let date2FromString = formatterGet.date(from: chat2.messages[chat2.messages.count-1].time!)
//                   return date1FromString! > date2FromString!
//               }
//
//            DispatchQueue.main.async {
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
//               // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
//
//          }
    }


}


