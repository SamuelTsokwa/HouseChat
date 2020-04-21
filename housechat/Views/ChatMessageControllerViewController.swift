//
//  ChatMessageControllerViewController.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-03-13.
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


struct FinalData{
    let title:String?
    let aryData:[Message]?
}


class ChatMessageControllerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    //var messagetextfield: UITextField!
    var videoPlayer : VideoPlayerController?
    @IBOutlet var collview: UICollectionView!
    let cellId = "cellId"
    var chat = Chat()
    var chatmessages = [Message]()
    var MessagesDictionary = [String: Message]()
    var sectionDictionary = [String: [Message]]()
    var allKeys = [String]()
    var aryFinalData = [FinalData]()
    var iminchat = false
    var imtyping = false
    var otheruseristyping = false
    var timer : Timer?
    var startingframe : CGRect?
    var backgroundview : UIView?
    var imageview : UIImageView?
    var Contacts = [User]()
    let headerID = "headerID"
    var playerlayer : AVPlayerLayer?
    let uid = Auth.auth().currentUser?.uid
    var loadedData = LoadData.init()
    var contactName = ""
    var originalcontactName = ""
    var contactsnames = [String]()
    var contactsCompletedArray : [User] = []
    {
        didSet
        {
            setArrayProp()
        }
    }
    func setArrayProp(){
        //self.Chats = chatCompletedArray
        self.Contacts = contactsCompletedArray
       
        //for user in usersCompletedArray{}
        
        for user in contactsCompletedArray
        {
            self.contactsnames.append(user.username!)
        }
        collview.reloadData()
        
        
        
    }

        
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
         

        showChat()
       
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        collview.addGestureRecognizer(tapGesture)
        collview.keyboardDismissMode = .interactive
        
//        NotificationCenter.default.addObserver(self, selector: #selector(showChat), name: NSNotification.Name(rawValue: "load"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(notification:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        setupUI()
        self.collview.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: "cell")
        self.collview.register(Header.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerID)
        
        loadedData.loadContacts { (contactCompletion) in
            self.contactsCompletedArray = contactCompletion
        }
         
              //self.scrollview.addSubview(blankMessagesView)
        
        if chat.chatpartner2! == uid
        {
            
            let isContact =  contactsnames.contains(chat.sender_name!)
            if isContact
            {
                contactName = chat.sender_name!
                originalcontactName = chat.sender_name!
            }
            else
            {
                originalcontactName = chat.sender_name!
                contactName = "Maybe : " + chat.sender_name!
                let img = UIImage(systemName: "person.badge.plus")
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(addUnknownContact))
            }
            
        }
        else
        {
            let isContact =  contactsnames.contains(chat.receiver_name!)
            if isContact
            {
                contactName = chat.receiver_name!
                originalcontactName = chat.receiver_name!
            }
            else
            {
                originalcontactName = chat.receiver_name!
                contactName = "Maybe : " + chat.receiver_name!
                let img = UIImage(systemName: "person.badge.plus")
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(addUnknownContact))            }
            
        }
        self.navigationItem.title = contactName
        
        // Create a basic toast that appears at the top
         
        
        



    }
    
    override func viewDidAppear(_ animated: Bool) {
        collview.scrollToBottom()

    }
    override func viewDidDisappear(_ animated: Bool) {
        //isNotInChat()
    }
   
    
    override var canBecomeFirstResponder: Bool
    {
        return true
    }
    
    override var canResignFirstResponder: Bool
    {
        return true
    }
    
    
    lazy var customView : AccessoryView =
    {
        let inputcontainerview = AccessoryView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        inputcontainerview.backgroundColor = UIColor.black
        inputcontainerview.chatController = self
        return inputcontainerview
        
    }()


    override var inputAccessoryView: UIView?
    {
        return customView
    }

    
    func setupUI()
    {

        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
     
    
    func showChat()
    {
        
        if chat.chat_id == "No chat yet"
        {return}
        
        else
        {
           // print("cooking",self.chat,  chat.chat_id)
        let uid = Auth.auth().currentUser?.uid
        GlobalReferences().databaseSpecificChatReference(chatid:self.chat.chat_id!).observe(.value)
                { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject]
                    {
                        if dictionary["chatpartner1"] as? String == uid
                        {
                            if dictionary[self.chat.chatpartner2!] as? String == "typing"
                            {
                                self.otheruseristyping = true
                                self.navigationItem.title = "typing..."
                                
                            }
                            else
                            {
                                self.otheruseristyping = false
                                self.navigationItem.title = self.contactName
                            }
                        }
                        else if dictionary["chatpartner2"] as? String == uid
                        {
                            if dictionary[self.chat.chatpartner1!] as? String == "typing"
                            {
                                self.otheruseristyping = true
                                self.navigationItem.title = "typing..."
                            }
                            else
                            {
                                self.otheruseristyping = false
                                self.navigationItem.title = self.contactName
                            }
                        }
                   
                        for messagein in dictionary["Messages"] as! [String:Any]
                        {
                            if let item = messagein.value as? [String:Any]
                            {
                               
                                let message = Message()
                                if item["mediaurl"] == nil
                                {
                                    message.receiver_uid = item["receiver_uid"] as? String
                                    message.seenstatus = "seen"
                                    message.sender_uid = item["sender_uid"] as? String
                                    message.text = item["text"] as? String
                                    message.time = item["time"] as? String
                                    message.messageid = item["messageid"] as? String
                                    
                                }
                                else
                                {
                                    message.receiver_uid = item["receiver_uid"] as? String
                                    message.seenstatus = "seen"
                                    message.sender_uid = item["sender_uid"] as? String
                                    message.text = item["text"] as? String
                                    message.time = item["time"] as? String
                                    message.messageid = item["messageid"] as? String
                                    message.mediaurl = item["mediaurl"] as? String
                                    message.imagewidth = item["imagewidth"] as? NSNumber
                                    message.imageheight = item["imageheight"] as? NSNumber
                                    if item["videourl"] != nil
                                    {
                                        message.videourl = item["videourl"] as? String
                                    }
                                }
                                
                                
                                self.MessagesDictionary[message.time!] = message
//                                let date = message.time!.split(separator: ",")
//                                let datefromstring = String(date[0])
                                //self.sectionDictionary[datefromstring] = message
                                
                            
                                
                                self.chatmessages = Array(self.MessagesDictionary.values)
                               
                                self.chatmessages.sort { (m1, m2) -> Bool in
                                    let formatterGet = DateFormatter()
                                    formatterGet.dateStyle = .short
                                    formatterGet.timeStyle = .medium
                                    formatterGet.locale = Locale(identifier: "en_US_POSIX")
                                    let time1FromString = formatterGet.date(from: m1.time!)
                                    let time2FromString = formatterGet.date(from: m2.time!)
                                    return time1FromString! < time2FromString!
                                }

                                DispatchQueue.main.async {
                                    //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                                   // self.collview.reloadData()
                                    self.reloadofTable()
                                    
                                    
                                }
                                
                                
                                
                            }

                            
                        }
                        
                    }
                    
                }
        }
      
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {
        //didStartTyping()
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 0.8,
            target: self,
            selector: #selector(didStopTyping),
            userInfo: nil,
            repeats: false)
        //didStopTyping()
        return true
    }
    
    
//    @objc func textFieldDidChange(textField: UITextField) {
//
//        self.timer?.invalidate()
//        timer = Timer.scheduledTimer(timeInterval: 0.48, target: self, selector: #selector(textFieldStopEditing), userInfo: nil, repeats: false)
//
//
//        didStartTyping()
//
//    }

    @objc func textFieldStopEditing(sender: Timer) {

        didStopTyping()
    }
    
    
    @objc func isInChat()
    {
        let uid = Auth.auth().currentUser?.uid
        let chatatid = GlobalReferences().databaseSpecificChatReference(chatid: chat.chat_id!)
        let uidinchat = [uid!:"inchat"]
        print("entering chat")
        iminchat = true
        chatatid.updateChildValues(uidinchat)
    }
    
    
    @objc func isNotInChat()
    {
        let uid = Auth.auth().currentUser?.uid
        let chatatid = GlobalReferences().databaseSpecificChatReference(chatid: chat.chat_id!)
        let uidinchat = [uid!:"notinchat"]
        print("left chat")
        chatatid.updateChildValues(uidinchat)
    }
    
    
    
    
    @objc func didStartTyping()
    {
        if chat.chat_id == "No chat yet"
        {return}
        let uid = Auth.auth().currentUser?.uid
        let chatatid = GlobalReferences().databaseSpecificChatReference(chatid: chat.chat_id!)
        let uidistyping = [uid!:"typing"]
        print("is typing ")
        imtyping = true
        chatatid.updateChildValues(uidistyping)
    }
    @objc func didStopTyping()
    {
        if chat.chat_id == "No chat yet"
        {return}
        let uid = Auth.auth().currentUser?.uid
        let chatatid = GlobalReferences().databaseSpecificChatReference(chatid: chat.chat_id!)
        let uidistyping = [uid!:"stopped typing"]
        print("stopped typing")
        chatatid.updateChildValues(uidistyping)
    }

    // collectionview set up
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return self.aryFinalData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        22
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        //print("section: ",section,self.aryFinalData[section].aryData!.count)
        return self.aryFinalData[section].aryData!.count

    }
    

    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerid", for: indexPath) as! HeaderView
            header.sectionLabel.text = self.aryFinalData[indexPath.section].title
            header.sectionLabel.tintColor = UIColor.darkGray
            
            return header

        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 60)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //let message = self.chatmessages[indexPath.row].text
        let message = self.aryFinalData[indexPath.section].aryData![indexPath.row].text
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ChatLogMessageCell
        //print(indexPath.section,message)
        cell.messageTextView.textColor = UIColor.white
        
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: message!).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], context: nil)
        
        
        let uid = Auth.auth().currentUser?.uid
        
        if self.aryFinalData[indexPath.section].aryData![indexPath.row].receiver_uid == uid
        {
           //self.chatmessages[indexPath.row].seenstatus = "seen"
           self.aryFinalData[indexPath.section].aryData![indexPath.row].seenstatus = "seen"
           let messageref = GlobalReferences().databaseSpecificChatReference(chatid: self.chat.chat_id!).child("Messages").child((self.aryFinalData[indexPath.section].aryData![indexPath.row].messageid)!)
           let new_seen = ["seenstatus":"seen"]
           messageref.ref.updateChildValues(new_seen)
           //chatatid.updateChildValues(uidinchat)
            //let uidinchat = [uid!:"inchat"]
        }

        //if chatmessages[indexPath.row].receiver_uid == uid
        if self.aryFinalData[indexPath.section].aryData![indexPath.row].receiver_uid == uid
        {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ChatLogMessageCell
            cell.ChatMessageControllerViewController = self
            //cell.messageatindexrow = self.chatmessages[indexPath.row]
            cell.messageatindexrow = self.aryFinalData[indexPath.section].aryData![indexPath.row]
            cell.bubbleImageView.image = ChatLogMessageCell.grayBubbleImage
            cell.bubbleImageView.tintColor = UIColor(named: "aqua")
            
            cell.messageTextView.textColor = UIColor.white
            cell.messageTextView.frame = CGRect(x: 16, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 30)
            cell.textBubbleView.frame = CGRect(x: 4, y: -4, width: estimatedFrame.width + 16 + 8 + 16, height: estimatedFrame.height + 20 + 6)
            if message != "New media item"
            {
               
               cell.messageimageview.isHidden = true
               cell.messageTextView.isHidden = false
               cell.messageTextView.text = message
               
            }
            else if message == "New media item"
            {
               cell.textBubbleView.frame = CGRect(x: -65, y: 0, width: 219, height: 245)
               //let url = URL(string: self.chatmessages[indexPath.row].mediaurl!)
               let url = URL(string: self.aryFinalData[indexPath.section].aryData![indexPath.row].mediaurl!)
               cell.messageimageview.kf.indicatorType = .activity
               cell.messageimageview.backgroundColor = UIColor.clear
               cell.messageimageview.kf.setImage(with: url)
               cell.messageimageview.isHidden = false
               cell.messageTextView.isHidden = true
               
            }
            //cell.playbutton.isHidden = self.chatmessages[indexPath.row].videourl == nil
            cell.playbutton.isHidden = self.aryFinalData[indexPath.section].aryData![indexPath.row].videourl == nil
            cell.messageimageview.isUserInteractionEnabled = cell.playbutton.isHidden
            
            //cell.messageimageview.isUserInteractionEnabled = self.chatmessages[indexPath.row].videourl == nil
            return cell
        }
        
        
        //if chatmessages[indexPath.row].sender_uid == uid
        if self.aryFinalData[indexPath.section].aryData![indexPath.row].sender_uid == uid
        {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ChatLogMessageCell
            cell.ChatMessageControllerViewController = self
           //cell.messageatindexrow = self.chatmessages[indexPath.row]
            cell.messageatindexrow = self.aryFinalData[indexPath.section].aryData![indexPath.row]
            cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 16, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
            cell.textBubbleView.frame = CGRect(x:view.frame.width - estimatedFrame.width - 16 - 8 - 16, y: -4, width: estimatedFrame.width + 16 + 8 + 10, height: estimatedFrame.height + 20 + 6)
            cell.bubbleImageView.image = ChatLogMessageCell.blueBubbleImage
            //cell.bubbleImageView.tintColor = UIColor(named: "texttint")
            cell.bubbleImageView.tintColor = UIColor(named: "red")
            
            if message != "New media item"
            {
                
                
                cell.messageimageview.isHidden = true
                cell.messageTextView.isHidden = false
                cell.messageTextView.text = message
                          
            }
            else if message == "New media item"
            {
                
//                cell.textBubbleView.frame = CGRect(x:65 , y: -4, width: 219, height: 245)
                cell.textBubbleView.frame = CGRect(x:65 , y: -4, width: 219, height: 245)
                cell.bubbleImageView.tintColor = UIColor.clear
                //let url = URL(string: self.chatmessages[indexPath.row].mediaurl!)
                let url = URL(string: self.aryFinalData[indexPath.section].aryData![indexPath.row].mediaurl!)
                cell.messageimageview.kf.indicatorType = .activity
                cell.messageimageview.kf.setImage(with: url)
                cell.messageimageview.isHidden = false
                cell.messageTextView.isHidden = true
            }
            //cell.playbutton.isHidden = self.chatmessages[indexPath.row].videourl == nil
            cell.playbutton.isHidden = self.aryFinalData[indexPath.section].aryData![indexPath.row].videourl == nil
            //cell.messageimageview.isUserInteractionEnabled = self.chatmessages[indexPath.row].videourl == nil
            cell.messageimageview.isUserInteractionEnabled = cell.playbutton.isHidden
            return cell
        }
            return cell
      }

    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let message = self.aryFinalData[indexPath.section].aryData![indexPath.row].text
        if message == "New media item"
        {
            let width = CGFloat(219)
            let height = CGFloat(245)
            return CGSize(width: width, height: height)
            

        }

        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: message!).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], context: nil)

         return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
     }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
 
}





extension ChatMessageControllerViewController
{
//    @objc func exitchat()
//    {
//
//        performSegue(withIdentifier: "exitmessages", sender: self)
//    }
    
    @objc func hideKeyboard()
    {
        //print("close keyboard")
        self.becomeFirstResponder()
        self.view.endEditing(true)
        
        
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification)
    {
        
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let frame = keyboardSize.cgRectValue
        let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
        if isKeyboardShowing
        {
            //let indexPath = IndexPath(item: self.chatmessages.count-1, section: self.collview.lastSection)
            //self.collview.scrollToItem(at: indexPath, at: .bottom, animated: true)
            self.collview.contentInset.bottom = frame.size.height
            self.collview.scrollToBottom()
            self.collview.verticalScrollIndicatorInsets.bottom = frame.size.height
            
        }
        else
        {
            self.collview.contentInset.bottom = 0
            self.collview.verticalScrollIndicatorInsets.bottom = 0
        }
            
            
            
            
    }
    

    @objc func uploadMedia()
    {
        let imagepicker = UIImagePickerController()
        imagepicker.allowsEditing  = true
        imagepicker.delegate = self
        imagepicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagepicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // selected video
        self.navigationItem.title = "sending message..."
        let ref = GlobalReferences().storagemessagemedia.child(NSUUID().uuidString + ".mov")
        
        if let videourl = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        {
            do
            {
                let video = try Data(contentsOf: videourl, options: .mappedIfSafe)
                ref.putData(video).observe(.success, handler:
                { (snapshot) in
                    ref.downloadURL { (url, error) in
                        if error != nil
                        {
                            print("error while uploading", error!)
                        }
                        if let videourlstring = url?.absoluteString
                        {
                            
                            if let thumbnail = self.thumbNailFromURL(url: videourl)
                            {
                                
                                self.uploadToFirebase(img: thumbnail)
                                { (url) in
                                    let properties = ["videourl": videourlstring,"time" : "","messageid":"","seenstatus" : "delivered","sender_uid" : "","receiver_uid" : "", "mediaurl": url, "text": "New media item", "imagewidth": thumbnail.size.width as NSNumber, "imageheight": thumbnail.size.height as NSNumber] as [String : Any]
                                    self.sendMediaItemMessage(messages: properties)
                                    self.navigationItem.title = self.contactName
                                
                                }
                            }
                            
                        }
                    }

                })
            }
            catch
            {
               print(error)
               return
            }

        }
        
        // selected image
        else
        {
            var imgfrompicker : UIImage?
                   if let imageselected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
                   {
                       imgfrompicker = imageselected
                   }
                   
                   if let imageoriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
                   {
                      imgfrompicker = imageoriginal
                   }
                   if let selectedimage = imgfrompicker
                   {
                        
                        uploadToFirebase(img: selectedimage) { (url) in

                        let properties = ["time" : "","messageid":"","seenstatus" : "delivered","sender_uid" : "","receiver_uid" : "", "mediaurl": url, "text": "New media item", "imagewidth": selectedimage.size.width as NSNumber, "imageheight": selectedimage.size.height as NSNumber] as [String : Any]
                        self.sendMediaItemMessage(messages: properties)
                        self.navigationItem.title = self.contactName
                    }
                       
                   }
        }
       
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func thumbNailFromURL(url: URL) -> UIImage?
    {
        let assetgen = AVAssetImageGenerator(asset: AVAsset(url: url))
        
        do
        {
            let thumbnailimage = try assetgen.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailimage).fixOrientation()
        }
        catch let error
        {
            print(error)
        }
        return nil
        
    }
    func uploadToFirebase(img : UIImage, completion: @escaping(_ imageurl : String) -> Void)
    {
        let imagename = NSUUID().uuidString
        let ref = GlobalReferences().storagemessagemedia.child(imagename)
        if let uploaddata = img.jpegData(compressionQuality: 0.2)
        {
            ref.putData(uploaddata).observe(.success) { (snapshot) in
                ref.downloadURL { (url, error) in
                    if error != nil
                    {
                        print("error")
                        print(error!.localizedDescription)
                        return
                    }
                    if let mediaurl = url?.absoluteString
                    {
                        
                        completion(mediaurl)
                        //self.sendMediaItemMessage(mediaurl: mediaurl, img: img)
                    }
                }
            }
            
        }
        
    }
    func sendMediaItemMessage(messages : [String:Any])
    {
        
         
         guard let uid = Auth.auth().currentUser?.uid else{return}
      
         let dateformatter = DateFormatter()
         dateformatter.dateStyle = .short
         dateformatter.timeStyle = .medium
         dateformatter.locale = Locale(identifier: "en_US_POSIX")
         let timestamp = dateformatter.string(from: Date())
        
//        var messages = ["messageid":"","seenstatus" : "delivered","sender_uid" : "","receiver_uid" : "", "time" :  timestamp, "mediaurl": mediaurl, "text": "New media item", "imagewidth": img.size.width as NSNumber, "imageheight": img.size.height as NSNumber] as [String : Any]
        var messagearray = messages
        messagearray["time"] = timestamp
         
         if chat.chatpartner1 == uid
         {
             //chat.chatpartner1 = uid
             messagearray["sender_uid"] = uid
             messagearray["receiver_uid"] = chat.chatpartner2
         }
         if chat.chatpartner2 == uid
         {
             messagearray["sender_uid"] = uid
             messagearray["receiver_uid"] = chat.chatpartner1
         }
         
         //if there is no chat, make new chat
         
         if chat.chat_id == "No chat yet"
         {
            
             print("No previous chat, create new chat in controller")
             chat.chat_time = timestamp
             let messageobject = Message()
             messageobject.sender_uid = messagearray["sender_uid"] as? String
             messageobject.receiver_uid = messagearray["receiver_uid"] as? String
             messageobject.time = timestamp
            messageobject.mediaurl = messagearray["mediaurl"] as? String
            messageobject.imageheight = messagearray["imageheight"] as? NSNumber
            messageobject.imagewidth = messagearray["imagewidth"] as? NSNumber
             messageobject.seenstatus = "delivered"
             messageobject.text  = "New media item"
             
             chat.messages.append(messageobject)
             let ref = GlobalReferences().databaseChat
             let childref = ref.childByAutoId()
             let messageref = GlobalReferences().databaseSpecificChatReference(chatid: childref.key!).child("Messages")
             let messagechildref = messageref.childByAutoId()
             let chatdata = ["chattime": timestamp,"chatpartner1": uid ,"chatpartner2": chat.chatpartner2!, "sendername": chat.sender_name!,"receiver": chat.receiver_name!, "chatid": childref.key!] as [String : Any]
             let messages1 = ["messageid":messagechildref.key!,"seenstatus" : messageobject.seenstatus!,"sender_uid" : messageobject.sender_uid!,"receiver_uid" : messageobject.receiver_uid!, "time" :  timestamp, "mediaurl": messageobject.mediaurl!,"text": messageobject.text!, "imagewidth" : messageobject.imagewidth!, "imageheight": messageobject.imageheight!] as [String : Any]
             chat.chat_id = childref.key!
             messageobject.messageid = messagechildref.key
             
             DispatchQueue.main.async {
                 childref.updateChildValues(chatdata)
                 messagechildref.updateChildValues(messagearray)
                 //self.showChat()
                 self.chatmessages.append(messageobject)
                self.reloadofTable()
                 //self.collview.reloadData()
             }

         }
         else
         {
             
             if self.chat.messages[chat.messages.count-1].seenstatus == "seen"
             {
                 
             }
             
             
             let messageobject = Message()
             messageobject.sender_uid = messages["sender_uid"] as? String
             messageobject.receiver_uid = messages["receiver_uid"] as? String
             messageobject.time = timestamp
            messageobject.mediaurl = messagearray["mediaurl"] as? String
             messageobject.text = "New media item"
             messageobject.seenstatus = "delivered"
             messageobject.imageheight = messages["imageheight"] as? NSNumber
             messageobject.imagewidth = messages["imagewidth"] as? NSNumber
             let messageref = GlobalReferences().databaseSpecificChatReference(chatid: chat.chat_id!).child("Messages")
             let messagechildref = messageref.childByAutoId()
             messageobject.messageid = messagechildref.key
             messagearray["messageid"] = messageobject.messageid
             
             DispatchQueue.main.async {
                 messagechildref.updateChildValues(messagearray)
                 self.chatmessages.append(messageobject)
                 //self.collview.reloadData()
                self.reloadofTable()
                 //self.collview.scrollToBottom()
             }
             
             
         }
         collview.scrollToBottom()
         //self.messagetextfield.text! = ""
        customView.messagetextfield.text! = ""
         //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
         print("Please reload, new message added to chat")

    }
    
    
    @objc func sendMessage()
    {
        //self.view.endEditing(true)
        
        
        
        guard let uid = Auth.auth().currentUser?.uid else{return}
        //guard let text = self.messagetextfield.text, !text.isEmpty
        guard let text = customView.messagetextfield.text, !text.isEmpty
        else
        {
            print("empty string")
            return
            
        }
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .short
        dateformatter.timeStyle = .medium
        dateformatter.locale = Locale(identifier: "en_US_POSIX")
        let timestamp = dateformatter.string(from: Date())
       
        var messages = ["messageid":"","seenstatus" : "delivered","sender_uid" : "","receiver_uid" : "", "time" :  timestamp, "text": text] as [String : Any]
        
        if chat.chatpartner1 == uid
        {
            //chat.chatpartner1 = uid
            messages["sender_uid"] = uid
            messages["receiver_uid"] = chat.chatpartner2
        }
        if chat.chatpartner2 == uid
        {
            messages["sender_uid"] = uid
            messages["receiver_uid"] = chat.chatpartner1
        }
        
        //if there is no chat, make new chat
        
        if chat.chat_id == "No chat yet"
        {
            print("No previous chat, create new chat in controller")
            chat.chat_time = timestamp
            
            let messageobject = Message()
            messageobject.sender_uid = messages["sender_uid"] as? String
            messageobject.receiver_uid = messages["receiver_uid"] as? String
            messageobject.time = timestamp
            messageobject.text = text
            messageobject.seenstatus = "delivered"
            
            chat.messages.append(messageobject)
            let ref = GlobalReferences().databaseChat
            let childref = ref.childByAutoId()
            let messageref = GlobalReferences().databaseSpecificChatReference(chatid: childref.key!).child("Messages")
            let messagechildref = messageref.childByAutoId()
            let chatdata = ["chattime": timestamp,"chatpartner1": uid ,"chatpartner2": chat.chatpartner2!, "sendername": chat.sender_name!,"receiver": chat.receiver_name!, "chatid": childref.key!] as [String : Any]
            let messages1 = ["messageid":messagechildref.key!,"seenstatus" : messageobject.seenstatus!,"sender_uid" : messageobject.sender_uid!,"receiver_uid" : messageobject.receiver_uid!, "time" :  timestamp, "text": messageobject.text!] as [String : Any]
            chat.chat_id = childref.key!
            messageobject.messageid = messagechildref.key
            
            DispatchQueue.main.async {
                self.chatmessages.append(messageobject)
                childref.updateChildValues(chatdata)
                messagechildref.updateChildValues(messages1)
                self.reloadofTable()
            }

        }
        else
        {
            
//            if self.chat.messages[chat.messages.count-1].seenstatus == "seen"
//            {
//
//            }
            
            
            let messageobject = Message()
            messageobject.sender_uid = messages["sender_uid"] as? String
            messageobject.receiver_uid = messages["receiver_uid"] as? String
            messageobject.time = timestamp
            messageobject.text = text
            messageobject.seenstatus = "delivered"
            let messageref = GlobalReferences().databaseSpecificChatReference(chatid: chat.chat_id!).child("Messages")
            let messagechildref = messageref.childByAutoId()
            messageobject.messageid = messagechildref.key
            messages["messageid"] = messageobject.messageid
            
            DispatchQueue.main.async {
                self.chatmessages.append(messageobject)
                messagechildref.updateChildValues(messages)
                self.reloadofTable()
                
                //self.collview.scrollToBottom()
            }
            
            
        }
        collview.scrollToBottom()
        //self.messagetextfield.text! = ""
        customView.messagetextfield.text! = ""
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        print("Please reload, new message added to chat")
      
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "videoplayer"
        {
            if let destinationVC = segue.destination as? VideoPlayerController
            {
                if let url = sender as? String?
                {
                    destinationVC.url = url!
                }
                
            }
             
        }
    }
    
    
    func performZoomForImageView(imageview : UIImageView)
    {
        self.imageview = imageview
        self.imageview?.isHidden = true
        startingframe = imageview.superview?.convert(imageview.frame, to: nil)
        let zoomingimageview = UIImageView(frame: startingframe!)
        zoomingimageview.backgroundColor = UIColor.clear
        zoomingimageview.image = imageview.image
        zoomingimageview.isUserInteractionEnabled = true
        zoomingimageview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleZoomOut))
        swipeUp.direction = .up
        zoomingimageview.addGestureRecognizer(swipeUp)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleZoomOut))
        swipeDown.direction = .down
        zoomingimageview.addGestureRecognizer(swipeDown)
        if let keywindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        {
            backgroundview = UIView(frame: keywindow.frame)
            backgroundview?.backgroundColor = UIColor.black
            backgroundview?.alpha = 0
            keywindow.addSubview(backgroundview!)
            keywindow.addSubview(zoomingimageview)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations:
                           {
                                self.backgroundview?.alpha = 1
                            self.inputAccessoryView!.alpha = 0
                                self.hideKeyboard()
                                let height = (self.startingframe!.height/self.startingframe!.width) * keywindow.frame.width
                                zoomingimageview.frame = CGRect(x: 0, y: 0, width: keywindow.frame.width, height: height)
                                zoomingimageview.center = keywindow.center
                                zoomingimageview.contentMode = .scaleAspectFit
                            zoomingimageview.enableZoom()
                           })
                           { (completed) in
                              //do  nothing
                           }
        }
  
    }
    
    func playVideo(url : String, imageview: UIImageView)
    {
//        let vc = VideoPlayerController()
//        vc.url = url
//        self.present(vc, animated: true, completion: nil)
        self.performSegue(withIdentifier: "videoplayer", sender: url)
    }
    
    @objc func handleZoomOut(gesture : UITapGestureRecognizer)
    {
        if let zoomoutimageview = gesture.view
        {
            zoomoutimageview.layer.cornerRadius = 16
            zoomoutimageview.clipsToBounds = true
            
                
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations:
                {
                    
                    zoomoutimageview.frame = self.startingframe!
                    //zoomoutimageview.frame = CGRect(x: self.startingframe!.origin.x, y: self.startingframe!.origin.y, width: 219, height: 245)
                    zoomoutimageview.contentMode = .scaleAspectFill
                    self.backgroundview?.alpha = 0
                    self.inputAccessoryView!.alpha = 1
                    
                    
                })
                { (completed) in
                    zoomoutimageview.removeFromSuperview()
                    self.imageview?.isHidden = false
                    
                }
        }
    }
    
    @objc func viewFromNIb(nibname : String) -> UIView
    {
           let nibContents = Bundle.main.loadNibNamed(nibname,
               owner: self, options: nil)
           let view = nibContents?.first as! UIView
               return view
    }
   

    func reloadofTable()
    {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(arrayWork), userInfo: nil, repeats: false)
    }
    @objc func arrayWork()
    {
        self.sectionDictionary = Dictionary(grouping: self.chatmessages, by: {String($0.time!.split(separator: ",")[0])})
        var dict = [String: Any]()
        self.allKeys = Array(self.sectionDictionary.keys)
        for value in self.allKeys{
            let data = FinalData(title: value, aryData: self.sectionDictionary[value]!)
            dict[value] = data
            self.aryFinalData.append(data)
        }
        self.aryFinalData = Array(dict.values) as! [FinalData]
        
        self.aryFinalData.sort { (d1, d2) -> Bool in
            let formatterGet = DateFormatter()
            formatterGet.dateStyle = .short
            formatterGet.timeStyle = .none
            formatterGet.locale = Locale(identifier: "en_US_POSIX")
            let time1FromString = formatterGet.date(from: d1.title!)
            let time2FromString = formatterGet.date(from: d2.title!)
            return time1FromString! < time2FromString!
        }
        DispatchQueue.main.async
            {
                self.collview.reloadData()
                //self.collview.scrollToBottom()
            }
    }
    
    
    @objc func addUnknownContact()
    {
        
        let alert = UIAlertController(title: "Do you want to add this contact?", message: "This action will save this user as one of your contacts" , preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:
        { action in
            self.addNewUnknownContact()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    
    func addNewUnknownContact()
    {
        Api.User.addContact(adderUID: self.uid!, addeeEmail: self.originalcontactName, onSucess:
        {
                            
            ProgressHUD.showSuccess("Successfully added contact")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            self.navigationItem.title = self.originalcontactName
            self.navigationItem.rightBarButtonItem = UIBarButtonItem()
            
        })
        { (error) in
            print(error)
            ProgressHUD.show(error)
        }
    }
    
  
    
    
    
}
extension UICollectionView {


    var lastSection: Int {
        return numberOfSections - 1
    }

    var lastIndexPath: IndexPath? {
        guard lastSection >= 0 else {
            return nil
        }

        let lastItem = numberOfItems(inSection: lastSection) - 1
        guard lastItem >= 0 else {
            return nil
        }

        return IndexPath(item: lastItem, section: lastSection)
    }

    /// Islands: Scroll to bottom of the CollectionView
    /// by scrolling to the last item in CollectionView
    func scrollToBottom() {
        guard let lastIndexPath = lastIndexPath else {
            return
        }
        scrollToItem(at: lastIndexPath, at: .bottom, animated: true)
    }
}
extension UIImageView {
  func enableZoom() {
    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
    isUserInteractionEnabled = true
    addGestureRecognizer(pinchGesture)
  }

  @objc
  private func startZooming(_ sender: UIPinchGestureRecognizer) {
    let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
    guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
    sender.view?.transform = scale
    sender.scale = 1
  }
}
extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 8, height: 16)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
