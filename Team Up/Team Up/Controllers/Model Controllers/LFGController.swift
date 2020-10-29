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
                    if user.username != Auth.auth().currentUser?.displayName {
                        users.append(user)
                    }
                }
            }
            
            completion(users)
        }
    }
    
    static func requestPlayerToTeamUp(user: User, completion: @escaping (_ success: Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser?.displayName else {
            Helpers.showNotificationBanner(title: "Something went wrong", subtitle: "We were unable to retrieve your profile. Restart Team Up and try again.", image: nil, style: .danger, textAlignment: .left)
            completion(false)
            return
        }
        
        ref.child("users").child(user.username).child("teammateRequests").observeSingleEvent(of: .value) { (snapshot) in
            if let requestsDictionary = snapshot.value as? [String : Any], requestsDictionary.keys.contains(currentUser) {
                Helpers.showNotificationBanner(title: "You've already requested \(user.username)", subtitle: "", image: nil, style: .danger, textAlignment: .center)
                completion(true)
                return
            }
            
            ref.child("users").child(user.username).child("teammateRequests").updateChildValues([currentUser : 1])
            Helpers.showNotificationBanner(title: "Teammate request sent to \(user.username)", subtitle: "", image: nil, style: .success, textAlignment: .center)
            completion(true)
        }
    }
  
}
