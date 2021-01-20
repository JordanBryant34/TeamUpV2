//
//  MessageController.swift
//  Team Up
//
//  Created by Jordan Bryant on 11/4/20.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class MessageController {
    
    static let shared = MessageController()
    private let ref = Database.database().reference()
    
    var chats: [DirectChat] = []
    
    func fetchChats() {
        guard let currentUser = Auth.auth().currentUser?.displayName else {
            chats = []
            NotificationCenter.default.post(name: Notification.Name("messagesUpdated"), object: nil)
            return
        }
        
        ref.child("users").child(currentUser).child("messaging").child("directChats").observe(.value) { [weak self] (snapshot) in
            var fetchedChats: [DirectChat] = []
            guard let dictionary = snapshot.value as? [String : Any] else {
                self?.chats = []
                NotificationCenter.default.post(name: Notification.Name("messagesUpdated"), object: nil)
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            for key in dictionary.keys {
                guard let chatDictionary = dictionary[key] as? [String : Any] else { return }
                
                dispatchGroup.enter()
                
                UserController.fetchUser(username: key) { (user) in
                    guard let user = user else { return }
                    
                    if let chat = DirectChat(chatPartner: user, dictionary: chatDictionary), chat.messages.count > 0 {
                        chat.messages = chat.messages.sorted(by: { $0.timestamp < $1.timestamp })
                        fetchedChats.append(chat)
                    }
                    
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self?.chats = fetchedChats
                NotificationCenter.default.post(name: Notification.Name("messagesUpdated"), object: nil)
            }
        }
    }
    
    func fetchDirectChat(chatParter: User) -> DirectChat? {
        for chat in chats {
            if chat.chatPartner == chatParter {
                return chat
            }
        }
        
        return nil
    }
    
    func sendDirectMessage(messageText: String, chatPartner: User) {
        guard let username = Auth.auth().currentUser?.displayName else { return }
        
        let userMessageRef = ref.child("users").child(username).child("messaging").child("directChats").child(chatPartner.username)
        let chatPartnerRef = ref.child("users").child(chatPartner.username).child("messaging").child("directChats").child(username)
        
        let message = Message(text: messageText, imageUrl: nil, fromUser: username, timestamp: Int(Date().timeIntervalSince1970))
        
        userMessageRef.childByAutoId().updateChildValues(message.asDictionary())
        chatPartnerRef.childByAutoId().updateChildValues(message.asDictionary())
    }
    
    func deleteDirectChat(chat: DirectChat) {
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        
        let chatRef = ref.child("users").child(currentUser).child("messaging").child("directChats").child(chat.chatPartner.username)
        chatRef.removeValue()
    }
    
    func clearDataAndObservers() {
        chats = []
        NotificationCenter.default.post(name: Notification.Name("messagesUpdated"), object: nil)
        
        guard let currentUser = Auth.auth().currentUser?.displayName else { print("could not remove message observers"); return }
        ref.child("users").child(currentUser).child("messaging").child("directChats").removeAllObservers()
    }
    
}
