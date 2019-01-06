//
//  ASSessionDescriptionRequest.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

public struct ASSessionDescriptionRequest {

    // MARK: - Public attributes
    
    public let receiverId: String?
    public let sessionDescription: RTCSessionDescription
    
    // MARK: - Initialization
    
    public init(receiverId: String? = nil, sessionDescription: RTCSessionDescription) {
        self.receiverId = receiverId
        self.sessionDescription = sessionDescription
    }
}
