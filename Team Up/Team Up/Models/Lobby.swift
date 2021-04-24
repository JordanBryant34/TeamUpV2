//
//  Lobby.swift
//  Team Up
//
//  Created by Jordan Bryant on 4/22/21.
//

import Foundation

enum LobbyAccessLevel: String, CaseIterable {
    case open = "Open"
    case inviteOnly = "Invite Only"
}

class Lobby {
    
    let id: String
    let game: Game
    let size: Int
    var players: [String]
    let title: String
    let description: String?
    var messages: [Message]
    let leader: String
    var kickedUsers: [String]
    var joinRequests: [String]
    var timeCreated: Int
    var accessLevel: LobbyAccessLevel
    
    init(id: String, game: Game, size: Int, players: [String] = [], title: String, description: String?, messages: [Message] = [], leader: String,
         kickedUsers: [String] = [], joinRequests: [String] = [], timeCreated: Int, accessLevel: LobbyAccessLevel) {
        
        self.id = id
        self.game = game
        self.size = size
        self.players = players
        self.title = title
        self.description = description
        self.messages = messages
        self.leader = leader
        self.kickedUsers = kickedUsers
        self.joinRequests = joinRequests
        self.timeCreated = timeCreated
        self.accessLevel = accessLevel
        
    }
    
}


/// TODO: once dictionary is retrieved from firebase, fill out this function to be able to init straight from the firebase dictionary
//extension Lobby {
//
//    convenience init?(dictionary: [String: Any]) {
//
//    }
//
//}

extension Lobby: Equatable {
    static func == (lhs: Lobby, rhs: Lobby) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.leader == rhs.leader
            && rhs.size == lhs.size && rhs.timeCreated == lhs.timeCreated
    }
}
