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
    
    func requestPlayerToTeamUp(username: String, completion: @escaping (_ success: Bool) -> Void) {
        AdController.shared.requestsCount += 1
        
        guard let currentUserName = Auth.auth().currentUser?.displayName else {
            Helpers.showNotificationBanner(title: "Something went wrong", subtitle: "We were unable to retrieve your profile. Restart Team Up and try again.", image: nil, style: .danger, textAlignment: .left)
            completion(false)
            return
        }
        
        ref.child("users").child(username).child("teammateRequests").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            if let requestsDictionary = snapshot.value as? [String : Any], requestsDictionary.keys.contains(currentUserName) {
                Helpers.showNotificationBanner(title: "You've already requested \(username)", subtitle: "", image: nil, style: .danger, textAlignment: .center)
                completion(true)
                return
            }
            
            self?.ref.child("users").child(username).child("teammateRequests").updateChildValues([currentUserName : 1])
            Helpers.showNotificationBanner(title: "Teammate request sent to \(username)", subtitle: "", image: nil, style: .success, textAlignment: .center)
            
            completion(true)
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
                strongSelf.teammateRequests = users
                NotificationCenter.default.post(name: Notification.Name(strongSelf.teammateRequestNotification), object: nil)
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            for key in dictionary.keys {
                dispatchGroup.enter()
                UserController.fetchUser(username: key) { (user) in
                    if let user = user {
                        users.append(user)
                    }
                    
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                strongSelf.teammateRequests = users
                NotificationCenter.default.post(name: Notification.Name(strongSelf.teammateRequestNotification), object: nil)
                strongSelf.updateTeammatesNotificationBadge()
            }
            
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
        
        removeRequest(requestingUser: requestingUser)
        updateTeammatesNotificationBadge()
    }
    
    func declineTeammateRequest(requestingUser: User) {
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        
        let currentUserRef = ref.child("users").child(currentUser)
        
        currentUserRef.child("teammateRequests").child(requestingUser.username).removeValue()
        
        removeRequest(requestingUser: requestingUser)
        updateTeammatesNotificationBadge()
    }
    
    func updateTeammatesNotificationBadge() {
        let scene = UIApplication.shared.connectedScenes.first
        guard let sceneDelegate = (scene?.delegate as? SceneDelegate) else { return }
        guard let tabBarController = sceneDelegate.tabBarController else { return }
        
        if teammateRequests.count > 0 {
            tabBarController.addBadgeToTabBarItemIndex(index: 1)
        } else  {
            tabBarController.removeBadgeFromTabBarItemIndex(index: 1)
        }
    }
    
    private func removeRequest(requestingUser: User) {
        if let index = teammateRequests.firstIndex(of: requestingUser) {
            teammateRequests.remove(at: index)
        }
    }
    
    func clearDataAndObservers() {
        teammateRequests = []
        NotificationCenter.default.post(name: Notification.Name(teammateRequestNotification), object: nil)
        
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        ref.child("users").child(currentUser).child("teammateRequests").removeAllObservers()
    }
    
}
