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
    
    public var peerId: String?
    public var videoTracks: [RTCVideoTrack]
    
    // MARK: - Initialization
    
    public init(peerId: String? = nil, videoTracks: [RTCVideoTrack]) {
        self.peerId = peerId
        self.videoTracks = videoTracks
    }
}
