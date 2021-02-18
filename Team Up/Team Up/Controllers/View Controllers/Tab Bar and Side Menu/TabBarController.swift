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
                
        lfgController.tabBarItem = UITabBarItem(title: "LFG", image: UIImage(named: "lfgIcon"), selectedImage: nil)
        teammatesController.tabBarItem = UITabBarItem(title: "Teammates", image: UIImage(named: "teammatesIcon"), selectedImage: nil)
        messagesController.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(named: "messagesIcon"), selectedImage: nil)
        profileController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profileIcon"), selectedImage: nil)
        
        tabBar.barTintColor = .teamUpDarkBlue()
        tabBar.unselectedItemTintColor = .secondaryLabelColor()
        tabBar.tintColor = .accent()
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
        } else if let currentUser = Auth.auth().currentUser?.displayName {
            UserController.fetchUsersGames(username: currentUser) { [weak self] (games) in
                if games.isEmpty {
                    let addGamesViewController = AddGamesViewController()
                    addGamesViewController.isEditingSettings = true
                    let addGamesNavigationController = UINavigationController(rootViewController: addGamesViewController)
                    addGamesNavigationController.modalPresentationStyle = .overFullScreen
                    self?.present(addGamesNavigationController, animated: true, completion: nil)
                }
            }
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
