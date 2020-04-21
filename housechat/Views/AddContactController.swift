//
//  AddContactController.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-03-03.
//  Copyright © 2020 Samuel Tsokwa. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import ProgressHUD
import Kingfisher

class AddContactController: UIViewController,UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var autocompletetable: UITableView!
    var allUsers = [User]()
    var Contacts = [User]()
    @IBOutlet var autocompleteheight: NSLayoutConstraint!
    @IBOutlet var searchfield: UITextView!
    var loadedData = LoadData.init()
    var autocompletearray = [User]()
    var currentuser = User()
    var contactsCompletedArray : [User] = []
    {
        didSet
        {
            setArrayProp()
        }
    }
    var usersCompletedArray : [User] = []
    {
        didSet
        {
            setArrayProp()
            
        }
    }
    func setArrayProp(){
         
        self.allUsers = usersCompletedArray
        self.Contacts = contactsCompletedArray
        for user in usersCompletedArray
        {
            if user.uid == Auth.auth().currentUser?.uid
            {
                self.currentuser = user
                self.allUsers.remove(element: user)
            }
        }
        self.autocompletetable.reloadData()
    }
    let backgroundview : UIView =
    {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dissmissview = UITapGestureRecognizer(target: self, action: #selector(dissMissView))
        //let dissmisskeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.backgroundview.addGestureRecognizer(dissmissview)
        self.searchfield.delegate = self
        self.searchfield.becomeFirstResponder()
        //let config = UIImage.SymbolConfiguration(pointSize: 29)
        setupUI()
        
        loadedData.loadAllUsers { (usersCompletion) in
        self.usersCompletedArray = usersCompletion
        }
        loadedData.loadContacts { (contactCompletion) in
            self.contactsCompletedArray = contactCompletion
            print("loaded for add",contactCompletion)
           
        }
        
    }

    
    func setupUI()
    {
        self.searchfield.delegate = self
        autocompletetable.tableFooterView = UIView()
        //self.searchfield.sizeToFit()
//        let buttonHeight: CGFloat = 44
//        let contentInset: CGFloat = 8

        //inset the textView
        
        self.searchfield.textContainerInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 49)

        let button = UIButton()
        print(self.searchfield.textContainerInset)
        button.frame = CGRect(x: searchfield.frame.width - 29 - 20, y: 0, width: 50, height: 50)
        let config = UIImage.SymbolConfiguration(pointSize: 29)
        let image = UIImage(systemName: "plus.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: "red")
        searchfield.addSubview(button)
        button.topAnchor.constraint(equalTo: searchfield.topAnchor, constant: 5).isActive = true
        button.addTarget(self, action: #selector(addContact), for: .touchUpInside)
        button.showsTouchWhenHighlighted = true
        self.backgroundview.frame = self.view.frame
        self.view.addSubview(backgroundview)
        self.view.sendSubviewToBack(backgroundview)

        
    }
    
  

    @objc func addContact()
    {
        if self.searchfield.text! == self.currentuser.email
        {
            
            self.searchfield.text! = ""
            ProgressHUD.showError("Can't add yourself :)")
           
            return
        }
        
        if Contacts.contains(where: { (user) -> Bool in
            return user.email == self.searchfield.text!
        })
        {
            self.searchfield.text! = ""
            ProgressHUD.showError("Contact already added")
            
             return
        }

        guard let uid = Auth.auth().currentUser?.uid else{return}
        Api.User.addContact(adderUID: uid, addeeEmail: self.searchfield.text!, onSucess: {
            
            ProgressHUD.showSuccess("Successfully added contact")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            
        }) { (error) in
            print(error)
            ProgressHUD.show(error)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
      
    
    @objc func dissMissView()
    {
        self.becomeFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    @objc func hideKeyboard()
    {
        self.autocompletetable.becomeFirstResponder()
        self.view.endEditing(true)
    }
    

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.autocompletetable.isHidden = false
        
//        autocompleteheight.constant = autocompletetable.contentSize.height
      
        let substring = (textView.text as NSString).replacingCharacters(in: range, with: text)
        autoComplete(substring: substring)
//        self.autocompletearray = allUsers.filter({ (user) -> Bool in
//            return (user.email?.lowercased().contains(substring.lowercased()))! || (user.username?.lowercased().contains(substring.lowercased()))!
//        })
//        let contactalreadyadded = Set(self.autocompletearray).intersection(Set(self.Contacts))
//        print("added",contactalreadyadded, self.Contacts)
//         autocompletetable.reloadData()
        //searchAutocompleteEntriesWithSubstring(substring: substring)
        return true
    }
    
    func autoComplete(substring : String)
    {
        self.autocompletearray = allUsers.filter({ (user) -> Bool in
              return (user.email?.lowercased().contains(substring.lowercased()))! || (user.username?.lowercased().contains(substring.lowercased()))!
          })
        removeAddedContactsFromArray(arr: self.autocompletearray)
        autocompletetable.reloadData()
    }
    func removeAddedContactsFromArray(arr : [User])
    {
        for contact in self.Contacts
        {
            for usersuggestions in self.autocompletearray
            {
                if contact.email! == usersuggestions.email!
                {
                    self.autocompletearray.remove(element: usersuggestions)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompletearray.count
    }
  
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = autocompletetable.dequeueReusableCell(withIdentifier: "autocompletecell", for: indexPath)
        if self.allUsers.count != 0
        {
            //let url = URL(string: self.autocompletearray[indexPath.row].profileImageUrl!)
            cell.textLabel?.text = self.autocompletearray[indexPath.row].username
            cell.detailTextLabel?.text = self.autocompletearray[indexPath.row].email
            //cell.imageView?.kf.setImage(with: url)
            
        }
        //cell.imageView?.image? = (cell.imageView?.image?.resized(toWidth: 50, isOpaque: true))!
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchfield.text = self.autocompletearray[indexPath.row].email
        self.autocompletetable.becomeFirstResponder()
        self.autocompletetable.deselectRow(at: indexPath, animated: true)
        hideKeyboard()
        
    }
    
    
    
    
}
