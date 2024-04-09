//
//  AppDelegate.swift
//  MusicPlayer
//
//  Created by Suvendu Kumar on 06/04/24.
//

import UIKit
import AVKit
import MediaPlayer

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tabBarController : TabBarController!
    var isFirstTime : Bool = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        initialiseTabBarController()
        
        MPMediaPlayerManager.shared.requestRemoteCommandHandling() // Request for remote controlling Event controll
        MPMediaPlayerManager.shared.setupRemoteTransportControls() // Track all remote event and take appropiate action
        return true
    }
    
    func initialiseTabBarController() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        tabBarController = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController
    
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        setupCurrentTrackInGlobalView()
    }
    

    //MARK:- Share Appdelegate
    func storyboard() -> UIStoryboard
    {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    func sharedDelegate() -> AppDelegate
    {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    
    func setupCurrentTrackInGlobalView() {
        if tabBarController != nil {
            tabBarController.tabBarView.setupCurrentTrackData()
        }
    }


}

