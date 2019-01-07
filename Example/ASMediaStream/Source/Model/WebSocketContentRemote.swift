//
//  WebSocketContentRemote.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import Foundation

struct SessionDescriptionContentRemote: Codable {
    
    // MARK: - Public properties
    
    let type: WebSocketContentTypeRemote = .sessionDescription
    let sessionDescription: SessionDescriptionRemote
    
    // MARK: - Initialization
    
    init(sessionDescription: SessionDescriptionRemote) {
        self.sessionDescription = sessionDescription
    }
}

struct CandidateContentRemote: Codable {
    
    // MARK: - Public properties
    
    let type: WebSocketContentTypeRemote = .candidate
    let candidate: CandidateRemote
    
    // MARK: - Initialization
    
    init(candidate: CandidateRemote) {
        self.candidate = candidate
    }
}

struct JoinContentRemote: Codable {
    
    // MARK: - Public properties
    
    let roomMemberIds: [String]
    
    // MARK: - Initialization
    
    init(roomMemberIds: [String]) {
        self.roomMemberIds = roomMemberIds
    }
}
