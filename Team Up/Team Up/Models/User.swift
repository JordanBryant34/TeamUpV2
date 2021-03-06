//
//  User.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/23/20.
//

import Foundation

enum Region: String, CaseIterable {
    case naWest = "NA West"
    case naEast = "NA East"
    case europe = "Europe"
    case asia = "Asia"
    case australia = "Australia"
}

enum MicStatus: String, CaseIterable {
    case mic = "mic"
    case noMic = "noMic"
}

class User {

    var username: String
    var profilePicUrl: String
    var mic: MicStatus
    var bio: String
    var region: Region
    var games: [Game]
    var platform: String?
    var currentlyPlaying: String?
    
    init(username: String, profilePicUrl: String, mic: MicStatus, bio: String, region: Region, games: [Game], platform: String? = nil, currentlyPlaying: String? = nil) {
        self.username = username
        self.profilePicUrl = profilePicUrl
        self.mic = mic
        self.bio = bio
        self.region = region
        self.games = games
        self.platform = platform
        self.currentlyPlaying = currentlyPlaying
    }
    
}

extension User {
    
    convenience init?(dictionary: [String: Any]) {
        guard let username = dictionary["username"] as? String else { return nil }
        guard let biography = dictionary["biography"] as? String else { return nil }
        guard let micString = dictionary["mic"] as? String else { return nil }
        guard let profilePicUrl = dictionary["profilePicUrl"] as? String else { return nil }
        guard let regionString = dictionary["region"] as? String else { return nil }
        
        guard let mic = MicStatus(rawValue: micString) else { return nil }
        guard let region = Region(rawValue: regionString) else { return nil }
        
        var games: [Game] = []
        if let gamesDictionary = dictionary["games"] as? [String : Any] {
            for key in gamesDictionary.keys {
                if let gameDictionary = gamesDictionary[key] as? [String : Any], let game = Game(dictionary: gameDictionary) {
                    games.append(game)
                }
            }
        }
        
        var platform: String? = nil
        var currentlyPlaying: String? = nil
        
        platform = dictionary["platform"] as? String
        currentlyPlaying = dictionary["currentlyPlaying"] as? String
        
        self.init(username: username, profilePicUrl: profilePicUrl, mic: mic, bio: biography, region: region, games: games, platform: platform, currentlyPlaying: currentlyPlaying)
    }
    
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.username == rhs.username && lhs.bio == rhs.bio && lhs.region == rhs.region
    }
}
