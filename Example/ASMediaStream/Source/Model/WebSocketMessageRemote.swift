//
//  WebSocketMessageRemote.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import Foundation

struct SessionDescriptionMessageRemote: Codable {
    
    // MARK: - Public properties
    
    let type: WebSocketMessageTypeRemote
    let roomId: String
    let senderId: String
    let receiverId: String?
    let content: SessionDescriptionContentRemote
    
    // MARK: - Initialization
    
    init(roomId: String, senderId: String, receiverId: String, content: SessionDescriptionContentRemote) {
        self.type = .message
        self.roomId = roomId
        self.senderId = senderId
        self.receiverId = receiverId
        self.content = content
    }
    
    init(roomId: String, senderId: String, content: SessionDescriptionContentRemote) {
        self.type = .broadcast
        self.roomId = roomId
        self.senderId = senderId
        self.receiverId = nil
        self.content = content
    }
}

struct CandidateMessageRemote: Codable {
    
    // MARK: - Public properties
    
    let type: WebSocketMessageTypeRemote
    let roomId: String
    let senderId: String
    let receiverId: String?
    let content: CandidateContentRemote
    
    // MARK: - Initialization
    
    init(roomId: String, senderId: String, receiverId: String, content: CandidateContentRemote) {
        self.type = .message
        self.roomId = roomId
        self.senderId = senderId
        self.receiverId = receiverId
        self.content = content
    }
    
    init(roomId: String, senderId: String, content: CandidateContentRemote) {
        self.type = .broadcast
        self.roomId = roomId
        self.senderId = senderId
        self.receiverId = nil
        self.content = content
    }
}

struct JoinMessageRemote: Codable {
    
    // MARK: - Public properties
    
    let type: WebSocketMessageTypeRemote = .join
    let roomId: String
    let senderId: String?
    let content: JoinContentRemote?
    
    // MARK: - Initialization
    
    init(roomId: String, senderId: String? = nil, content: JoinContentRemote? = nil) {
        self.roomId = roomId
        self.senderId = senderId
        self.content = content
    }
}
