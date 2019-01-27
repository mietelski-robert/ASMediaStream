//
//  ASMediaStreamClientDelegate.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

public protocol ASMediaStreamClientDelegate: class {
    func mediaStreamClient(_ client: ASMediaStreamClient, didChangeState state: ASMediaStreamClientState)
    func mediaStreamClient(_ client: ASMediaStreamClient, didReceiveVideoTrack track: RTCVideoTrack)
    func mediaStreamClient(_ client: ASMediaStreamClient, didDiscardVideoTrack track: RTCVideoTrack)
    func mediaStreamClient(_ client: ASMediaStreamClient, didReceiveAudioTrack track: RTCAudioTrack)
    func mediaStreamClient(_ client: ASMediaStreamClient, didDiscardAudioTrack track: RTCAudioTrack)
    func mediaStreamClient(_ client: ASMediaStreamClient, didFailWithError error: Error)
    
    func mediaStreamClient(_ client: ASMediaStreamClient, peer: ASPeer, didChangeConnectionState state: RTCIceConnectionState)
    func mediaStreamClient(_ client: ASMediaStreamClient, peer: ASPeer, didReceiveVideoTracks tracks: [RTCVideoTrack])
    func mediaStreamClient(_ client: ASMediaStreamClient, peer: ASPeer, didDiscardVideoTracks tracks: [RTCVideoTrack])
    func mediaStreamClient(_ client: ASMediaStreamClient, peer: ASPeer, didReceiveAudioTracks tracks: [RTCAudioTrack])
    func mediaStreamClient(_ client: ASMediaStreamClient, peer: ASPeer, didDiscardAudioTracks tracks: [RTCAudioTrack])
    func mediaStreamClient(_ client: ASMediaStreamClient, peer: ASPeer, didChangeSenderDataChannelState state: RTCDataChannelState)
    func mediaStreamClient(_ client: ASMediaStreamClient, peer: ASPeer, didChangeReceiverDataChannelState state: RTCDataChannelState)
    func mediaStreamClient(_ client: ASMediaStreamClient, peer: ASPeer, didReceiveData data: Data)
}

public extension ASMediaStreamClientDelegate {
    func mediaStreamClient(_ client: ASMediaStreamClient, didReceiveAudioTrack track: RTCAudioTrack) {}
    func mediaStreamClient(_ client: ASMediaStreamClient, didDiscardAudioTrack track: RTCAudioTrack) {}
    
    func mediaStreamClient(_ client: ASMediaStreamClient, peer: ASPeer, didReceiveAudioTracks tracks: [RTCAudioTrack]) {}
    func mediaStreamClient(_ client: ASMediaStreamClient, peer: ASPeer, didDiscardAudioTracks tracks: [RTCAudioTrack]) {}
    func mediaStreamClient(_ client: ASMediaStreamClient, peer: ASPeer, didChangeSenderDataChannelState state: RTCDataChannelState) {}
    func mediaStreamClient(_ client: ASMediaStreamClient, peer: ASPeer, didChangeReceiverDataChannelState state: RTCDataChannelState) {}
    func mediaStreamClient(_ client: ASMediaStreamClient, peer: ASPeer, didReceiveData data: Data) {}
}
