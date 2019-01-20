//
//  ASMediaStreamClientDelegate.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import Foundation

public protocol ASMediaStreamClientDelegate: class {
    func mediaStreamClient(_ client: ASMediaStreamClient, didChangeState state: ASMediaStreamClientState)
    func mediaStreamClient(_ client: ASMediaStreamClient, didReceiveLocalVideo output: ASVideoOutput)
    func mediaStreamClient(_ client: ASMediaStreamClient, didDiscardLocalVideo output: ASVideoOutput)
    func mediaStreamClient(_ client: ASMediaStreamClient, didReceiveLocalAudio output: ASAudioOutput)
    func mediaStreamClient(_ client: ASMediaStreamClient, didDiscardLocalAudio output: ASAudioOutput)
    func mediaStreamClient(_ client: ASMediaStreamClient, didReceiveRemoteVideo output: ASVideoOutput)
    func mediaStreamClient(_ client: ASMediaStreamClient, didDiscardRemoteVideo output: ASVideoOutput)
    func mediaStreamClient(_ client: ASMediaStreamClient, didReceiveRemoteAudio output: ASAudioOutput)
    func mediaStreamClient(_ client: ASMediaStreamClient, didDiscardRemoteAudio output: ASAudioOutput)
    func mediaStreamClient(_ client: ASMediaStreamClient, didOpenDataChannelWithPeer peerId: String)
    func mediaStreamClient(_ client: ASMediaStreamClient, didReceiveData output: ASDataOutput)
    func mediaStreamClient(_ client: ASMediaStreamClient, didFailWithError error: Error)
}
