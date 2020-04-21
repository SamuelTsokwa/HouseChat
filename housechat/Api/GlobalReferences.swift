//
//  GlobalReferences.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-03-02.
//  Copyright © 2020 Samuel Tsokwa. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import ProgressHUD

let REF_USER = "users"
let ROOT_STORAGE_URL = "gs://housechatrevamp.appspot.com"
let STORAGE_PROFILE = "profile"
let STORAGE_MESSAGE_MEDIA = "messagemedia"
let UID = "uid"
let USERNAME = "username"
let EMAIL = "email"
let CONTACT_LIST  = "contact_list"
let PROFILE_IMAGE_URL = "profileImageUrl"
let EMPTY_USERNAME_ERROR = "Please enter a usernmae"
let EMPTY_EMAIL_ERROR = "Please enter a valid email address"
let INVALID_PASSWORD_ERROR = "Please enter a valid password"
let SELECT_AVATAR_ERROR = "Please select an avatar image"
var uidva = ""
let CHAT_REF = "Chats"
//let MESSAGE_REF = "Message"

class GlobalReferences
{
    
    // Database Reference
    let databaseRoot: DatabaseReference = Database.database().reference()
    var databaseUsers: DatabaseReference
    {
        return databaseRoot.child(REF_USER)
    }
    
    func databaseSpecificUserReference(uid: String) -> DatabaseReference
    {
        return databaseUsers.child(uid)
    }
    
    var databaseChat : DatabaseReference
    {
        return databaseRoot.child(CHAT_REF)
    }
    
    func databaseSpecificChatReference(chatid: String) -> DatabaseReference
    {
           return databaseChat.child(chatid)
    }
    
//    var databaseMessage : DatabaseReference
//    {
//        return databaseChat.child(MESSAGE_REF)
//    }
    
    let storageRoot: StorageReference = Storage.storage().reference(forURL: ROOT_STORAGE_URL)
    var storageProfile: StorageReference
    {
        return storageRoot.child(STORAGE_PROFILE)
    }
    var storagemessagemedia : StorageReference
    {
        return storageRoot.child(STORAGE_MESSAGE_MEDIA)
    }
    
    func storageSpecificProfile(uid: String) -> StorageReference
    {
        storageProfile.child(uid)
    }
    
}
