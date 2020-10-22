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
    
    init(name: String, platforms: [String], backgroundImageUrl: String, logoImageUrl: String) {
        self.name = name
        self.platforms = platforms
        self.backgroundImageUrl = backgroundImageUrl
        self.logoImageUrl = logoImageUrl
    }
    
}

extension Game {
    
    convenience init?(dictionary: [String: AnyObject]) {
        guard let name = dictionary["name"] as? String else { print("could not unwrap name"); return nil }
        guard let platformsDict = dictionary["platforms"] as? NSDictionary else { print("could not unwrap platforms game dictionary"); return nil }
        guard let platforms = platformsDict.allKeys as? [String] else { print("could not unwrap platforms"); return nil }
        guard let backgroundImageUrl = dictionary["backgroundImageUrl"] as? String else { print("could not unwrap backgroundImageUrl"); return nil }
        guard let logoImageUrl = dictionary["logoImageUrl"] as? String else { print("could not unwrap logoImageUrl"); return nil }
        
        self.init(name: name, platforms: platforms, backgroundImageUrl: backgroundImageUrl, logoImageUrl: logoImageUrl)
    }
    
}
