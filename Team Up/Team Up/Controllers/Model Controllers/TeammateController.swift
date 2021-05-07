//
//  TeammateController.swift
//  Team Up
//
//  Created by Jordan Bryant on 1/7/21.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class TeammateController {
    
    static let shared = TeammateController()
    private let ref = Database.database().reference()
    
    var teammates: [User] = []
    
    func fetchTeammates() {
        guard let currentUser = Auth.auth().currentUser?.displayName else {
            teammates = []
            NotificationCenter.default.post(name: Notification.Name("teammatesUpdated"), object: nil)
            return
        }
                
        ref.child("users").child(currentUser).child("teammates").observe(.value) { [weak self] (snapshot) in
            guard let dictionary = snapshot.value as? [String : Any] else {
                self?.teammates = []
                NotificationCenter.default.post(name: Notification.Name("teammatesUpdated"), object: nil)
                return
            }
            
            let teammateNames = Array(dictionary.keys)
            
            UserController.fetchUsers(usernames: teammateNames) { [weak self] (teammates) in
                self?.teammates = self?.sortTeammates(teammates: teammates) ?? []
                NotificationCenter.default.post(name: Notification.Name("teammatesUpdated"), object: nil)
            }
        }
    }
    
    func removeTeammate(teammate: User) {
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        
        ref.child("users").child(currentUser).child("teammates").child(teammate.username).removeValue()
        ref.child("users").child(teammate.username).child("teammates").child(currentUser).removeValue()
        
        ref.child("users").child(currentUser).child("messaging").child("directChats").child(teammate.username).removeValue()
        ref.child("users").child(teammate.username).child("messaging").child("directChats").child(currentUser).removeValue()
        
        Helpers.showNotificationBanner(title: "\(teammate.username) has been removed", subtitle: "", image: nil, style: .success, textAlignment: .center)
    }
    
    func clearDataAndObservers() {
        teammates = []
        NotificationCenter.default.post(name: Notification.Name("teammatesUpdated"), object: nil)
        
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        ref.child("users").child(currentUser).child("teammates").removeAllObservers()
    }
    
    func sortTeammates(teammates: [User]) -> [User] {
        if teammates.count <= 1 {
            return teammates
        }
        
        var sortedTeammates = teammates.sorted { (teammate1, teammate2) -> Bool in
            return teammate1.username.lowercased() < teammate2.username.lowercased()
        }
        
        for teammate in sortedTeammates.reversed() {
            if teammate.currentlyPlaying != nil, let index = sortedTeammates.firstIndex(of: teammate) {
                sortedTeammates.remove(at: index)
                sortedTeammates.insert(teammate, at: 0)
            }
        }
        
        return sortedTeammates
    }
    
}
