//
//  ASDataChannelPair.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 10.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

class ASDataChannelPair {

    // MARK: - Public properties
    
    let sender: RTCDataChannel?
    let receiver: RTCDataChannel?
    
    // MARK: - Initialization
    
    init(sender: RTCDataChannel? = nil, receiver: RTCDataChannel? = nil) {
        self.sender = sender
        self.receiver = receiver
    }
}
