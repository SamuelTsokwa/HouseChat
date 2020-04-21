//
//  BaseCell.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-03-13.
//  Copyright © 2020 Samuel Tsokwa. All rights reserved.
//

import UIKit
import AVFoundation
//class BaseCell: UICollectionViewCell {
//
//}



class ChatLogMessageCell: UICollectionViewCell {
   
    var ChatMessageControllerViewController : ChatMessageControllerViewController?
    var messageatindexrow : Message?
    var playerlayer : AVPlayerLayer?
    
    
    lazy var playbutton : UIButton =
    {
        let button = UIButton()
        //button.setTitle("Play button", for: .normal)
        let config = UIImage.SymbolConfiguration(pointSize: 45)
        let image = UIImage(systemName: "play.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = "Sample message"
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        textView.isUserInteractionEnabled = false
        return textView
    }()

    let textBubbleView: UIView = {
        let view = UIView()
        
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var messageimageview: UIImageView =
    {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return view
    }()
    let bubbleImageView: UIImageView = {
           let imageView = UIImageView()
           imageView.image = ChatLogMessageCell.grayBubbleImage
           imageView.tintColor = UIColor(white: 0.90, alpha: 1)
           imageView.isUserInteractionEnabled = true
        
           return imageView
       }()
    
    @objc func handleZoomTap(gesture : UITapGestureRecognizer)
    {
        if let imageview = gesture.view as? UIImageView
        {
            self.ChatMessageControllerViewController!.performZoomForImageView(imageview: imageview)
        }
        
    }
    
    @objc func handlePlay(sender: UIButton)
    {
        print("play vid")
        if let videourl = messageatindexrow?.videourl
        {
            self.ChatMessageControllerViewController?.playVideo(url: videourl, imageview : bubbleImageView)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerlayer?.removeFromSuperlayer()
    }

     static let grayBubbleImage = UIImage(named: "bubble_gray")!
     .resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26),
                     resizingMode: .stretch).withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
     static let blueBubbleImage = UIImage(named: "bubble_blue")!
     .resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26),
                     resizingMode: .stretch).withRenderingMode(UIImage.RenderingMode.alwaysTemplate)

   



    override init(frame: CGRect) {
           super.init(frame: frame)
           setupViews()
           
       }

       required init?(coder aDecoder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
        //super.init()
         
       }
    
        func setupViews()
        {
            

            addSubview(textBubbleView)
            addSubview(messageTextView)
            bubbleImageView.addSubview(messageimageview)
            messageimageview.leftAnchor.constraint(equalTo: bubbleImageView.leftAnchor).isActive = true
            messageimageview.topAnchor.constraint(equalTo: bubbleImageView.topAnchor).isActive = true
            messageimageview.widthAnchor.constraint(equalTo: bubbleImageView.widthAnchor).isActive = true
            messageimageview.heightAnchor.constraint(equalTo: bubbleImageView.heightAnchor).isActive = true
            bubbleImageView.addSubview(playbutton)
            playbutton.centerXAnchor.constraint(equalTo: bubbleImageView.centerXAnchor).isActive = true
            playbutton.centerYAnchor.constraint(equalTo: bubbleImageView.centerYAnchor).isActive = true
            playbutton.widthAnchor.constraint(equalToConstant: 45).isActive = true
            playbutton.heightAnchor.constraint(equalToConstant: 45).isActive = true
            textBubbleView.addSubview(bubbleImageView)
                textBubbleView.addConstraintsWithFormat(format: "H:|[v0]|", views: bubbleImageView)
                textBubbleView.addConstraintsWithFormat(format: "V:|[v0]|", views: bubbleImageView)
            //print(messageimageview)
           
        }
        
}
class Header : ChatLogMessageCell
{
    
}

extension UIView {

    func addConstraintsWithFormat(format: String, views: UIView...) {

        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
}
extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
}
