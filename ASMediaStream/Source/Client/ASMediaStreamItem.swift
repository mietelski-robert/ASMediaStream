//
//  ASMediaStreamItem.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 10.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

struct ASMediaStreamItem {

    // MARK: - Public properties
    
    let peerConnection: RTCPeerConnection?
    let dataChannelPair: ASDataChannelPair
    
    // MARK: - Initialization
    
    init(peerConnection: RTCPeerConnection?, dataChannelPair: ASDataChannelPair) {
        self.peerConnection = peerConnection
        self.dataChannelPair = dataChannelPair
    }
}
