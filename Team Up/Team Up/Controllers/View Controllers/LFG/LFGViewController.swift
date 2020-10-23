//
//  LFGViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/19/20.
//

import UIKit

class LFGViewController: UIViewController {
    
    let gameController = GameController.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .teamUpBlue()
        
        title = "LFG"
        
        getGames()
    }
    
    private func getGames() {
        gameController.fetchAllGames { (games) in
            for game in games {
                GameController.shared.fetchGameBackground(game: game) { (_) in }
                GameController.shared.fetchGameLogo(game: game) { (_) in }
            }
        }
    }
}
