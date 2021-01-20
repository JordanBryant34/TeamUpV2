//
//  RequestController.swift
//  Team Up
//
//  Created by Jordan Bryant on 1/12/21.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class RequestController {
    
    static let shared = RequestController()
    
    private let ref = Database.database().reference()
    let teammateRequestNotification = "teammateRequestNotification"
    
    var teammateRequests: [User] = []
    
    func requestPlayerToTeamUp(user: User, completion: @escaping (_ success: Bool) -> Void) {
        guard let currentUserName = Auth.auth().currentUser?.displayName else {
            Helpers.showNotificationBanner(title: "Something went wrong", subtitle: "We were unable to retrieve your profile. Restart Team Up and try again.", image: nil, style: .danger, textAlignment: .left)
            completion(false)
            return
        }
        
        ref.child("users").child(user.username).child("teammateRequests").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            if let requestsDictionary = snapshot.value as? [String : Any], requestsDictionary.keys.contains(currentUserName) {
                Helpers.showNotificationBanner(title: "You've already requested \(user.username)", subtitle: "", image: nil, style: .danger, textAlignment: .center)
                completion(true)
                return
            }
            
            UserController.fetchUser(username: currentUserName) { [weak self] (currentUser) in
                guard let currentUser = currentUser else { return }
                
                let userDictionary = [
                    "username" : currentUser.username,
                    "mic" : currentUser.mic.rawValue,
                    "biography" : currentUser.bio,
                    "profilePicUrl" : currentUser.profilePicUrl,
                    "region" : currentUser.region.rawValue
                ]
                
                self?.ref.child("users").child(user.username).child("teammateRequests").updateChildValues([currentUserName : userDictionary])
                Helpers.showNotificationBanner(title: "Teammate request sent to \(user.username)", subtitle: "", image: nil, style: .success, textAlignment: .center)
                completion(true)
            }
        }
    }
    
    func fetchTeammateRequests() {
        guard let currentUserName = Auth.auth().currentUser?.displayName else {
            teammateRequests = []
            NotificationCenter.default.post(name: Notification.Name(teammateRequestNotification), object: nil)
            return
        }
        
        ref.child("users").child(currentUserName).child("teammateRequests").observe(.value) { [weak self] (snapshot) in
            var users: [User] = []
            guard let strongSelf = self else { return }
            guard let dictionary = snapshot.value as? [String : Any] else {
                print("could not get dictionary")
                strongSelf.teammateRequests = users
                NotificationCenter.default.post(name: Notification.Name(strongSelf.teammateRequestNotification), object: nil)
                return
            }
            
            for key in dictionary.keys {
                if let userDictionary = dictionary[key] as? [String : Any], let user = User(dictionary: userDictionary) {
                    users.append(user)
                }
            }
            
            strongSelf.teammateRequests = users
            NotificationCenter.default.post(name: Notification.Name(strongSelf.teammateRequestNotification), object: nil)
        }
    }
    
    func acceptTeammateRequest(requestingUser: User) {
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        
        let currentUserRef = ref.child("users").child(currentUser)
        let requestingUserRef = ref.child("users").child(requestingUser.username)
        
        currentUserRef.child("teammates").updateChildValues([requestingUser.username : 1])
        requestingUserRef.child("teammates").updateChildValues([currentUser : 1])
        
        currentUserRef.child("teammateRequests").child(requestingUser.username).removeValue()
        requestingUserRef.child("teammateRequests").child(currentUser).removeValue()
        
        Helpers.showNotificationBanner(title: "\(requestingUser.username) added as a teammate", subtitle: "Send them a message!", image: nil, style: .success, textAlignment: .left)
    }
    
    func declineTeammateRequest(requestingUser: User) {
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        
        let currentUserRef = ref.child("users").child(currentUser)
        
        currentUserRef.child("teammateRequests").child(requestingUser.username).removeValue()
    }
    
    func clearDataAndObservers() {
        teammateRequests = []
        NotificationCenter.default.post(name: Notification.Name(teammateRequestNotification), object: nil)
        
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        ref.child("users").child(currentUser).child("teammateRequests").removeAllObservers()
    }
    
}
