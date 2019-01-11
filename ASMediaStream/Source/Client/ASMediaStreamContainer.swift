//
//  ASMediaStreamContainer.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 10.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

class ASMediaStreamContainer {

    // MARK: - Public properties
    
    var numberOfItems: Int {
        return self.dictionary.count
    }
    
    var items: [ASMediaStreamItem] {
        return Array(self.dictionary.values)
    }
    
    // MARK: - Private properties
    
    private var dictionary: [String: ASMediaStreamItem]
    
    // MARK: - Initialization
    
    init() {
        self.dictionary = [:]
    }
    
    // MARK: - Access methods
    
    func setItem(_ item: ASMediaStreamItem, forIdentifier identifier: String) {
        self.dictionary[identifier] = item
    }
    
    func item(identifier: String) -> ASMediaStreamItem? {
        return self.dictionary[identifier]
    }
    
    func identifier(peerConnection: RTCPeerConnection) -> String? {
        return self.dictionary.first(where: { $1.peerConnection === peerConnection })?.key
    }
    
    func identifier(dataChannelPair: ASDataChannelPair) -> String? {
        return self.dictionary.first(where: { $1.dataChannelPair === dataChannelPair })?.key
    }
    
    func identifier(sender: RTCDataChannel?) -> String? {
        return self.dictionary.first(where: { $1.dataChannelPair.sender === sender })?.key
    }
    
    func identifier(receiver: RTCDataChannel?) -> String? {
        return self.dictionary.first(where: { $1.dataChannelPair.receiver === receiver })?.key
    }
}
