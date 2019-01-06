//
//  SessionDescriptionRemote.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 20.12.2018.
//  Copyright © 2018 Robert Mietelski. All rights reserved.
//

import WebRTC

struct SessionDescriptionRemote: Codable {
    
    // MARK: - Public attributes
    
    var type: Int
    var sdp: String
    
    // MARK: - Initialization
    
    init(domain: RTCSessionDescription) {
        self.type = domain.type.rawValue
        self.sdp = domain.sdp
    }
}
