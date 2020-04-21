//
//  StartChatFromContact.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-03-05.
//  Copyright © 2020 Samuel Tsokwa. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import ProgressHUD
import Kingfisher

class StartChatFromContact: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var Contacts = [User]()
    var messages = [Message]()
    var Chats = [Chat]()
    var currentuser = User()
    var contactsdictionary = [String: User]()
    //var timer = Timer()
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(showContacts), userInfo: nil, repeats: false)
        //print(Chats)
        showContacts()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
//        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self , selector: #selector(loadList), userInfo: nil, repeats: true)
//        self.timer.tolerance = 0.1
        // Do any additional setup after loading the view.
    }
    
    func setupUI()
    {
        self.tableview.tableFooterView = UIView(frame: CGRect.zero)
        self.navigationController?.setNavigationBarHidden(true, animated: true)

    }
    
   
    @objc func showContacts()
    {
                
        guard let uid = Auth.auth().currentUser?.uid else{return}
        
        GlobalReferences().databaseSpecificUserReference(uid: uid).observeSingleEvent( of:  .value)
        { (snapshot) in

            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                self.currentuser.email = dictionary["email"] as? String
                self.currentuser.username = dictionary["username"] as? String
                self.currentuser.profileImageUrl = dictionary["profileImageUrl"] as? String
                self.currentuser.uid = dictionary["uid"] as? String
                if dictionary["Contacts"] == nil{return}
                for user in (dictionary["Contacts"] as? [String: AnyObject])!.values
                {
                    GlobalReferences().databaseSpecificUserReference(uid: user["uid"] as! String).observeSingleEvent(of: .value) { (snapshot) in
                            if let dictionary = snapshot.value as? [String: AnyObject]
                            {
                                    let user = User()
                                    user.email = dictionary["email"] as? String
                                    user.username = dictionary["username"] as? String
                                    user.profileImageUrl = dictionary["profileImageUrl"] as? String
                                    user.uid = dictionary["uid"] as? String
                                    self.contactsdictionary[user.uid!] = user
                                    self.Contacts = Array(self.contactsdictionary.values)
                               // Timer.sch
                                    DispatchQueue.main.async {
                                        self.tableview.reloadSections(NSIndexSet(index:1) as IndexSet, with: .none)
                                    }
                                    
                                    
                            }
                       
                        }
                    
                }
          
                
                DispatchQueue.main.async {
                    self.tableview.reloadData()
                }
                
                
                

            }


        }
        
       
        
                
    }
    
 
    
    

}


extension StartChatFromContact
{
    @objc func loadList()
    {
        //self.tableview.reloadSections(NSIndexSet(index:1) as IndexSet, with: .none)
        print("reload")
        //self.tableview.reloadData()
        //showContacts()
        //Contacts.removeAll()
        self.tableview.reloadSections(NSIndexSet(index:1) as IndexSet, with: .none)
        //showContacts()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0
        {
            
            tableView.deselectRow(at: indexPath, animated: false)
            performSegue(withIdentifier: "addcontactsegue", sender: self)
            return
        }
        
        
        if Chats.count == 0
        {
            print("empty db")

              let chat = Chat()
              
              chat.chatpartner2 = self.Contacts[indexPath.row].uid
              chat.chatpartner1 = currentuser.uid
              chat.sender_name = currentuser.username
              chat.receiver_name = self.Contacts[indexPath.row].username
              chat.messages = [Message]()
              chat.chat_time = ""
              chat.chat_id = "No chat yet"
              self.performSegue(withIdentifier: "tochatcontroller", sender: chat)
            
            
        }
        else
        {
            let haschat = Chats.contains
            { (chat) -> Bool in
                if ((Contacts[indexPath.row].uid == chat.chatpartner1  || Contacts[indexPath.row].uid == chat.chatpartner2) && (currentuser.uid == chat.chatpartner1 || currentuser.uid ==  chat.chatpartner2))
                      {
                          print("Chat between contacts found")
                          self.performSegue(withIdentifier: "tochatcontroller", sender: chat)
                          return true

                      }
                      else
                      {
                          return false
                      }
            }
            if haschat == false
            {
                
           print("No previous chat, create new chat")
                let chat = Chat()
                
                chat.chatpartner2 = self.Contacts[indexPath.row].uid
                chat.chatpartner1 = currentuser.uid
                chat.sender_name = currentuser.username
                chat.receiver_name = self.Contacts[indexPath.row].username
                chat.messages = [Message]()
                chat.chat_time = ""
                chat.chat_id = "No chat yet"
                self.performSegue(withIdentifier: "tochatcontroller", sender: chat)
                        
            }
                      
            
          
        }
        

        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            return 1
        }
        else
        {
            return Contacts.count
        }
     }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
     {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactscell")
        
        
        self.Contacts.sort { (chat1, chat2) -> Bool in
                return chat1.username!.localizedCompare(chat2.username!) == ComparisonResult.orderedAscending}
        if indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactscell", for: indexPath)
            cell.textLabel?.text = "Add Contact"
            cell.detailTextLabel?.text = ""
            cell.imageView?.image = UIImage(systemName: "person.crop.circle.fill.badge.plus")
            return cell
        }
        
        else
        {
            
            let user =  Contacts[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactscell", for: indexPath)
            
            let url = URL(string: user.profileImageUrl!)
            
            //cell.imageView?.kf.setImage(with: url)
            let processor = RoundCornerImageProcessor(cornerRadius: 20)
            cell.imageView?.kf.setImage(
                with: url,
                options: [
                .processor(processor)
                ])
            {
                result in
                switch result {
                case .success( _):
                    cell.textLabel?.text = user.username
                    cell.detailTextLabel?.text = user.email
                    cell.imageView?.image? = (cell.imageView?.image?.resized(toWidth: 50, isOpaque: false))!
                    cell.imageView?.layer.masksToBounds = true
                    cell.imageView?.layer.cornerRadius = 27
                case .failure( _):
                    print()
                }
            }
            return cell

        }
        
        return cell!
     }
     
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
         return 100
     }
     func tableView(_ tableView: UITableView, titleForHeaderInSection
                                 section: Int) -> String? {
        if section == 1
        {return "Contacts"}
        
        return ""
     }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "tochatcontroller"
        {
            if let destinationVC = segue.destination as? ChatMessageControllerViewController
            {
                if let chat = sender as? Chat?
                {
                    destinationVC.chat = chat!
                }
                
            }
             
        }
    }

    
    
}
 
