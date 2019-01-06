//
//  ASCandidateRequest.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

public struct ASCandidateRequest {

    // MARK: - Public attributes
    
    public let receiverId: String?
    public let candidate: RTCIceCandidate
    
    // MARK: - Initialization
    
    public init(receiverId: String? = nil, candidate: RTCIceCandidate) {
        self.receiverId = receiverId
        self.candidate = candidate
    }
}
