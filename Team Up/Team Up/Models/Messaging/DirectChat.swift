//
//  DirectChat.swift
//  Team Up
//
//  Created by Jordan Bryant on 11/3/20.
//

import UIKit
import FirebaseAuth

class DirectChat {
    
    var chatPartner: User
    var messages: [Message]
    
    var unreadMessages: [Message] {
        guard let currentUser = Auth.auth().currentUser?.displayName else { return [] }
        let newMessages = messages.filter({ $0.fromUser != currentUser && $0.read == false })

        return newMessages
    }
    
    var hasNewMessages: Bool {
        return !unreadMessages.isEmpty
    }
    
    init(chatPartner: User, messages: [Message]) {
        self.chatPartner = chatPartner
        self.messages = messages
    }
    
}

extension DirectChat {
    
    convenience init?(chatPartner: User, dictionary: [String: Any]) {
        
        var messages: [Message] = []
        
        for key in dictionary.keys {
            if let messageDictionary = dictionary[key] as? [String : Any], let message = Message(dictionary: messageDictionary) {
                messages.append(message)
            }
        }
        
        self.init(chatPartner: chatPartner, messages: messages)
    }
    
    
}

extension DirectChat: Equatable {
    
    static func == (lhs: DirectChat, rhs: DirectChat) -> Bool {
        return lhs.chatPartner == rhs.chatPartner && lhs.messages == rhs.messages
    }
    
}
