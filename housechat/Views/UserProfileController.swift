//
//  UserProfileController.swift
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
import Kingfisher
import SideMenu
import SwiftEntryKit


struct datawithlist
{
    let chat : Chat?
    let contactsnames : [String]?
}
class UserProfileController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
  
    
    @IBOutlet var addcontactbtn: UIButton!
    @IBOutlet var scrollview: UIScrollView!
    
    @IBOutlet var collview: UICollectionView!
    @IBOutlet var tableview: UITableView!
    var delegate : arrayset?
    var contactsDictionary = [String: User]()
    var Chats = [Chat]()
    var Contacts = [User]()
    var currentuser = User()
    var contactsnames = [String]()
    var navright : UIBarButtonItem?
    var editModeEnabled = false
    var navigationBarOriginalOffset : CGFloat?
    var originalrect : CGRect?
    var ChatsDictionary = [String: Chat]()
    var otheruseristyping = false
    var timer : Timer?
    var timer1 : Timer?
    var loadedData = LoadData.init()
    var usersCompletedArray : [User] = []
    {
           didSet
           {
               setArrayProp()
           }
    }

//    var contactsCompletedArray : [User] = []
//    {
//        didSet
//        {
//            setArrayProp()
//        }
//    }
//    var chatCompletedArray : [Chat] = []
//    {
//        didSet
//        {
//            setArrayProp()
//        }
//    }
    lazy var blankMessagesView : UIView =
    {
        let view = UIView()
        view.frame = self.tableview.frame
        view.backgroundColor = UIColor(named: "toolbox")
        
        
        return view
    }()
    
    func setArrayProp(){

        for user in usersCompletedArray
        {
            if user.uid == Auth.auth().currentUser?.uid
            {
                self.currentuser = user
            }
        }
   
        self.tableview.reloadData()
        self.collview.reloadData()


    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateuser()
        NotificationCenter.default.addObserver(self, selector: #selector(loadAgain), name: NSNotification.Name(rawValue: "load"), object: nil)
        self.registerChatViewCell()
        self.tableview.allowsMultipleSelectionDuringEditing = true
        
        setUPUI()
        showChats()
        showContacts()
        

        loadedData.loadAllUsers { (usersCompletion) in
             self.usersCompletedArray = usersCompletion
         }
//
        
        
        let image = UIImage(systemName: "line.horizontal.3")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(toggleMenu))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:  "Edit", style: .plain, target: self, action: #selector(navrightTapped(sender:)))
        navright = navigationItem.rightBarButtonItem
        
        
  
//        let const = NSLayoutConstraint(item: scrollview!, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 200)
//        const.isActive = true
        print(view.frame.width, scrollview.frame.width)

        
    }

    func setUPUI()
    {
        self.tableview.tableFooterView = UIView(frame: CGRect.zero)
        self.addcontactbtn.addTarget(self, action: #selector(addContact), for: .touchUpInside)
      
    }
    @objc func addContact()
    {
        if let presentedViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddContactController") {
                      presentedViewController.providesPresentationContextTransitionStyle = true
                      presentedViewController.definesPresentationContext = true
                      presentedViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
                      presentedViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.85)
                      self.present(presentedViewController, animated: true, completion: nil)
                  }
    }
    @objc func loadAgain()
    {

        self.reloadofCollView()
        self.reloadofTable()
    }
    
    
    func authenticateuser()
    {
        if Auth.auth().currentUser == nil
        {
            DispatchQueue.main.async
            {
                print("not logged in ")
                self.performSegue(withIdentifier: "userprofile_to_signin", sender: self)
            }
        }
    }
    
    func registerChatViewCell()
    {
        let ChatViewCell = UINib(nibName: "ChatViewCell", bundle: nil)
        let ContactsCell = UINib(nibName: "ContactsCell", bundle: nil)
        self.tableview.register(ChatViewCell, forCellReuseIdentifier: "ChatViewCell")
        self.collview.register(ContactsCell, forCellWithReuseIdentifier: "ContactsCell")
    }
    
    
    
}

extension UserProfileController
{
    func showContacts()
    {
        guard let uid = Auth.auth().currentUser?.uid else{return}
        GlobalReferences().databaseSpecificUserReference(uid: uid).child("Contacts").observe( .value)
        { (snapshot) in
                   if let dictionary = snapshot.value as? [String: AnyObject]
                   {
                        for data in  dictionary
                        {
                            let user = User()
                            user.email =  data.value["email"]  as? String
                            user.username = data.value["username"]  as? String
                            user.profileImageUrl = data.value["profileImageUrl"]  as? String
                            user.uid = data.value["uid"]  as? String
                            self.contactsDictionary[user.uid!] = user
                        }
                  
                        
                        DispatchQueue.main.async
                        {
                            self.reloadofCollView()
                        }
                   }
           
        }

    }
    
    func showChats()
    {
        guard let uid = Auth.auth().currentUser?.uid else{ return }
        GlobalReferences().databaseChat.observe(.value) { (snapshot) in
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
                 
                           
             
                        DispatchQueue.main.async {
                            
                            self.reloadofTable()
                           
                        }
                        
                             
                           
                       }
                       
                   }
                   
               }
            
            
        }
    }
    
    
    
    
    
    
    
    @objc func viewnavtransitions()
    {
        performSegue(withIdentifier: "add_contact_segue", sender: self)
    }
    @objc func seguetocontacts()
    {
        //performSegue(withIdentifier: "contactslist", sender: Chats)
       
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
         return 15
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        //print(Contacts.count)
           // return Contacts.count
        return Contacts.count
    }
      
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        

            let contact = self.Contacts[indexPath.row]
            let cell = self.collview.dequeueReusableCell(withReuseIdentifier: "ContactsCell", for: indexPath) as? ContactsCell
            if self.navigationItem.rightBarButtonItem!.title == "Edit"
            {
                cell!.deleteview.isHidden = true
            }
            else
            {
                cell!.deleteview.isHidden = false
            }
            cell?.contactname.text = contact.username
            cell?.contactimage?.layer.cornerRadius = (cell?.contactimage.frame.height)! / 2
            let url = URL(string: contact.profileImageUrl!)
            let processor = RoundCornerImageProcessor(cornerRadius: (cell?.contactimage.frame.height)! / 2)
            cell?.contactimage?.kf.setImage(
                with: url,
                options: [
                .processor(processor)
                ])
            {
                result in
                switch result {
                case .success( _):
                    cell?.contactimage?.layer.masksToBounds = true

                    cell?.contactname.text = contact.username
                case .failure( _):
                    print()
                }
            }
            cell?.deletebutton.layer.setValue(indexPath.row, forKey: "index")
            cell?.deletebutton.addTarget(self, action: #selector(deleteContactsCell(sender:)), for: .touchUpInside)
            return cell!
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
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
                  let data = datawithlist(chat: chat, contactsnames: self.contactsnames)
                  self.performSegue(withIdentifier: "tomessagescontroller", sender: data)


            }
            else
            {
                let haschat = Chats.contains
                { (chat) -> Bool in
                    if ((Contacts[indexPath.row].uid == chat.chatpartner1  || Contacts[indexPath.row].uid == chat.chatpartner2) && (currentuser.uid == chat.chatpartner1 || currentuser.uid ==  chat.chatpartner2))
                          {
                              print("Chat between contacts found")
                              let data = datawithlist(chat: chat, contactsnames: self.contactsnames)
                              self.performSegue(withIdentifier: "tomessagescontroller", sender: data)
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
                    let data = datawithlist(chat: chat, contactsnames: self.contactsnames)
                    self.performSegue(withIdentifier: "tomessagescontroller", sender: data)

                }



            }
        
    }
      
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Chats.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableview.deselectRow(at: indexPath, animated: true)
        let data = datawithlist(chat: Chats[indexPath.row], contactsnames: self.contactsnames)
        self.performSegue(withIdentifier: "tomessagescontroller", sender: data )
    }

    //
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let selectedchat = Chats[indexPath.row]
        let ref = GlobalReferences().databaseSpecificChatReference(chatid: selectedchat.chat_id!)
        ref.removeValue { (error, dbreference) in
            if error != nil
            {
                print(error!.localizedDescription)
            }
            
            
        }
        DispatchQueue.main.async {
            self.ChatsDictionary.removeValue(forKey: selectedchat.chat_id!)
            self.reloadofTable()
            //self.Chats.remove(element: selectedchat)
            //self.tableview.reloadData()
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        _ = tableView.dequeueReusableCell(withIdentifier: "ChatViewCell") as? ChatViewCell
        
        let uid = Auth.auth().currentUser?.uid
        let chatatrow = self.Chats[indexPath.row]
        let chatmessages = chatatrow.messages
        let checkmark = "✓ "

        if uid == self.Chats[indexPath.row].chatpartner1
        {
           
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatViewCell") as? ChatViewCell
            cell?.profileimage.layer.cornerRadius = (cell?.profileimage.frame.height)! / 2
            cell?.profileimage.clipsToBounds = true
            GlobalReferences().databaseSpecificUserReference(uid: self.Chats[indexPath.row].chatpartner2!).observeSingleEvent(of: .value)
            { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]
                {
                    let url = URL(string: dictionary["profileImageUrl"] as! String)
                    let processor = RoundCornerImageProcessor(cornerRadius: (cell?.profileimage.frame.height)! / 2)
                    cell?.profileimage.layer.masksToBounds = true
                    cell?.profileimage.clipsToBounds = true
                    cell?.profileimage.translatesAutoresizingMaskIntoConstraints = false
                    cell?.profileimage?.kf.setImage(
                        with: url,
                        options: [
                        .processor(processor)
                        ])
                    {
                        result in
                        switch result {
                        case .success( _):
                            if self.contactsnames.contains((dictionary["username"] as? String)!)
                            {
                                cell?.contactname.text = dictionary["username"] as? String
                            }
                            else
                            {
                                var finaltext = ""
                                finaltext.append("Maybe : " )
                                finaltext.append((dictionary["username"] as? String)!)
                                cell?.contactname.text = finaltext
                            }
                            
                            self.Chats[indexPath.row].receiver_name = dictionary["username"] as? String
          
                            if self.Chats[indexPath.row].messages[self.Chats[indexPath.row].messages.count - 1].sender_uid == uid
                            {
                                if chatmessages[chatmessages.count-1].seenstatus == "seen"
                                {
                                    let string = chatmessages[chatmessages.count-1].text!
                                    let attributedString = NSAttributedString(string: string)
                                    let attr : [NSAttributedString.Key : Any] = [NSAttributedString.Key.strokeWidth: -5.0,NSAttributedString.Key.foregroundColor: UIColor.systemBlue, NSAttributedString.Key.strokeColor : UIColor.systemBlue]
                                    let bluecheckmark = NSAttributedString(string: "✓ ", attributes: attr)
                                    let result = NSMutableAttributedString()
                                    result.append(bluecheckmark)
                                    result.append(attributedString)
                                    
                                    
                                    cell?.chattext.attributedText = result

                               
                                    
                                }
                                else
                                {
                                 
                                    cell?.chattext.text = checkmark + chatmessages[chatmessages.count-1].text!
                                }
                                
                            }
                            else
                            {
                               cell?.chattext.text = chatmessages[chatmessages.count-1].text!
                            }

                            cell?.chattext.textColor = UIColor.lightGray
                            //cell?.profileimage.image = (cell?.profileimage.image?.resized(toWidth: 54, isOpaque: false))!
                           
//                            if (chatmessages[chatmessages.count-1].seenstatus == "seen") && (chatmessages[chatmessages.count-1].receiver_uid == uid)
//                            {
//                                let seencheckmark = checkmark.attributedStringWithColor([checkmark], color: UIColor.systemBlue)
//                                cell?.chattext.text = seencheckmark.string + chatmessages[chatmessages.count-1].text!
//
//                            }
                            let date = chatmessages[chatmessages.count-1].time!.split(separator: ",")
                            cell?.chattime.text = String(date[0])
//                            if chatmessages[chatmessages.count-1].sender_uid == uid
//                           {
//                               chatmessages[chatmessages.count-1].seenstatus = "seen"
//
//                           }
                            if chatmessages[chatmessages.count-1].seenstatus != "seen" && chatmessages[chatmessages.count-1].sender_uid != uid
                            {
                                cell?.numberofunread.image = UIImage(systemName: "circle.fill")
                            }
                          
                            
                        case .failure( _):
                            print()
                        }
                    }
                }
            }
            return cell!
            
        }
        else
        {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatViewCell") as? ChatViewCell
            cell?.profileimage.layer.cornerRadius = (cell?.profileimage.frame.height)! / 2
            cell?.profileimage.clipsToBounds = true
            GlobalReferences().databaseSpecificUserReference(uid: self.Chats[indexPath.row].chatpartner1!).observeSingleEvent(of: .value)
            { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]
                {
                    let url = URL(string: dictionary["profileImageUrl"] as! String)
                    cell?.profileimage.layer.masksToBounds = true
                    cell?.profileimage.clipsToBounds = true
                    cell?.profileimage.translatesAutoresizingMaskIntoConstraints = false
                    let processor = RoundCornerImageProcessor(cornerRadius: (cell?.profileimage.frame.height)! / 2)
                    cell?.profileimage?.kf.setImage(
                        with: url,
                        options: [
                        .processor(processor)
                        ])
                    {
                        result in
                        switch result {
                        case .success( _):
                            //cell?.contactname.text = (dictionary["username"] as! String)
                            //self.Chats[indexPath.row].receiver_name = (dictionary["username"] as! String)
                            
                        if self.contactsnames.contains((dictionary["username"] as? String)!)
                        {
                            cell?.contactname.text = dictionary["username"] as? String
                        }
                        else
                        {
                            var finaltext = ""
                            finaltext.append("Maybe : " )
                            finaltext.append((dictionary["username"] as? String)!)
                            cell?.contactname.text = finaltext
                        }
                                                   
               
                           if self.Chats[indexPath.row].messages[self.Chats[indexPath.row].messages.count - 1].sender_uid == uid
                           {
                                if chatmessages[chatmessages.count-1].seenstatus == "seen"
                                {
                                    let string = chatmessages[chatmessages.count-1].text!
                                    let attributedString = NSAttributedString(string: string)
                                    let attr : [NSAttributedString.Key : Any] = [NSAttributedString.Key.strokeWidth: -5.0,NSAttributedString.Key.foregroundColor: UIColor.systemBlue, NSAttributedString.Key.strokeColor : UIColor.systemBlue]
                                    let bluecheckmark = NSAttributedString(string: "✓ ", attributes: attr)
                                    let result = NSMutableAttributedString()
                                    result.append(bluecheckmark)
                                    result.append(attributedString)
                                    cell?.chattext.attributedText = result
                                }
                                else
                                {
                                    cell?.chattext.text = checkmark + chatmessages[chatmessages.count-1].text!
                                }
//                               cell?.chattext.text = checkmark + chatmessages[chatmessages.count-1].text!
                            }
                            
                           else
                           {
                                cell?.chattext.text = chatmessages[chatmessages.count-1].text!
                           }
                            
                            
                            
                            
                            cell?.chattext.textColor = UIColor.lightGray
                            //cell?.profileimage.image = (cell?.profileimage.image?.resized(toWidth: 50, isOpaque: false))!
                            
                            let date = chatmessages[chatmessages.count-1].time!.split(separator: ",")
                            cell?.chattime.text = String(date[0])
//                            if chatmessages[chatmessages.count-1].sender_uid == uid
//                           {
//                               chatmessages[chatmessages.count-1].seenstatus = "seen"
//
//                           }
                            if chatmessages[chatmessages.count-1].seenstatus != "seen" && chatmessages[chatmessages.count-1].sender_uid != uid
                            {
                                cell?.numberofunread.image = UIImage(systemName: "circle.fill")
                            }
                          
                         
                       
                        case .failure( _):
                            print()
                        }
                    }
                }
            }
            return cell!
        }

        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    

    
    @objc func reloadofTable()
    {
        self.timer1?.invalidate()
        self.timer1 = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleReload), userInfo: nil, repeats: false)
    }
    @objc func handleReload()
     {
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
               
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                    self.tableview.reloadData()
                }, completion: nil)
                 
           }
        
     }
    
   
    @objc func reloadofCollView()
    {
          self.timer?.invalidate()
          self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleCollviewReload), userInfo: nil, repeats: false)
    }
    @objc func handleCollviewReload()
    {
        self.Contacts = Array(self.contactsDictionary.values)
        self.Contacts.sort
        { (us1, us2) -> Bool in
               return us1.username!.lowercased() < us2.username!.lowercased()
        }
        self.contactsnames.removeAll()
        for user in Array(self.contactsDictionary.values)
        {
            
            self.contactsnames.append(user.username!)
        }
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                print("setting")
                let sm = self.storyboard?.instantiateViewController(identifier: "menuviewcontroller")
                self.delegate = sm as? arrayset
                self.delegate?.setContact(array: self.Contacts)
                self.collview.reloadData()
            }, completion: nil)
            
        }
    }
   
    
 
    
    @objc func deleteContactsCell(sender:UIButton)
    {
        
        let i: Int = (sender.layer.value(forKey: "index")) as! Int
        guard let contactuid = self.Contacts[i].uid else{return}
        let alert = UIAlertController(title: "Do you want to delete this contact ?", message: "This action will rmeove them from your contacts list", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in

            Api.User.deleteContact(contactuid: contactuid) {
                self.contactsDictionary.removeValue(forKey: contactuid)
                self.reloadofCollView()
                self.reloadofTable()
                
                ProgressHUD.showSuccess("Successfully deleted contact")
            }
            
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
        

        
    }
  
    
    @objc func navrightTapped(sender: AnyObject)
    {
        
        if(editModeEnabled == false)
        {
              // Put the collection view in edit mode
            //let navb = editButtonItem
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.navigationItem.rightBarButtonItem!.title = "Done"
                self.navigationItem.rightBarButtonItem!.style = .done
            }, completion: nil)
            
              editModeEnabled = true

              // Loop through the collectionView's visible cells
            for item in self.collview.visibleCells as! [ContactsCell] {
                let indexPath: IndexPath = self.collview.indexPath(for: item as ContactsCell)!
                let cell: ContactsCell = (self.collview.cellForItem(at: indexPath) as! ContactsCell)
                cell.deleteview.isHidden = false
                
                
              }
        } else {
                  // Take the collection view out of edit mode
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.navigationItem.rightBarButtonItem!.style = .plain
                self.navigationItem.rightBarButtonItem!.title = "Edit"
            }, completion: nil)
            
                  editModeEnabled = false
        
                  // Loop through the collectionView's visible cells
                  for item in self.collview.visibleCells as! [ContactsCell] {
                    let indexPath: IndexPath = self.collview.indexPath(for: item as ContactsCell)!
                   
                        let cell: ContactsCell = (self.collview.cellForItem(at: indexPath) as! ContactsCell)
                        cell.deleteview.isHidden = true // Hide all of the delete buttons
                                       
                  }
              }

    }


 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard let segueData = sender as? datawithlist else{return}
        
        if segue.identifier == "tomessagescontroller"
        {
            if let destinationVC = segue.destination as? ChatMessageControllerViewController
            {
                
                destinationVC.chat = segueData.chat!
                destinationVC.contactsnames = segueData.contactsnames!
                
            }
            
             
        }
        let data = sender as? [User]
        if segue.identifier == "toAddContact"
        {
            if let destinationVC = segue.destination as? AddContactController
            {
                
                destinationVC.Contacts = data!
                
            }
               
                
        }

    }
    @objc func toggleMenu()
    {
        let vc = storyboard?.instantiateViewController(identifier: "menuviewcontroller")
        let menu = SideMenuNavigationController(rootViewController: vc!)
        menu.leftSide = true
        menu.statusBarEndAlpha = 0
        menu.enableTapToDismissGesture = true
        present(menu, animated: true, completion: nil)

    }
    
    func chatPartnerisAContact()
    {
        
    }
     
}

extension UIImage {
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(width))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}

extension Array where Element: Equatable{
    mutating func remove (element: Element) {
        if let i = self.firstIndex(of: element) {
            self.remove(at: i)
        }
    }
}

extension String {
    func attributedStringWithColor(_ strings: [String], color: UIColor, characterSpacing: UInt? = nil) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        for string in strings {
            let range = (self as NSString).range(of: string)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }

        guard let characterSpacing = characterSpacing else {return attributedString}

        attributedString.addAttribute(NSAttributedString.Key.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))

        return attributedString
    }
}
