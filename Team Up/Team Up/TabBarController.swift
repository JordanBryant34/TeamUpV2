//
//  TabBarController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/19/20.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
    }
    
    private func setupTabBar() {
        let lfgController = UINavigationController(rootViewController: LFGViewController())
        let teammatesController = UINavigationController(rootViewController: TeammatesViewController())
        let messagesController = UINavigationController(rootViewController: MessagesViewController())
        let profileController = UINavigationController(rootViewController: ProfileViewController())
        
        setViewControllers([lfgController, teammatesController, messagesController, profileController], animated: true)
        
        lfgController.tabBarItem = UITabBarItem(title: "LFG", image: nil, selectedImage: nil)
        teammatesController.tabBarItem = UITabBarItem(title: "Teammates", image: nil, selectedImage: nil)
        messagesController.tabBarItem = UITabBarItem(title: "Messages", image: nil, selectedImage: nil)
        profileController.tabBarItem = UITabBarItem(title: "Profile", image: nil, selectedImage: nil)
    }
}
