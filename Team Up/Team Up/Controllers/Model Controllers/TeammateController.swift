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
    
    var teammates: [User] = []
    
    func fetchTeammates() {
        guard let currentUser = Auth.auth().currentUser?.displayName else {
            teammates = []
            NotificationCenter.default.post(name: Notification.Name("teammatesUpdated"), object: nil)
            return
        }
                
        Database.database().reference().child("users").child(currentUser).child("teammates").observe(.value) { [weak self] (snapshot) in
            guard let dictionary = snapshot.value as? [String : Any] else {
                self?.teammates = []
                NotificationCenter.default.post(name: Notification.Name("teammatesUpdated"), object: nil)
                return
            }
            
            let teammateNames = Array(dictionary.keys)
            
            UserController.fetchUsers(usernames: teammateNames) { [weak self] (teammates) in
                self?.teammates = teammates
                NotificationCenter.default.post(name: Notification.Name("teammatesUpdated"), object: nil)
            }
        }
    }
    
}
