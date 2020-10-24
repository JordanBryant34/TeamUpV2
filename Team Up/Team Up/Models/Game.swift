//
//  Game.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/21/20.
//

import Foundation

class Game {
    
    let name: String
    let platforms: [String]
    let backgroundImageUrl: String
    let logoImageUrl: String
    var playerPlatform: String?
    
    init(name: String, platforms: [String], backgroundImageUrl: String, logoImageUrl: String, playerPlatform: String? = nil) {
        self.name = name
        self.platforms = platforms
        self.backgroundImageUrl = backgroundImageUrl
        self.logoImageUrl = logoImageUrl
        self.playerPlatform = playerPlatform
    }
    
}

extension Game {
    
    convenience init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String else { return nil }
        guard let platformsDict = dictionary["platforms"] as? NSDictionary else { return nil }
        guard let platforms = platformsDict.allKeys as? [String] else { return nil }
        guard let backgroundImageUrl = dictionary["backgroundImageUrl"] as? String else { return nil }
        guard let logoImageUrl = dictionary["logoImageUrl"] as? String else { return nil }
        let playerPlatform = dictionary["playerPlatform"] as? String
        
        self.init(name: name, platforms: platforms, backgroundImageUrl: backgroundImageUrl, logoImageUrl: logoImageUrl, playerPlatform: playerPlatform)
    }
    
}

extension Game: Equatable {}

func ==(lhs: Game, rhs: Game) -> Bool {
    return lhs.name == rhs.name
}
