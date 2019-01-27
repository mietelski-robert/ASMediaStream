//
//  ASPeerDelegate.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 27.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

protocol ASPeerDelegate: class {
    func peerShouldNegotiate(_ peer: ASPeer)
    func peer(_ peer: ASPeer, didChangeSignalingState stateChanged: RTCSignalingState)
    func peer(_ peer: ASPeer, didAddStream stream: RTCMediaStream)
    func peer(_ peer: ASPeer, didRemoveStream stream: RTCMediaStream)
    func peer(_ peer: ASPeer, didChangeConnectionState newState: RTCIceConnectionState)
    func peer(_ peer: ASPeer, didChangeGatheringState newState: RTCIceGatheringState)
    func peer(_ peer: ASPeer, didGenerateCandidate candidate: RTCIceCandidate)
    func peer(_ peer: ASPeer, didRemoveCandidates candidates: [RTCIceCandidate])
    func peer(_ peer: ASPeer, didChangeSenderDataChannelState state: RTCDataChannelState)
    func peer(_ peer: ASPeer, didChangeReceiverDataChannelState state: RTCDataChannelState)
    func peer(_ peer: ASPeer, didReceiveData data: Data)
}

extension ASPeerDelegate {
    func peerShouldNegotiate(_ peer: ASPeer) {}
    func peer(_ peer: ASPeer, didChangeSignalingState stateChanged: RTCSignalingState) {}
    func peer(_ peer: ASPeer, didAddStream stream: RTCMediaStream) {}
    func peer(_ peer: ASPeer, didRemoveStream stream: RTCMediaStream) {}
    func peer(_ peer: ASPeer, didChangeConnectionState newState: RTCIceConnectionState) {}
    func peer(_ peer: ASPeer, didChangeGatheringState newState: RTCIceGatheringState) {}
    func peer(_ peer: ASPeer, didGenerateCandidate candidate: RTCIceCandidate) {}
    func peer(_ peer: ASPeer, didRemoveCandidates candidates: [RTCIceCandidate]) {}
    func peer(_ peer: ASPeer, didChangeSenderDataChannelState state: RTCDataChannelState) {}
    func peer(_ peer: ASPeer, didChangeReceiverDataChannelState state: RTCDataChannelState) {}
    func peer(_ peer: ASPeer, didReceiveData data: Data) {}
}
