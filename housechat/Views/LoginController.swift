//
//  ViewController.swift
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

class LoginController: UIViewController,UITextFieldDelegate {
    @IBOutlet var signup_segue_button: UIButton!
    @IBOutlet var Email: UITextField!
    
    @IBOutlet var password: UITextField!
    @IBOutlet var login_button: UIButton!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupUI()
        
    }
    
    
    @IBAction func login_didTap(_ sender: Any)
    {
        self.view.endEditing(true)
        self.validateFields()
        self.logIn(onSucess:
            {
                    self.performSegue(withIdentifier: "Signin_to_userprofile", sender: self)
            })
        { (error) in
            ProgressHUD.showError(error)
        }
    }
    
    func setupUI()
    {
        signup_segue_button.addTarget(self, action: #selector(signupSegue), for: .touchDown)
        login_button.layer.cornerRadius = 8
    }
   
    
}


extension LoginController
{
    
    
    @objc func logIn(onSucess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void)
    {
        ProgressHUD.show()
        Api.User.logIn(email: Email.text!, password: "qwertyuiop",onSucess:
            {
                ProgressHUD.dismiss()
                onSucess()
            })
            { (error) in
             onError(error)
            }
    }
    
    @objc func validateFields()
    {
        
        guard let email_input = Email.text, !email_input.isEmpty
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

    
    @objc func signupSegue()
    {
        performSegue(withIdentifier: "login_to_signup", sender: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
//    {
//        if segue.identifier == "Signin_to_userprofile"
//        {
//            if let destinationVC = segue.destination as? UserProfileController
//            {
//                if let user = sender as? Dictionary<String,Any>
//                {
//                    destinationVC.user = user
//                }
//
//            }
//
//        }
//    }
}
