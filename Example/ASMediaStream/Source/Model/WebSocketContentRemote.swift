//
//  WebSocketContentRemote.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import Foundation

// MARK: - Content interface

protocol WebSocketContentRemote: Codable {

}

// MARK: - Content implementation

struct SessionDescriptionContentRemote: WebSocketContentRemote {
    
    // MARK: - Public properties
    
    let type: WebSocketContentTypeRemote = .sessionDescription
    let sessionDescription: SessionDescriptionRemote
    
    // MARK: - Initialization
    
    init(sessionDescription: SessionDescriptionRemote) {
        self.sessionDescription = sessionDescription
    }
}

struct CandidateContentRemote: WebSocketContentRemote {
    
    // MARK: - Public properties
    
    let type: WebSocketContentTypeRemote = .candidate
    let candidate: CandidateRemote
    
    // MARK: - Initialization
    
    init(candidate: CandidateRemote) {
        self.candidate = candidate
    }
}

struct JoinContentRemote: WebSocketContentRemote {
    
    // MARK: - Public properties
    
    let roomMembers: Int
    
    // MARK: - Initialization
    
    init(roomMembers: Int) {
        self.roomMembers = roomMembers
    }
}
