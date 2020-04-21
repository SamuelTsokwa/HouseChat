//
//  AppDelegate.swift
//  housechat
//
//  Created by Samuel Tsokwa on 2020-02-29.
//  Copyright © 2020 Samuel Tsokwa. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        // Override point for customization after application launch.
       
       // UIApplication.shared.setMinimumBackgroundFetchInterval(3600)
//        Notifications().observeChats()
        //UIApplication.shared.applicationIconBadgeNumber = 0
        let navigationBarAppearace = UINavigationBar.appearance()
//        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "red")!]
//        navigationBarAppearace.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "red")!]
        navigationBarAppearace.tintColor = UIColor(named: "red")
       // navigationBarAppearace.tintColor = UIColor.white
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationBarAppearace.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
       

//        LoadData().loadAllUsers { user in
//            //print(user)
//        }
//        LoadData().loadChats()
       

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
//    
//    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        Notifications().observeChats()
//    }
//    
}

