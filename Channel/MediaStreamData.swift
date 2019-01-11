//
//  MediaStreamData.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 09.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

public class MediaStreamData {

    // MARK: - Public properties
    
    public let type: MediaStreamType
    public var audioTrack: RTCAudioTrack?
    public var videoTrack: RTCVideoTrack?
    
    // MARK: - Initialization
    
    public init(type: MediaStreamType, audioTrack: RTCAudioTrack? = nil, videoTrack: RTCVideoTrack? = nil) {
        self.type = type
        self.audioTrack = audioTrack
        self.videoTrack = videoTrack
    }
}
