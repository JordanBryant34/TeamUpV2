//
//  LobbyController.swift
//  Team Up
//
//  Created by Jordan Bryant on 4/22/21.
//

import Foundation
import Firebase

class LobbyController {
    
    static let shared = LobbyController()
    
    let ref = Database.database().reference()
    
    var lobby: Lobby? = nil
    var initialFetchComplete = false
    
    func createLobby(game: Game, size: Int, title: String, description: String?, accessLevel: LobbyAccessLevel) {
        
    }
    
    func fetchUsersLobby(completion: @escaping (Bool) -> Void = { _ in } ) {
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        
        ref.child("users").child(currentUser).child("lobby").observe(.value) { [weak self] (snapshot) in
            guard let lobbyId = snapshot.value as? String else {
                self?.lobby = nil
                self?.initialFetchComplete = true
                NotificationCenter.default.post(name: Notification.Name("userLobbyUpdated"), object: nil)
                completion(true)
                return
            }
            
            print("Lobby Id: \(lobbyId)")
            
            let userLobby = Lobby(id: "lobby-id", game: Game(name: "League of Legends", platforms: ["PC"], backgroundImageUrl: "https://firebasestorage.googleapis.com/v0/b/team-up-c52ec.appspot.com/o/game-backgrounds%2Fleague.jpg?alt=media&token=1f20d438-e980-4b9c-8c50-1dc195a5c5f1", logoImageUrl: "https://firebasestorage.googleapis.com/v0/b/team-up-c52ec.appspot.com/o/game-logos%2Fleague.png?alt=media&token=a1b3d805-cae0-4a52-8c36-695a21bee9f0"), size: 4, players: ["ImJordanBryant"], title: "Lobby Title", description: "Lobby description", messages: [], leader: "ImJordanBryant", kickedUsers: [], joinRequests: [], timeCreated: 0, accessLevel: .open)
            
            self?.lobby = userLobby
            self?.initialFetchComplete = true
            NotificationCenter.default.post(name: Notification.Name("userLobbyUpdated"), object: nil)
            completion(true)
        }
    }
    
    func clearDataAndObservers() {
        lobby = nil
        NotificationCenter.default.post(name: Notification.Name("userLobbyUpdated"), object: nil)
        
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        ref.child("users").child(currentUser).child("lobby").removeAllObservers()
    }
    
}
