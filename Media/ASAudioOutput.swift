//
//  ASAudioOutput.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 10.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

public struct ASAudioOutput {

    // MARK: - Public properties
    
    public var clientId: String?
    public var audioTracks: [RTCAudioTrack]
    
    // MARK: - Initialization
    
    public init(clientId: String? = nil, audioTracks: [RTCAudioTrack]) {
        self.clientId = clientId
        self.audioTracks = audioTracks
    }
}
