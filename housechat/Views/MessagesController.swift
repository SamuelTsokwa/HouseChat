//
//  MessagesController.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-03-12.
//  Copyright © 2020 Samuel Tsokwa. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import ProgressHUD
import Kingfisher



class MessagesController: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    var chat = Chat()
    

    @IBOutlet var backbutton: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(" fvsjklnvs")
        for u in chat.messages
        {
            print(u.text)
        }
       backbutton.leftBarButtonItem = UIBarButtonItem(
           title: "", style: .plain, target: nil, action: #selector(exitchat))
       backbutton.leftBarButtonItem?.setBackgroundImage(UIImage(systemName: "arrow.left"), for: .normal, barMetrics: .default)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    func setupCollectionView() {
        collectionView?.backgroundColor = .clear
        collectionView?.delegate = self

        collectionView?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 50)

        // register cell
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "messcell")
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return chat.messages.count
        //return modelData.count

    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messcell", for: indexPath)
    
        // Configure the cell
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    
    
    
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    
    @objc func exitchat()
    {
        //isNotInChat()
        performSegue(withIdentifier: "exitmessages", sender: self)
    }

}
