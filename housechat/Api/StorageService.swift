//
//  StorageService.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-03-01.
//  Copyright © 2020 Samuel Tsokwa. All rights reserved.
//

import Foundation
import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import ProgressHUD
import FirebaseStorage

class StorageService
{
    static func savePhoto(username: String, uid: String, imagedata: Data, metadata: StorageMetadata, storage_profile_ref: StorageReference, dict: Dictionary<String, Any>, onSucess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void)
    {
        storage_profile_ref.putData(imagedata, metadata: metadata, completion:
                           {  (storage,error) in
                               if error != nil
                               {
                                   onError(error!.localizedDescription)
                                   return
                               }
                               
                               storage_profile_ref.downloadURL{ (url, error) in
                                   if let imageurl = url?.absoluteString
                                   {
                                        if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                        {
                                            changeRequest.photoURL = url
                                            changeRequest.displayName = username
                                            changeRequest.commitChanges
                                            {
                                                (error) in
                                                if let error = error
                                                {
                                                    ProgressHUD.showError(error.localizedDescription)
                                                }
                                            }
                                        }
                                        
                                        var tempDictionary = dict
                                        tempDictionary[PROFILE_IMAGE_URL] = imageurl
                                    GlobalReferences().databaseSpecificUserReference(uid: uid).updateChildValues(tempDictionary, withCompletionBlock: {  (error,ref) in
                                            if error == nil
                                            {
                                                ProgressHUD.dismiss()
                                                print("done")
                                                onSucess()
                                            }
                                        })

                                   }
                                
                               }
                               
                           })
    }
}
