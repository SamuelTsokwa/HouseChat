//
//  SideMenuViewController.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-04-04.
//  Copyright © 2020 Samuel Tsokwa. All rights reserved.
//
import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import ProgressHUD
import Kingfisher

protocol arrayset {
    func setContact(array: [User])
}

class SideMenuViewController: UIViewController, UINavigationControllerDelegate, arrayset {
    
    
    var contacts = 0
    //var
    var finalcontacts = [User]()
    var contactsArray = [User]()
    {
        didSet
        {
            setter()
        }
    }
    @IBOutlet var groupchatbtn: UIButton!
    @IBOutlet var logout_btn: UIButton!
    @IBOutlet var contactsnumber: UILabel!
    @IBOutlet var username: UILabel!
    @IBOutlet var profilepic: UIImageView!
    var new_avatar_image: UIImage? = nil
    var loadedData = LoadData.init()
    var currentuser = User()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
        let ges = UITapGestureRecognizer(target: self, action: #selector(imagePicker))
        self.profilepic.addGestureRecognizer(ges)
        self.profilepic.isUserInteractionEnabled = true
        
        
   
    }
    func setter()
    {
        self.finalcontacts = contactsArray
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func setupUI()
    {
        self.profilepic.layer.cornerRadius = self.profilepic.frame.height/2
        let config = UIImage.SymbolConfiguration(pointSize: 12)
        let image = UIImage(systemName: "camera.fill", withConfiguration: config)
        let plusview = UIImageView(image: image)
        plusview.contentMode = .center
        plusview.tintColor = .white
        plusview.frame = CGRect(x: 0, y: 0, width: self.profilepic.frame.width, height: self.profilepic.frame.height)
        plusview.backgroundColor = UIColor.black.withAlphaComponent(0.53)
        self.profilepic.addSubview(plusview)
        self.logout_btn.addTarget(self, action: #selector(logout), for: .touchUpInside)
        self.groupchatbtn.addTarget(self, action: #selector(createGroupChat), for: .touchUpInside)
        

    }
    
    func loadUserData()
    {
        var contactcount = 0
        guard let uid = Auth.auth().currentUser?.uid else{return}
        GlobalReferences().databaseSpecificUserReference(uid: uid).observe(.value)
        { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                let profileimageurl = dictionary["profileImageUrl"] as? String
                let url = URL(string: profileimageurl!)
                self.profilepic.kf.indicatorType = .activity
                self.profilepic.kf.setImage(with: url)
                self.username.text = dictionary["username"] as? String
                if dictionary["Contacts"] as? [String: AnyObject] == nil
                {
                    contactcount = 0
                }
                else
                {
                    for _ in dictionary["Contacts"] as! [String: AnyObject]
                    {
                        contactcount = contactcount + 1
                    }
                }
                
                let string = "\(contactcount) Friends"
                let colorstring = "Friends"
                let range = (string as NSString).range(of: colorstring)
                let attribute = NSMutableAttributedString.init(string: string)
                attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray , range: range)
                self.contactsnumber.attributedText = attribute



            }
        }
        
        
    }
    @objc func imagePicker()
    {
        let alert = UIAlertController(title: "Are you sure you want to change your profile photo ?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true)
        
    }
    func updateStorageAndDB()
    {
        guard let uid = Auth.auth().currentUser?.uid else{return}
        let ref = GlobalReferences().databaseSpecificUserReference(uid: uid)
        let storageProfile = GlobalReferences().storageSpecificProfile(uid: uid)
        guard let imagedata = new_avatar_image?.jpegData(compressionQuality: 0.4)else{return}
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        storageProfile.putData(imagedata, metadata: metadata) { (data, error) in
            if error != nil
            {
                print(error!.localizedDescription)
            }
            storageProfile.downloadURL { (url, error) in
               if let imageurl = url?.absoluteString
               {
                let newprofileurl = ["profileImageUrl": imageurl]
                ref.updateChildValues(newprofileurl)
           

              }
            }
        }
        
        
        
        
    }
    @objc func logout()
    {
        DispatchQueue.main.async
            {
                Api.User.logOut()
                self.performSegue(withIdentifier: "signoutsegue", sender: self)
            }
    }
    @objc func createGroupChat()
    {
        ProgressHUD.showSuccess("Coming Soon !")
        //performSegue(withIdentifier: "groupchat", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "groupchat"
              {
                  if let destinationVC = segue.destination as? GroupChatViewController
                  {
                    destinationVC.contacts = self.finalcontacts
                  }
                  
                   
              }
    }
    

}

extension SideMenuViewController : UIImagePickerControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
      {
          if let imageselected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
          {
              new_avatar_image = imageselected
              self.profilepic.image = imageselected
              self.updateStorageAndDB()
          }
          
          if let imageoriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
          {
              new_avatar_image = imageoriginal
              self.profilepic.image = imageoriginal
          }
          
          picker.dismiss(animated: true, completion: nil)
      }
    
    func setContact(array: [User]) {
        self.contactsArray = array
        print("yoooo",self.contactsArray)
    }
}
