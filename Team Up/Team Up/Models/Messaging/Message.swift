//
//  Message.swift
//  Team Up
//
//  Created by Jordan Bryant on 11/3/20.
//

import Foundation

class Message {
    
    var text: String?
    var imageUrl: String?
    var fromUser: String
    var timestamp: Int
    
    init(text: String?, imageUrl: String?, fromUser: String, timestamp: Int) {
        self.text = text
        self.imageUrl = imageUrl
        self.fromUser = fromUser
        self.timestamp = timestamp
    }
    
}

extension Message: Equatable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.text == rhs.text && lhs.imageUrl == rhs.imageUrl && lhs.fromUser == rhs.fromUser && lhs.timestamp == rhs.timestamp
    }
    
}
