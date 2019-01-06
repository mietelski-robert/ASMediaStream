//
//  ASMediaStreamClientDelegate.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

public protocol ASMediaStreamClientDelegate: class {
    func mediaStreamClient(_ client: ASMediaStreamClient, didReceiveLocalVideoTrack videoTrack: RTCVideoTrack)
    func mediaStreamClient(_ client: ASMediaStreamClient, didDiscardLocalVideoTrack videoTrack: RTCVideoTrack)
    func mediaStreamClient(_ client: ASMediaStreamClient, didReceiveLocalAudioTrack audioTrack: RTCAudioTrack)
    func mediaStreamClient(_ client: ASMediaStreamClient, didDiscardLocalAudioTrack audioTrack: RTCAudioTrack)
    func mediaStreamClient(_ client: ASMediaStreamClient, didReceiveRemoteVideoTracks videoTracks: [RTCVideoTrack])
    func mediaStreamClient(_ client: ASMediaStreamClient, didDiscardRemoteVideoTracks videoTracks: [RTCVideoTrack])
    func mediaStreamClient(_ client: ASMediaStreamClient, didChangeState state: ASMediaStreamClientState)
    func mediaStreamClient(_ client: ASMediaStreamClient, didFailWithError error: Error)
}
