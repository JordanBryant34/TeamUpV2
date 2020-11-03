//
//  DirectChat.swift
//  Team Up
//
//  Created by Jordan Bryant on 11/3/20.
//

import UIKit

class DirectChat {
    
    var chatPartner: User
    var messages: [Message]
    
    init(chatPartner: User, messages: [Message]) {
        self.chatPartner = chatPartner
        self.messages = messages
    }
    
}

extension DirectChat: Equatable {
    
    static func == (lhs: DirectChat, rhs: DirectChat) -> Bool {
        return lhs.chatPartner == rhs.chatPartner && lhs.messages == rhs.messages
    }
    
}
