//
//  WebSocketMessageRemote.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import Foundation

// MARK: - Message interface

protocol WebSocketMessageRemote: Codable {
    associatedtype T = Codable
    
    var type: WebSocketMessageTypeRemote { get }
    var roomId: String { get }
    var senderId: String? { get }
    var content: T? { get }
}

// MARK: - Message implementation

struct SessionDescriptionMessageRemote: WebSocketMessageRemote {
    
    // MARK: - Public properties
    
    let type: WebSocketMessageTypeRemote
    let roomId: String
    let senderId: String?
    let receiverId: String?
    let content: SessionDescriptionContentRemote?
    
    // MARK: - Initialization
    
    init(roomId: String, senderId: String? = nil, receiverId: String, content: SessionDescriptionContentRemote? = nil) {
        self.type = .message
        self.roomId = roomId
        self.senderId = senderId
        self.receiverId = receiverId
        self.content = content
    }
    
    init(roomId: String, senderId: String? = nil, content: SessionDescriptionContentRemote? = nil) {
        self.type = .broadcast
        self.roomId = roomId
        self.senderId = senderId
        self.receiverId = nil
        self.content = content
    }
}

struct CandidateMessageRemote: WebSocketMessageRemote {
    
    // MARK: - Public properties
    
    let type: WebSocketMessageTypeRemote
    let roomId: String
    let senderId: String?
    let receiverId: String?
    let content: CandidateContentRemote?
    
    // MARK: - Initialization
    
    init(roomId: String, senderId: String? = nil, receiverId: String, content: CandidateContentRemote? = nil) {
        self.type = .message
        self.roomId = roomId
        self.senderId = senderId
        self.receiverId = receiverId
        self.content = content
    }
    
    init(roomId: String, senderId: String? = nil, content: CandidateContentRemote? = nil) {
        self.type = .broadcast
        self.roomId = roomId
        self.senderId = senderId
        self.receiverId = nil
        self.content = content
    }
}

struct JoinMessageRemote: WebSocketMessageRemote {
    
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
