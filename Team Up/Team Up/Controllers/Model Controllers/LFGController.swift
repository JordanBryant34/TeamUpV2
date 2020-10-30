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
        guard let currentUserName = Auth.auth().currentUser?.displayName else {
            Helpers.showNotificationBanner(title: "Something went wrong", subtitle: "We were unable to retrieve your profile. Restart Team Up and try again.", image: nil, style: .danger, textAlignment: .left)
            completion(false)
            return
        }
        
        ref.child("users").child(user.username).child("teammateRequests").observeSingleEvent(of: .value) { (snapshot) in
            if let requestsDictionary = snapshot.value as? [String : Any], requestsDictionary.keys.contains(currentUserName) {
                Helpers.showNotificationBanner(title: "You've already requested \(user.username)", subtitle: "", image: nil, style: .danger, textAlignment: .center)
                completion(true)
                return
            }
            
            UserController.fetchUser(username: currentUserName) { (currentUser) in
                guard let currentUser = currentUser else { return }
                
                let userDictionary = [
                    "username" : currentUser.username,
                    "mic" : currentUser.mic.rawValue,
                    "biography" : currentUser.bio,
                    "profilePicUrl" : currentUser.profilePicUrl,
                    "region" : currentUser.region.rawValue
                ]
                
                ref.child("users").child(user.username).child("teammateRequests").updateChildValues([currentUserName : userDictionary])
                Helpers.showNotificationBanner(title: "Teammate request sent to \(user.username)", subtitle: "", image: nil, style: .success, textAlignment: .center)
                completion(true)
            }
        }
    }
    
    static func fetchTeammateRequests(completion: @escaping ([User]) -> Void) {
        var users: [User] = []
        
        guard let currentUserName = Auth.auth().currentUser?.displayName else {
            Helpers.showNotificationBanner(title: "Something went wrong", subtitle: "We were unable to retrieve your profile. Restart Team Up and try again.", image: nil, style: .danger, textAlignment: .left)
            completion(users)
            return
        }
        
        ref.child("users").child(currentUserName).child("teammateRequests").observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String : Any] else {
                completion(users)
                return
            }
            
            for key in dictionary.keys {
                if let userDictionary = dictionary[key] as? [String : Any], let user = User(dictionary: userDictionary) {
                    users.append(user)
                }
            }
            
            completion(users)
        }
    }
    
    static func acceptTeammateRequest(requestingUser: User) {
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        
        let currentUserRef = ref.child("users").child(currentUser)
        let requestingUserRef = ref.child("users").child(requestingUser.username)
        
        currentUserRef.child("teammates").updateChildValues([requestingUser.username : 1])
        requestingUserRef.child("teammates").updateChildValues([currentUser : 1])
        
        currentUserRef.child("teammateRequests").child(requestingUser.username).removeValue()
        requestingUserRef.child("teammateRequests").child(currentUser).removeValue()
        
        Helpers.showNotificationBanner(title: "\(requestingUser.username) added as a teammate", subtitle: "Send them a message!", image: nil, style: .success, textAlignment: .left)
    }
    
    static func declineTeammateRequest(requestingUser: User) {
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        
        let currentUserRef = ref.child("users").child(currentUser)
        
        currentUserRef.child("teammateRequests").child(requestingUser.username).removeValue()
    }
  
}
