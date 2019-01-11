//
//  ASVideoOutput.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 10.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

public struct ASVideoOutput {

    // MARK: - Public properties
    
    public var clientId: String?
    public var videoTracks: [RTCVideoTrack]
    
    // MARK: - Initialization
    
    public init(clientId: String? = nil, videoTracks: [RTCVideoTrack]) {
        self.clientId = clientId
        self.videoTracks = videoTracks
    }
}
