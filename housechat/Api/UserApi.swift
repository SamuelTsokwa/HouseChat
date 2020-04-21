//
//  UserApi.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-03-01.
//  Copyright © 2020 Samuel Tsokwa. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import ProgressHUD


class UserApi
{
    func signUp(withUsername username: String, email: String, password: String, new_avatar_image: UIImage?, onSucess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void)
    {
        
        Auth.auth().createUser(withEmail: email, password: password)
        { (authResult, error) in
            if (error != nil)
            {
                //print(error.debugDescription)
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            if let authdata = authResult
            {
                guard let uid = Auth.auth().currentUser?.uid else{return}
                print(authdata.user.email!)
                let dict: Dictionary<String,Any> =
                    [UID: uid,
                     USERNAME : username,
                     EMAIL: authdata.user.email!,
                     PROFILE_IMAGE_URL: "",
                    ]
                
                       
                guard new_avatar_image != nil
                    else
                    {
                        ProgressHUD.showError(SELECT_AVATAR_ERROR)
                        return
                    }
                guard let imagedata = new_avatar_image?.jpegData(compressionQuality: 0.4)
                else
                {
                    return
                }

                let storageProfile = GlobalReferences().storageSpecificProfile(uid: authdata.user.uid)
                
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpg"
                
                StorageService.savePhoto(username: username, uid: authdata.user.uid, imagedata: imagedata, metadata: metadata, storage_profile_ref: storageProfile, dict: dict, onSucess: {
                    onSucess()
                }, onError: {(error) in onError(error)})
                //nSucess()
//                let user = UserModel.init(data: dict)
//                print(user.email)
                
                
               
                
            }
        }
    }
    
    func logIn(email: String, password: String,  onSucess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) 
    {
        Auth.auth().signIn(withEmail: email, password: password) { (AuthData, error) in
            if error != nil
            {
                onError(error!.localizedDescription)
                return
            }
            if AuthData != nil
            {
                onSucess()
                return
            }
            
        }
    }
    
    func logOut()
    {
        do
        {
            try Auth.auth().signOut()
        }
        catch let signOutError as NSError
        {
          print ("Error signing out: %@", signOutError)
        }
    }
    
    func addContact(adderUID: String, addeeEmail: String,  onSucess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void)
    {
        
        if Auth.auth().currentUser == nil
        {
             onError("Error adding contact")
           return
           
        }
        else
        {
            guard let uid = Auth.auth().currentUser?.uid else{return}
            if uid == adderUID
            {
                GlobalReferences().databaseUsers.observeSingleEvent(of: .value) { (snapshot) in
                              if let dictionary = snapshot.value as? [String: AnyObject]
                              {
                                for (_,data) in dictionary
                                  {
                                    
                                      if data["email"] as! String == addeeEmail || data["username"] as! String == addeeEmail
                                      {
                                        GlobalReferences().databaseSpecificUserReference(uid: data["uid"] as! String).observeSingleEvent(of: .value)
                                        { (snapshot) in
                                            if let dictionary = snapshot.value as? [String: AnyObject]
                                            {
                                                //print(dictionary)
                                                let user = User()
                                                user.email = dictionary["email"] as? String
                                                user.username = dictionary["username"] as? String
                                                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                                                user.uid = dictionary["uid"] as? String
                                                let userinfo = ["email": user.email,"username": user.username,"profileImageUrl": user.profileImageUrl,"uid": user.uid]
                                                let ref = GlobalReferences().databaseSpecificUserReference(uid: uid).child("Contacts")
                                                let childref = ref.childByAutoId()
                                                childref.updateChildValues(userinfo as [AnyHashable : Any])

                                            }
                                            
                                            
                                            
                                            onSucess()
                                        }
                                        
                                      }
                                      
                                      
                                  }
                              }
                          }


            }
 
        }
        
    }
    
    func setUserprofile(user: User, uid : String)
       {
           //let user = User()
           GlobalReferences().databaseSpecificUserReference(uid: uid).observeSingleEvent(of: .value)
           { (snapshot) in
               if let dictionary = snapshot.value as? [String: AnyObject]
               {
                   user.profileImageUrl = dictionary["profileImageUrl"] as? String
               }
           }
       }
    
    func deleteContact( contactuid : String, onSucess: @escaping() -> Void)
    {
        let uid =  Auth.auth().currentUser?.uid
        let reftocontacts = GlobalReferences().databaseSpecificUserReference(uid: uid!).child("Contacts")
             reftocontacts.observeSingleEvent(of: .value) { (snapshot) in
                 if let dictionary = snapshot.value as? [String: AnyObject]
                 {
                     for data in dictionary
                     {
                         if data.value["uid"] as? String == contactuid
                         {
                             let ref = reftocontacts.child(data.key)
                             print(ref)

                             ref.removeValue { (err, dref) in
                                 if err != nil
                                 {
                                     print(err!)

                                 }
                                onSucess()
                             }
                         }
                     }
                 }
             }
    }
    
}
