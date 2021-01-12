//
//  SceneDelegate.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/19/20.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        setupWindow(windowScene: windowScene)
        checkIfSignedIn()
    }
    
    private func setupWindow(windowScene: UIWindowScene) {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.windowScene = windowScene
        window?.makeKeyAndVisible()
    }
    
    private func checkIfSignedIn() {
        if Auth.auth().currentUser == nil {
            window?.rootViewController = UINavigationController(rootViewController: SignInViewController())
        } else {
//            try? Auth.auth().signOut()
            MessageController.shared.fetchChats()
            TeammateController.shared.fetchTeammates()
            RequestController.shared.fetchTeammateRequests()
            window?.rootViewController = TabBarController()
        }
    }

}

