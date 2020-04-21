//
//  SignUpController.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-02-29.
//  Copyright © 2020 Samuel Tsokwa. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import ProgressHUD

class SignUpController: UIViewController
{
    
    @IBOutlet var password: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var username: UITextField!
    @IBOutlet var signup_button: UIButton!
    @IBOutlet weak var backarrow: UIButton!
    @IBOutlet weak var avatar: UIImageView!
    var new_avatar_image: UIImage? = nil
    override func viewDidLoad()
    {
        super.viewDidLoad()
        appsetup()
        
        
        
        
        
    }
    
    func appsetup()
    {
        backarrow.addTarget(self, action: #selector(viewnavtransitions), for: .touchDown)
        signup_button.layer.cornerRadius = 8
        avatarSetup()
    }
    
    
}


extension SignUpController
{
    
    @objc func avatarSetup()
    {
        let config = UIImage.SymbolConfiguration(pointSize: 12)
        let image = UIImage(systemName: "camera.fill", withConfiguration: config)
        let plusview = UIImageView(image: image)
        plusview.contentMode = .center
        plusview.tintColor = .white
        plusview.frame = CGRect(x: 0, y: 0, width: self.avatar.frame.width, height: self.avatar.frame.height)
        plusview.backgroundColor = UIColor.black.withAlphaComponent(0.53)
        self.avatar.addSubview(plusview)
        avatar.layer.cornerRadius = avatar.frame.size.width / 2
        avatar.clipsToBounds = true
        avatar.isUserInteractionEnabled = true
        let avatar_didTap = UITapGestureRecognizer(target: self, action: #selector(showimagepicker))
        avatar.addGestureRecognizer(avatar_didTap)
        print(plusview.frame.height,avatar.frame.height)
        
    }
    
    @objc func viewnavtransitions()
    {
        
        performSegue(withIdentifier: "signup_to_login", sender: self)
    }
    
    @objc func showimagepicker()
    {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    @IBAction func signup_did_tap(_ sender: Any)
    {
        self.view.endEditing(true)
        self.validateFields()
        self.signUp(onSucess: {
            Api.User.logIn(email: self.email.text!, password: self.password.text!, onSucess: {
                print("Loging in after signup completed")
                self.performSegue(withIdentifier: "signup_to_userprofile", sender: self)

            }) { (error) in
                print(error)
            }
        }, onError:  {(error) in print(error)})
       

    }
    
    
    
    @objc func validateFields()
    {
        guard let username_input = username.text, !username_input.isEmpty
            else
            {
                //print("Please enter a usernmae")
                ProgressHUD.showError(EMPTY_USERNAME_ERROR)
                return
            }
        
        guard let email_input = email.text, !email_input.isEmpty
        else
        {
            //print("Please enter a valid email address")
            ProgressHUD.showError(EMPTY_EMAIL_ERROR)
            return
        }
        
        guard let password_input = password.text, !password_input.isEmpty
        else
        {
            //print("Please enter a valid password")
            ProgressHUD.showError(INVALID_PASSWORD_ERROR)
            return
        }
    }
    
    @objc func signUp(onSucess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void)
    {
        ProgressHUD.show()
        Api.User.signUp(withUsername: username.text!, email: email.text!, password: "qwertyuiop", new_avatar_image: new_avatar_image, onSucess:
            {
                onSucess()
                
            })
            { (error) in
             onError(error)
            }
        

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    

    
    
}

extension SignUpController: UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let imageselected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        {
            new_avatar_image = imageselected
            avatar.image = imageselected
        }
        
        if let imageoriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            new_avatar_image = imageoriginal
            avatar.image = imageoriginal
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
