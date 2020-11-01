//
//  TabBarController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/19/20.
//

import UIKit
import FirebaseAuth

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getGames()
        setupTabBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkIfProfileIsSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupTabBar() {
        let lfgController = UINavigationController(rootViewController: LFGViewController())
        let teammatesController = UINavigationController(rootViewController: TeammatesViewController())
        let messagesController = UINavigationController(rootViewController: MessagesViewController())
        
        let profileVC = ProfileViewController()
        profileVC.currentUser = true
        let profileController = UINavigationController(rootViewController: profileVC)
        
        setViewControllers([lfgController, teammatesController, messagesController, profileController], animated: true)
        
        lfgController.tabBarItem = UITabBarItem(title: "LFG", image: nil, selectedImage: nil)
        teammatesController.tabBarItem = UITabBarItem(title: "Teammates", image: nil, selectedImage: nil)
        messagesController.tabBarItem = UITabBarItem(title: "Messages", image: nil, selectedImage: nil)
        profileController.tabBarItem = UITabBarItem(title: "Profile", image: nil, selectedImage: nil)
        
        tabBar.barTintColor = .teamUpDarkBlue()
        tabBar.isTranslucent = false
    }
    
    private func checkIfProfileIsSetup() {
        if Auth.auth().currentUser == nil {
            let signInController = UINavigationController(rootViewController: SignInViewController())
            signInController.modalPresentationStyle = .overFullScreen
            present(signInController, animated: true, completion: nil)
        } else if Auth.auth().currentUser?.displayName == nil {
            let setupProfileController = UINavigationController(rootViewController: SetupProfileViewController())
            setupProfileController.modalPresentationStyle = .overFullScreen
            present(setupProfileController, animated: true, completion: nil)
        }
    }
    
    private func getGames() {
        GameController.shared.fetchAllGames { (games) in
            for game in games {
                GameController.shared.fetchGameBackground(game: game) { (_) in }
                GameController.shared.fetchGameLogo(game: game) { (_) in }
            }
        }
    }

}
