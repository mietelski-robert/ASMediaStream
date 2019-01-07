//
//  ASSessionDescriptionResponse.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

public struct ASSessionDescriptionResponse {

    // MARK: - Public attributes
    
    public let senderId: String
    public let sessionDescription: RTCSessionDescription
    
    // MARK: - Initialization
    
    public init(senderId: String, sessionDescription: RTCSessionDescription) {
        self.senderId = senderId
        self.sessionDescription = sessionDescription
    }
}
