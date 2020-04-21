//
//  LaunchViewDelay.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-03-09.
//  Copyright © 2020 Samuel Tsokwa. All rights reserved.
//


import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import ProgressHUD
import Kingfisher


struct datafromload
{
    let chat : [Chat]?
    let contactsnames : [User]?
}
class LaunchViewDelay: UIViewController {

    var Chats = [Chat]()
    var ChatsDictionary = [String: Chat]()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }
    
   
    
    
    
    @objc func presentMainView()
    {
        print(Chats)
        self.performSegue(withIdentifier: "launchtomain", sender: self.Chats)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "launchtomain"
        {
            if let destinationVC = segue.destination as? UserProfileController
            {
                if let chats = sender as? [Chat]?
                {
                    destinationVC.Chats = chats!
                }

            }

        }
    }
   

}
