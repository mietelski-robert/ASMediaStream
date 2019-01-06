//
//  CandidateRemote.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 20.12.2018.
//  Copyright © 2018 Robert Mietelski. All rights reserved.
//

import WebRTC

struct CandidateRemote: Codable {
    
    // MARK: - Public attributes
    
    var sdp: String
    var sdpMLineIndex: Int32
    var sdpMid: String?
    
    // MARK: - Initialization
    
    init(domain: RTCIceCandidate) {
        self.sdp = domain.sdp
        self.sdpMLineIndex = domain.sdpMLineIndex
        self.sdpMid = domain.sdpMid
    }
}
