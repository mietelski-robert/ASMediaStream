//
//  ASPeer.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 10.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

public class ASPeer: NSObject {

    // MARK: - Public properties
    
    weak var delegate: ASPeerDelegate?
    
    // MARK: - Private properties
    
    private var peerConnection: RTCPeerConnection?
    private var dataChannelPair = ASDataChannelPair()
    
    // MARK: - Initialization
    
    init(iceServers: [RTCIceServer], dataChannelLabel: String, factory: ASPeerFactory) {
        super.init()
        
        let configuration = factory.makeDataChannelConfiguration()
        let peerConnection = factory.makePeerConnection(iceServers: iceServers, delegate: self)
        let dataChannel = peerConnection.dataChannel(forLabel: dataChannelLabel, configuration: configuration, delegate: self)
        
        self.peerConnection = peerConnection
        self.dataChannelPair = ASDataChannelPair(sender: nil, receiver: dataChannel)
    }
    
    // MARK: - Access methods
    
    func setLocalDescription(_ sdp: RTCSessionDescription, completionHandler: ((Error?) -> Void)? = nil) {
        self.peerConnection?.setLocalDescription(sdp, completionHandler: completionHandler)
    }
    
    func setRemoteDescription(_ sdp: RTCSessionDescription, completionHandler: ((Error?) -> Void)? = nil) {
        self.peerConnection?.setRemoteDescription(sdp, completionHandler: completionHandler)
    }
    
    func offer(for constraints: RTCMediaConstraints, completionHandler: ((RTCSessionDescription?, Error?) -> Void)? = nil) {
        self.peerConnection?.offer(for: constraints, completionHandler: completionHandler)
    }
    
    func answer(for constraints: RTCMediaConstraints, completionHandler: ((RTCSessionDescription?, Error?) -> Void)? = nil) {
        self.peerConnection?.answer(for: constraints, completionHandler: completionHandler)
    }
    
    func add(_ candidate: RTCIceCandidate) {
        self.peerConnection?.add(candidate)
    }
    
    func remove(_ candidates: [RTCIceCandidate]) {
        self.peerConnection?.remove(candidates)
    }
    
    func add(_ stream: RTCMediaStream) {
        self.peerConnection?.add(stream)
    }
    
    func remove(_ stream: RTCMediaStream) {
        self.peerConnection?.remove(stream)
    }
    
    func close() {
        self.peerConnection?.close()
        self.dataChannelPair.sender?.close()
        self.dataChannelPair.receiver?.close()
    }
}

// MARK: - Data management

extension ASPeer {
    public func sendBinaryData(_ data: Data) {
        let buffer = RTCDataBuffer(data: data, isBinary: true)
        self.dataChannelPair.sender?.sendData(buffer)
    }
    
    public func sendData(_ data: Data) {
        let buffer = RTCDataBuffer(data: data, isBinary: false)
        self.dataChannelPair.sender?.sendData(buffer)
    }
}

// MARK: - Statistics

extension ASPeer {
    public func stats(for mediaStreamTrack: RTCMediaStreamTrack?,
                      statsOutputLevel: RTCStatsOutputLevel,
                      completionHandler: (([RTCLegacyStatsReport]) -> Void)? = nil) {
        
        self.peerConnection?.stats(for: mediaStreamTrack,
                                   statsOutputLevel: statsOutputLevel,
                                   completionHandler: completionHandler)
    }
}


// MARK: - RTCPeerConnectionDelegate

extension ASPeer: RTCPeerConnectionDelegate {
    public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        DispatchQueue.main.async {
            self.delegate?.peerShouldNegotiate(self)
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        DispatchQueue.main.async {
            self.delegate?.peer(self, didChangeSignalingState: stateChanged)
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        DispatchQueue.main.async {
            self.delegate?.peer(self, didAddStream: stream)
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        DispatchQueue.main.async {
            self.delegate?.peer(self, didRemoveStream: stream)
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        DispatchQueue.main.async {
            self.delegate?.peer(self, didChangeConnectionState: newState)
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        DispatchQueue.main.async {
            self.delegate?.peer(self, didChangeGatheringState: newState)
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        DispatchQueue.main.async {
            self.delegate?.peer(self, didGenerateCandidate: candidate)
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        DispatchQueue.main.async {
            self.delegate?.peer(self, didRemoveCandidates: candidates)
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        DispatchQueue.main.async {
            self.dataChannelPair.sender = dataChannel
            self.delegate?.peer(self, didChangeSenderDataChannelState: dataChannel.readyState)
        }
    }
}

// MARK: - RTCDataChannelDelegate

extension ASPeer: RTCDataChannelDelegate {
    public func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        DispatchQueue.main.async {
            self.delegate?.peer(self, didChangeReceiverDataChannelState: dataChannel.readyState)
        }
    }
    
    public func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        DispatchQueue.main.async {
            self.delegate?.peer(self, didReceiveData: buffer.data)
        }
    }
}

// MARK: - RTCPeerConnection

extension RTCPeerConnection {
    func dataChannel(forLabel label: String,
                     configuration: RTCDataChannelConfiguration,
                     delegate: RTCDataChannelDelegate?) -> RTCDataChannel? {
        let dataChannel = self.dataChannel(forLabel: label, configuration: configuration)
        dataChannel?.delegate = delegate
        
        return dataChannel
    }
}
