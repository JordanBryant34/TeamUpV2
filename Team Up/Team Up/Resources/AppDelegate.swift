//
//  AppDelegate.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/19/20.
//

import UIKit
import Firebase
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        styleNavigationControllers()
        
        UserController.fetchFCMToken()
        AdController.shared.loadAds()
        
        return true
    }
    
    private func styleNavigationControllers() {
        UINavigationBar.appearance().barTintColor = .teamUpDarkBlue()
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
        UINavigationBar.appearance().isTranslucent = false
    }
    
}

