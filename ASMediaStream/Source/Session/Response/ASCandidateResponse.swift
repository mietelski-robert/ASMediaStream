//
//  ASCandidateResponse.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

public struct ASCandidateResponse {

    // MARK: - Public attributes
    
    public let senderId: String
    public let candidate: RTCIceCandidate
    
    // MARK: - Initialization
    
    public init(senderId: String, candidate: RTCIceCandidate) {
        self.senderId = senderId
        self.candidate = candidate
    }
}
