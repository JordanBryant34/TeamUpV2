//
//  AppDelegate.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/19/20.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        styleNavigationControllers()
        
        getGames()
        
        return true
    }
    
    private func getGames() {
        GameController.fetchAllGames { (games) in
            for game in games {
                GameController.fetchGameBackground(game: game) { (_) in }
                GameController.fetchGameLogo(game: game) { (_) in }
            }
        }
    }
    
    private func styleNavigationControllers() {
        UINavigationBar.appearance().barTintColor = .teamUpDarkBlue()
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
        UINavigationBar.appearance().isTranslucent = false
    }
    
}

