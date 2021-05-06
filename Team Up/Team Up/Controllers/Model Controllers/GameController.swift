//
//  GameController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/21/20.
//

import Foundation
import Firebase

class GameController {
    
    static let shared = GameController()
    
    var games: [Game] = []
    var userCurrentlyPlayedGame: Game? = nil
    var initialCurrentGameFetchComplete = false
    
    private let ref = Database.database().reference()
    
    func fetchAllGames(completion: @escaping ([Game]) -> Void = { _ in } ) {
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
    
    func fetchGameBackground(game: Game, completion: @escaping (UIImage?) -> Void = { _ in } ) {
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
    
    func fetchGameLogo(game: Game, completion: @escaping (UIImage?) -> Void = { _ in } ) {
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
    
    func getGame(name: String) -> Game? {
        return games.first(where: { $0.name == name })
    }
    
    func fetchCurrentlyPlayedGame(completion: @escaping (Game?) -> Void = { _ in } ) {
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        
        ref.child("users").child(currentUser).child("currentlyPlaying").observe(.value) { [weak self] (snapshot) in
            guard let strongSelf = self else { completion(nil); return }
            var game: Game? = nil
            
            if let gameName = snapshot.value as? String {
                if strongSelf.games.isEmpty {
                    strongSelf.fetchAllGames { (_) in
                        game = strongSelf.getGame(name: gameName)
                        strongSelf.updateCurrentlyPlayedGame(game: game)
                    }
                } else {
                    game = strongSelf.getGame(name: gameName)
                    strongSelf.updateCurrentlyPlayedGame(game: game)
                }
            } else {
                strongSelf.updateCurrentlyPlayedGame(game: game)
            }
        }
    }
    
    private func updateCurrentlyPlayedGame(game: Game?) {
        userCurrentlyPlayedGame = game
        initialCurrentGameFetchComplete = true
        NotificationCenter.default.post(name: Notification.Name("currentGameUpdated"), object: nil)
    }
    
    func goOnlineForGame(game: Game) {
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        
        UserController.fetchUser(username: currentUser) { [weak self] (user) in
            guard let user = user, let platform = game.playerPlatform, let strongSelf = self else { return }
            
            let lfgDictionary = [
                "username" : user.username,
                "region" : user.region.rawValue,
                "profilePicUrl" : user.profilePicUrl,
                "mic" : user.mic.rawValue,
                "biography" : user.bio,
                "platform" : platform,
                "compoundQuery" : "\(platform)_\(user.region.rawValue)",
                "currentlyPlaying" : game.name
            ]
            
            let gameRef = strongSelf.ref.child("lfg").child("online").child(game.name)
            gameRef.childByAutoId().updateChildValues(lfgDictionary)
            
            strongSelf.ref.child("users").child(currentUser).child("currentlyPlaying").setValue(game.name)
        }
    }
    
    func goOfflineForGame(game: Game) {
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        
        ref.child("users").child(currentUser).child("currentlyPlaying").removeValue()
        
        let gameRef = ref.child("lfg").child("online").child(game.name)
        gameRef.queryOrdered(byChild: "username").queryEqual(toValue: currentUser).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? NSDictionary, let autoId = dictionary.allKeys.first as? String {
                gameRef.child(autoId).removeValue()
            }
        }
    }
    
    func clearDataAndObservers() {
        userCurrentlyPlayedGame = nil
        NotificationCenter.default.post(name: Notification.Name("currentGameUpdated"), object: nil)
        
        guard let currentUser = Auth.auth().currentUser?.displayName else { print("could not remove currently played observer"); return }
        ref.child("users").child(currentUser).child("currentlyPlaying").removeAllObservers()
    }
    
}
