//
//  GameController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/21/20.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

enum GameImageType: String {
    case logo = "game-logos"
    case background = "game-backgrounds"
}

class GameController {
    
    static let shared = GameController()
    
    var games: [Game] = []
    
    private let ref = Database.database().reference()
    
    func fetchAllGames(completion: @escaping ([Game]) -> Void) {
        let gamesRef = ref.child("games")
        var games: [Game] = []
        
        gamesRef.observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let gamesDictionary = snapshot.value as? NSDictionary else {
                completion(games)
                return
            }
            
            for key in gamesDictionary.allKeys {
                if let dictionary = gamesDictionary[key] as? [String : AnyObject], let game = Game(dictionary: dictionary) {
                    games.append(game)
                }
            }
            
            games = games.sorted(by: { $0.name < $1.name })
            
            self?.games = games
            completion(games)
        }
    }
    
    func fetchGameBackground(game: Game, completion: @escaping (UIImage?) -> Void) {
        let path = "\(game.name)_background.jpg"
        
        if let image = Helpers.getImageFromFile(pathComponent: path) {
            completion(image)
        } else {
            guard let imageUrl = URL(string: game.backgroundImageUrl) else { return completion(nil) }
            
            ImageService.getImage(withURL: imageUrl) { (image) in
                guard let image = image else { return completion(nil) }
                let width = UIScreen.main.bounds.width
                let height = width * (9/16)
                
                Helpers.storeJpgToFile(image: image, pathComponent: path, size: CGSize(width: width, height: height))
                
                completion(image.resize(newSize: CGSize(width: width, height: height)))
            }
        }
    }
    
    func fetchGameLogo(game: Game, completion: @escaping (UIImage?) -> Void) {
        let path = "\(game.name)_logo.png"
        
        if let image = Helpers.getImageFromFile(pathComponent: path) {
            completion(image)
        } else {
            guard let imageUrl = URL(string: game.logoImageUrl) else { return completion(nil) }
            
            ImageService.getImage(withURL: imageUrl) { (image) in
                guard let image = image else { return completion(nil) }
                
                Helpers.storePngToFile(image: image, pathComponent: path, size: image.size)
                
                completion(image)
            }
        }
    }
    
    func searchGames(searchText: String) -> [Game] {
        let results = games.filter {
            var isMatch = false

            for word in $0.name.split(separator: " ") {
                if word.hasPrefix(searchText) {
                    isMatch = true
                }
            }
            
            if searchText.count >= 4 && $0.name.lowercased().contains(searchText.lowercased()) {
                isMatch = true
            }

            return isMatch
        }
        
        return results
    }
    
}
