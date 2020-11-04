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

extension Message {
    
    convenience init?(dictionary: [String: Any]) {
        guard let fromUser = dictionary["fromUser"] as? String else { return nil }
        guard let timestamp = dictionary["timestamp"] as? Int else { return nil }
        let text = dictionary["text"] as? String
        let imageUrl = dictionary["imageUrl"] as? String
        
        self.init(text: text, imageUrl: imageUrl, fromUser: fromUser, timestamp: timestamp)
    }
    
}

extension Message: Equatable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.text == rhs.text && lhs.imageUrl == rhs.imageUrl && lhs.fromUser == rhs.fromUser && lhs.timestamp == rhs.timestamp
    }
    
}
