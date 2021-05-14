//
//  LFGController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/28/20.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class LFGController {
    
    static private let ref = Database.database().reference()
    static private let limit: UInt = 150
    
    static func fetchPlayers(game: Game, platform: String?, region: Region?, completion: @escaping (_ users: [User], _ onlineUsers: [User]) -> Void) {
        let lfgRef = ref.child("lfg").child(game.name)
        let onlineLFGRef = ref.child("lfg").child("online").child(game.name)
        let query, onlineQuery: DatabaseQuery
        let group = DispatchGroup()
        
        var users: [User] = []
        var onlineUsers: [User] = []
        
        if let platform = platform, let region = region {
            query = lfgRef.queryOrdered(byChild: "compoundQuery").queryEqual(toValue: "\(platform)_\(region.rawValue)").queryLimited(toLast: limit)
            onlineQuery = onlineLFGRef.queryOrdered(byChild: "compoundQuery").queryEqual(toValue: "\(platform)_\(region.rawValue)").queryLimited(toLast: limit)
        } else if let platform = platform {
            query = lfgRef.queryOrdered(byChild: "platform").queryEqual(toValue: platform).queryLimited(toLast: limit)
            onlineQuery = onlineLFGRef.queryOrdered(byChild: "platform").queryEqual(toValue: platform).queryLimited(toLast: limit)
        } else if let region = region {
            query = lfgRef.queryOrdered(byChild: "region").queryEqual(toValue: region.rawValue).queryLimited(toLast: limit)
            onlineQuery = onlineLFGRef.queryOrdered(byChild: "region").queryEqual(toValue: region.rawValue).queryLimited(toLast: limit)
        } else {
            query = lfgRef.queryLimited(toLast: limit)
            onlineQuery = onlineLFGRef.queryLimited(toLast: limit)
        }
        
        group.enter()
        query.observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String : Any] else { group.leave(); return }
            users = getLFGUsersFromDictionary(dictionary: dictionary)
            group.leave()
        }
        
        group.enter()
        onlineQuery.observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String : Any] else { group.leave(); return }
            onlineUsers = getLFGUsersFromDictionary(dictionary: dictionary)
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion(users, onlineUsers)
        }
    }
  
}

private func getLFGUsersFromDictionary(dictionary: [String : Any]) -> [User] {
    var users: [User] = []
    
    for key in dictionary.keys {
        if let userDictionary = dictionary[key] as? [String : Any], let user = User(dictionary: userDictionary) {
            if user.username != Auth.auth().currentUser?.displayName && !TeammateController.shared.teammates.contains(user) {
                users.append(user)
            }
        }
    }
    
    return users
}
