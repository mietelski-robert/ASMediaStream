//
//  ASMediaStreamConnectionFactory.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

public class ASMediaStreamConnectionFactory {
    
    // MARK: - Private attributes
    
    private let connectionFactory: RTCPeerConnectionFactory = RTCPeerConnectionFactory()
    
    // MARK: - Access methods
    
    public func makePeerConnection(iceServers: [RTCIceServer], delegate: RTCPeerConnectionDelegate?) -> RTCPeerConnection {
        let configuration = self.makePeerConnectionConfiguration(iceServers: iceServers)
        let constraints = self.makePeerConnectionConstraints()
        
        return self.connectionFactory.peerConnection(with: configuration,
                                                     constraints: constraints,
                                                     delegate: delegate)
    }
    
    public func makePeerConnectionConfiguration(iceServers: [RTCIceServer]) -> RTCConfiguration {
        let configuration = RTCConfiguration()
        configuration.iceServers = iceServers
        
        return configuration
    }
    
    public func makePeerConnectionConstraints() -> RTCMediaConstraints {
        return RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: ["DtlsSrtpKeyAgreement": "true"])
    }
    
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
        let videoSource: RTCVideoSource = self.connectionFactory.videoSource()
        return self.connectionFactory.videoTrack(with: videoSource, trackId: trackId)
    }
    
    public func makeAudioTrack(withTrackId trackId: String) -> RTCAudioTrack {
        return self.connectionFactory.audioTrack(withTrackId: trackId)
    }
    
    public func makeMediaStream(withStreamId streamId: String) -> RTCMediaStream {
        return self.connectionFactory.mediaStream(withStreamId: streamId)
    }
}
