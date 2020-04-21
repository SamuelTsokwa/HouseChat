//
//  InChatNotifications.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-04-05.
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
import SwiftEntryKit


class inChatNotifications
{
    func observeChats()
    {
        GlobalReferences().databaseChat.observe(.childChanged) { (snap) in
            print("seen vibes")
        }
    }
    func sendNotification()
    {
            var attributes = EKAttributes.topToast
            attributes.entryBackground = .color(color: .black)
                     attributes.entranceAnimation = .translation
                     attributes.exitAnimation = .translation
                     attributes.statusBar = .inferred
                     attributes.windowLevel = .statusBar
                     attributes.position = .top

                    let style = EKProperty.LabelStyle(font: .italicSystemFont(ofSize: 20), color: .white, alignment: .center)
                     let title = EKProperty.LabelContent(text: "hiiiii", style: style)
                     let description = EKProperty.LabelContent(text: "msg", style: style)
                     let simpleMessage = EKSimpleMessage(title: title, description: description)
                     let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)

                     let contentView = EKNotificationMessageView(with: notificationMessage)

                     SwiftEntryKit.display(entry: contentView, using: attributes)
    }
}
