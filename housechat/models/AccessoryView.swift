//
//  AccessoryView.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-03-26.
//  Copyright © 2020 Samuel Tsokwa. All rights reserved.
//

import Foundation
import UIKit
 

class AccessoryView: UIView {
    
    let addImage = UIButton()
    let sendButton = UIButton()
    var chatController : ChatMessageControllerViewController?
    {
        didSet
        {
//            self.messagetextfield.addTarget(chatController, action: #selector(chatController?.textFieldDidChange(textField:)), for: .editingChanged)
            self.messagetextfield.addTarget(chatController, action: #selector(chatController?.textField(_:shouldChangeCharactersIn:replacementString:)), for: .editingChanged)
            self.addImage.addTarget(chatController, action: #selector(chatController?.uploadMedia), for: .touchUpInside)
            self.sendButton.addTarget(chatController, action: #selector(chatController?.sendMessage), for: .touchUpInside)
//            self.messagetextfield.addTarget(chatController, action: #selector(Api.chatMethods.textFieldDidChange(textField:)), for: .editingChanged)
            
        }
    }
    
    let messagetextfield: UITextField =
       {
           let textfield = UITextField()
           textfield.placeholder = "Send message"
           textfield.translatesAutoresizingMaskIntoConstraints = false
           return textfield
       }()
    
    
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let config = UIImage.SymbolConfiguration(pointSize: 27)
        let image = UIImage(systemName: "plus.circle.fill", withConfiguration: config)
        self.addImage.setImage(image, for: .normal)
        self.addImage.isUserInteractionEnabled = true
        self.addImage.showsTouchWhenHighlighted = true
        
        self.addImage.tintColor = UIColor(named: "aqua")
        self.addImage.translatesAutoresizingMaskIntoConstraints = false
        //addImage.addTarget(self, action: #selector(uploadMedia), for: .touchUpInside)
        addSubview(self.addImage)
        
        self.addImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 9).isActive = true
        self.addImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.addImage.widthAnchor.constraint(equalToConstant: 27).isActive = true
        self.addImage.heightAnchor.constraint(equalToConstant: 27).isActive = true
        
        
        //sendbutton
        
        sendButton.showsTouchWhenHighlighted = true
        let image1 = UIImage(systemName: "arrow.right.circle.fill", withConfiguration: config)
        sendButton.setImage(image1, for: .normal)
        sendButton.tintColor = UIColor(named: "aqua")
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        //sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        sendButton.isUserInteractionEnabled = true
        addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -9).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 27).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 27).isActive = true
        
        
        

        self.messagetextfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: messagetextfield.frame.height))
        self.messagetextfield.leftViewMode = .always
        self.messagetextfield.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: messagetextfield.frame.height))
        self.messagetextfield.rightViewMode = .always
        self.messagetextfield.layer.borderColor = UIColor(named: "aqua")?.cgColor
        self.messagetextfield.layer.masksToBounds = true
        self.messagetextfield.layer.cornerRadius = 24
        self.messagetextfield.layer.cornerCurve = .continuous
        self.messagetextfield.layer.borderWidth = 1
        addSubview(self.messagetextfield)
        self.messagetextfield.leftAnchor.constraint(equalTo: addImage.rightAnchor, constant: 17).isActive = true
        self.messagetextfield.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.messagetextfield.heightAnchor.constraint(equalToConstant: 48).isActive = true
        self.messagetextfield.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -17).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
