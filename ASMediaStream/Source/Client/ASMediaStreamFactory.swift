//
//  ASMediaStreamFactory.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

public class ASMediaStreamFactory {

    // MARK: - Private properties
    
    private let peerConnectionFactory: RTCPeerConnectionFactory
    
    // MARK: - Initialization
    
    public init(peerConnectionFactory: RTCPeerConnectionFactory) {
        self.peerConnectionFactory = peerConnectionFactory
    }
    
    // MARK: - Access methods

    public func makeStreamConstraints(isVideoEnabled: Bool, isAudioEnabled: Bool) -> RTCMediaConstraints {
        let mandatoryConstraints: [String: String]
        
        if isVideoEnabled && isAudioEnabled {
            mandatoryConstraints = ["OfferToReceiveAudio" : "true", "OfferToReceiveVideo": "true"]
        } else if isVideoEnabled {
            mandatoryConstraints = ["OfferToReceiveVideo": "true"]
        } else if isAudioEnabled {
            mandatoryConstraints = ["OfferToReceiveAudio": "true"]
        } else {
            mandatoryConstraints = [:]
        }
        return RTCMediaConstraints(mandatoryConstraints: mandatoryConstraints, optionalConstraints: nil)
    }
    
    public func makeVideoTrack(withTrackId trackId: String) -> RTCVideoTrack {
        let videoSource: RTCVideoSource = self.peerConnectionFactory.videoSource()
        return self.peerConnectionFactory.videoTrack(with: videoSource, trackId: trackId)
    }
    
    public func makeAudioTrack(withTrackId trackId: String) -> RTCAudioTrack {
        return self.peerConnectionFactory.audioTrack(withTrackId: trackId)
    }
    
    public func makeMediaStream(withStreamId streamId: String) -> RTCMediaStream {
        return self.peerConnectionFactory.mediaStream(withStreamId: streamId)
    }
}
