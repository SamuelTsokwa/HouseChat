//
//  VideoPlayerController.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-03-22.
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

class VideoPlayerController: UIViewController {
    var url : String?
    var playerlayer : AVPlayerLayer?
    
    lazy var player = AVPlayer(url: URL(string: url!)!)
    var timer : Timer?
    var isPlaying: Bool
    {
        return self.player.rate != 0 && self.player.error == nil
    }
    
    let slider : UISlider =
    {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = UIColor.lightGray
        slider.maximumTrackTintColor = UIColor.darkGray
        slider.isContinuous = true
        slider.isEnabled = true
        slider.isUserInteractionEnabled = true
        slider.addTarget(self, action: #selector(seekVideo), for: .touchUpInside)
        return slider
    }()
    
    let videotime : UILabel =
    {
        let videotime = UILabel()
        videotime.translatesAutoresizingMaskIntoConstraints = false
        videotime.layer.backgroundColor = UIColor.black.withAlphaComponent(0.65).cgColor
        videotime.layer.cornerRadius = 13
        videotime.frame.size.width = videotime.intrinsicContentSize.width + 7
        videotime.frame.size.height = videotime.intrinsicContentSize.height + 7
        videotime.layer.masksToBounds = true
        videotime.layer.cornerCurve = .continuous
        videotime.textAlignment = .center
        videotime.text = "00:00" + " / " + "01:20"
        videotime.font = videotime.font.withSize(15)
        return videotime
    }()
    
    let upperView : UIView =
    {
        let upperView = UIView()
        return upperView
    }()
    
    let controlsView : UIView =
    {
        let controlsView = UIView()
        return controlsView
    }()
    
    lazy var maincontainerview : UIView =
    {
        let view = UIView()
        view.frame = self.view.frame
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    let playbutton : UIButton =
    {
        let playbutton = UIButton()
        return playbutton
    }()
    
    lazy var activityIndicatorView: UIActivityIndicatorView =
    {
        let aiv = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.startAnimating()
        return aiv
    }()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setUpPlayer()
        setUpUI()
        updateUi()
//        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.timerFired(_:)), userInfo: nil, repeats: true)
        player.play()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { [weak self] _ in
            self!.player.seek(to: CMTime.zero)
            self!.player.play()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.timer?.invalidate()
        self.player.pause()
        self.player.replaceCurrentItem(with: nil)
    }
    
    @objc func setUpUI()
    {
        self.view.backgroundColor = UIColor.black
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(hideControls))
        self.maincontainerview.isUserInteractionEnabled = true
        self.maincontainerview.addGestureRecognizer(tapgesture)
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(exitVideoPlayer))
        swipeUp.direction = .up
        self.maincontainerview.addGestureRecognizer(swipeUp)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(exitVideoPlayer))
        swipeDown.direction = .down
        self.maincontainerview.addGestureRecognizer(swipeDown)
        
        self.controlsView.translatesAutoresizingMaskIntoConstraints = false
        self.controlsView.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        
        self.controlsView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80)
        
        self.upperView.translatesAutoresizingMaskIntoConstraints = false
        self.upperView.backgroundColor = UIColor.clear
        self.upperView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80)

        
        
        //playbutton
        
        self.playbutton.translatesAutoresizingMaskIntoConstraints = false
        self.playbutton.tintColor = UIColor.white
        self.playbutton.addTarget(self, action: #selector(playButtonClicked), for: .touchDown)
        self.controlsView.addSubview(self.playbutton)
        
        //slider
        
        
        //slider.backgroundColor = UIColor.red
        let newimage = UIImage.from(color: UIColor.white)
        self.slider.setThumbImage(newimage, for: .normal)
        self.slider.setThumbImage(newimage, for: .highlighted)
        self.slider.setThumbImage(newimage, for: .focused)
        self.controlsView.addSubview(self.slider)
        
        //exitbutton
        let exitButton = UIButton()
        exitButton.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        let config1 = UIImage.SymbolConfiguration(pointSize: 21)
        let image1 = UIImage(systemName: "xmark", withConfiguration: config1)
        exitButton.setImage(image1, for: .normal)
        exitButton.tintColor = UIColor.white
        exitButton.showsTouchWhenHighlighted = true
        exitButton.addTarget(self, action: #selector(exitVideoPlayer), for: .touchUpInside)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.isUserInteractionEnabled  = true
        exitButton.layer.cornerRadius = 13
        exitButton.frame.size.width = videotime.intrinsicContentSize.width + 5
        exitButton.frame.size.height = videotime.intrinsicContentSize.height + 5
        exitButton.layer.masksToBounds = true
        exitButton.layer.cornerCurve = .continuous
        exitButton.contentMode = .center
        self.upperView.addSubview(exitButton)
        
        
        self.upperView.addSubview(self.videotime)
        //videotime.font.pointSize = 21
        
        self.view.addSubview(self.maincontainerview)
        self.view.addSubview(self.controlsView)
        self.view.addSubview(self.upperView)
        self.view.addSubview(self.activityIndicatorView)
        
        
        NSLayoutConstraint.activate([
            self.controlsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.controlsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            self.controlsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            self.controlsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -80),
            self.controlsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            self.playbutton.leftAnchor.constraint(equalTo: self.controlsView.leftAnchor, constant: 14),
            self.playbutton.centerYAnchor.constraint(equalTo: self.controlsView.centerYAnchor),
            self.playbutton.widthAnchor.constraint(equalToConstant: 19),
            self.playbutton.heightAnchor.constraint(equalToConstant: 19),
            self.slider.centerYAnchor.constraint(equalTo: self.controlsView.centerYAnchor),
            self.slider.leftAnchor.constraint(equalTo: self.playbutton.rightAnchor, constant: 25),
            self.slider.rightAnchor.constraint(equalTo: self.controlsView.rightAnchor, constant:  -17),
            
            
            
            //upperView
            self.upperView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            self.upperView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            self.upperView.topAnchor.constraint(equalTo: view.topAnchor),
            self.upperView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            exitButton.rightAnchor.constraint(equalTo: self.upperView.rightAnchor, constant: -14),
            exitButton.centerYAnchor.constraint(equalTo: self.upperView.centerYAnchor),
            exitButton.widthAnchor.constraint(equalToConstant: 26),
            exitButton.heightAnchor.constraint(equalToConstant: 26),
            self.videotime.leftAnchor.constraint(equalTo: self.upperView.leftAnchor, constant: 14),
            self.videotime.centerYAnchor.constraint(equalTo: self.upperView.centerYAnchor),
            self.videotime.heightAnchor.constraint(equalToConstant: 26),
            self.videotime.widthAnchor.constraint(equalToConstant: 110),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//            self.maincontainerview.topAnchor.constraint(equalTo: self.upperView.bottomAnchor),
//            self.maincontainerview.bottomAnchor.constraint(equalTo: self.controlsView.topAnchor),
            
            
            
        ])
        
        
            
            
    }
    
    func updateUi()
    {
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self , selector: #selector(self.timerFired(_:)), userInfo: nil, repeats: true)
    }
    
    @objc func timerFired(_ timer: Timer)
    {
        
        let config = UIImage.SymbolConfiguration(pointSize: 19)
        let image = UIImage(systemName: "play.fill", withConfiguration: config)
        let image1 = UIImage(systemName: "pause.fill", withConfiguration: config)
        
        self.playbutton.setImage(image, for: .normal)
        if isPlaying
        {
            self.playbutton.setImage(image1, for: .normal)
            self.activityIndicatorView.stopAnimating()
        }
        
        else
        {
            self.playbutton.setImage(image, for: .normal)
        }
        
        let duration = self.player.currentItem?.asset.duration
        let currentpos = self.player.currentTime()
        let currsecs = CMTimeGetSeconds(currentpos)
        let secs = CMTimeGetSeconds(duration!)
        let totalduration = getFormattedTime(timeInterval: TimeInterval(secs))
        let currentposformatted = getFormattedTime(timeInterval: TimeInterval(currsecs))
        self.videotime.text = currentposformatted + " / " + totalduration
        self.slider.maximumValue = Float(secs)
        self.slider.value = Float(currsecs)
    }
    
    func setUpPlayer()
    {
        
        self.playerlayer = AVPlayerLayer(player: self.player)
        self.playerlayer?.frame = self.view.bounds
        self.playerlayer?.videoGravity = .resizeAspect
         do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        self.view.layer.addSublayer(self.playerlayer!)
        
    }

}
extension VideoPlayerController
{
    func getFormattedTime(timeInterval: TimeInterval) -> String {
           let mins = timeInterval / 60
           let secs = timeInterval.truncatingRemainder(dividingBy: 60)
           let timeformatter = NumberFormatter()
           timeformatter.minimumIntegerDigits = 2
           timeformatter.minimumFractionDigits = 0
           timeformatter.roundingMode = .down
           guard let minsStr = timeformatter.string(from: NSNumber(value: mins)), let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
               return ""
           }
           return "\(minsStr):\(secsStr)"
       }
    
    @objc func hideControls()
    {
        let uishowing = self.controlsView.alpha == 1 && self.upperView.alpha == 1
        if uishowing
        {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
                self.upperView.alpha = 0
                self.controlsView.alpha = 0
            }, completion: nil)
        }
        else
        {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
                self.upperView.alpha = 1
                self.controlsView.alpha = 1
            }, completion: nil)
        }
        
    }
    @objc func playButtonClicked()
    {
        if isPlaying
        {
            self.player.pause()
        }
        else
        {
            self.player.play()
        }
    }
    
    @objc func exitVideoPlayer()
    {
        self.player.pause()
        self.timer?.invalidate()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func seekVideo()
    {

        
        if let duration = self.player.currentItem?.duration
        {
            self.player.pause()
            let totalsecs = CMTimeGetSeconds(duration)
            let value = Float64(self.slider.value) * totalsecs
            //let value = self.slider.value
            let seektime = CMTime(value: Int64(value), timescale: 1)
            self.player.seek(to: seektime)
            self.player.play()
        }
        
        
    }
    
    override var prefersStatusBarHidden: Bool {
      return true
    }
    
    
}
