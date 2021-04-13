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
    var tabBarController: TabBarController?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        setupWindow(windowScene: windowScene)
        checkIfSignedIn()
    }
    
    private func setupWindow(windowScene: UIWindowScene) {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .dark
        }
        
        window?.windowScene = windowScene
        window?.makeKeyAndVisible()
    }
    
    private func checkIfSignedIn() {
        if Auth.auth().currentUser == nil {
            window?.rootViewController = UINavigationController(rootViewController: SignInViewController())
        } else {
            UserController.fetchUserData()
            tabBarController = TabBarController()
            window?.rootViewController = tabBarController
        }
    }

}

