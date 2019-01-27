//
//  ASPeerFactory.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

class ASPeerFactory {
    
    // MARK: - Private properties
    
    private let peerConnectionFactory: RTCPeerConnectionFactory
    
    // MARK: - Initialization
    
    init(peerConnectionFactory: RTCPeerConnectionFactory) {
        self.peerConnectionFactory = peerConnectionFactory
    }
    
    // MARK: - Access methods
    
    func makePeerConnection(iceServers: [RTCIceServer], delegate: RTCPeerConnectionDelegate?) -> RTCPeerConnection {
        let configuration = self.makePeerConnectionConfiguration(iceServers: iceServers)
        let constraints = self.makePeerConnectionConstraints()
        
        return self.peerConnectionFactory.peerConnection(with: configuration,
                                                         constraints: constraints,
                                                         delegate: delegate)
    }
    
    func makePeerConnectionConfiguration(iceServers: [RTCIceServer]) -> RTCConfiguration {
        let configuration = RTCConfiguration()
        configuration.iceServers = iceServers
        
        return configuration
    }
    
    func makeDataChannelConfiguration() -> RTCDataChannelConfiguration {
        return RTCDataChannelConfiguration()
    }
    
    func makePeerConnectionConstraints() -> RTCMediaConstraints {
        return RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: ["DtlsSrtpKeyAgreement": "true"])
    }
}
