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
    
    static func fetchPlayers(game: Game, platform: String?, region: Region?, completion: @escaping ([User]) -> Void) {
        let lfgRef = ref.child("lfg").child(game.name)
        let limit: UInt = 150
        let query: DatabaseQuery
        
        if let platform = platform, let region = region {
            query = lfgRef.queryOrdered(byChild: "compoundQuery").queryEqual(toValue: "\(platform)_\(region.rawValue)").queryLimited(toLast: limit)
        } else if let platform = platform {
            query = lfgRef.queryOrdered(byChild: "platform").queryEqual(toValue: platform).queryLimited(toLast: limit)
        } else if let region = region {
            query = lfgRef.queryOrdered(byChild: "region").queryEqual(toValue: region.rawValue).queryLimited(toLast: limit)
        } else {
            query = lfgRef.queryLimited(toLast: limit)
        }
        
        query.observeSingleEvent(of: .value) { (snapshot) in
            var users: [User] = []
            
            guard let dictionary = snapshot.value as? [String : Any] else {
                completion(users)
                return
            }
            
            for key in dictionary.keys {
                if let userDictionary = dictionary[key] as? [String : Any], let user = User(dictionary: userDictionary) {
                    if user.username != Auth.auth().currentUser?.displayName && !TeammateController.shared.teammates.contains(user) {
                        users.append(user)
                    }
                }
            }
            
            completion(users)
        }
    }
  
}
