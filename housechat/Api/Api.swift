//
//  Api.swift
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




struct Api {
    static var User = UserApi()
    static var chatMethods = ChatControllerMethods()
}
