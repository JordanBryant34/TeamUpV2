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
    var read: Bool = false
    var id: String
    
    init(text: String?, imageUrl: String?, fromUser: String, timestamp: Int, read: Bool, id: String) {
        self.text = text
        self.imageUrl = imageUrl
        self.fromUser = fromUser
        self.timestamp = timestamp
        self.read = read
        self.id = id
    }
    
    func markAsRead() {
        self.read = true
    }
    
}

extension Message {
    
    convenience init?(dictionary: [String: Any]) {
        guard let fromUser = dictionary["fromUser"] as? String else { return nil }
        guard let timestamp = dictionary["timestamp"] as? Int else { return nil }
        guard let id = dictionary["id"] as? String else { return nil}
        let text = dictionary["text"] as? String
        let imageUrl = dictionary["imageUrl"] as? String
        let read = dictionary["read"] as? Bool ?? false
        
        self.init(text: text, imageUrl: imageUrl, fromUser: fromUser, timestamp: timestamp, read: read, id: id)
    }
    
    func asDictionary() -> [String : Any] {
        var dictionary: [String : Any] = [
            "fromUser" : fromUser,
            "timestamp" : timestamp,
            "read" : read,
            "id" : id
        ]
        
        if let text = text {
            dictionary["text"] = text
        }
        
        if let imageUrl = imageUrl {
            dictionary["imageUrl"] = imageUrl
        }
        
        return dictionary
    }
    
}

extension Message: Equatable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.text == rhs.text && lhs.imageUrl == rhs.imageUrl && lhs.fromUser == rhs.fromUser && lhs.timestamp == rhs.timestamp && lhs.id == rhs.id
    }
    
}
