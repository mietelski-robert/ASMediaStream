//
//  ASMediaStreamClient.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

public class ASMediaStreamClient: NSObject {

    // MARK: - Public attributes
    
    public var isVideoEnabled: Bool = true {
        didSet {
            guard let mediaStream = self.localStream, isVideoEnabled != oldValue else {
                return
            }
            do {
                if isVideoEnabled {
                    try self.enableVideo(for: mediaStream)
                } else {
                    try self.disableVideo(for: mediaStream)
                }
            } catch {
                self.delegate?.mediaStreamClient(self, didFailWithError: error)
            }
        }
    }
    
    public var isAudioEnabled: Bool = true {
        didSet {
            guard let mediaStream = self.localStream, isAudioEnabled != oldValue else {
                return
            }
            do {
                if isAudioEnabled {
                    try self.enableAudio(for: mediaStream)
                } else {
                    try self.disableAudio(for: mediaStream)
                }
            } catch {
                self.delegate?.mediaStreamClient(self, didFailWithError: error)
            }
        }
    }
    
    public var videoTrack: RTCVideoTrack? {
        guard let streamId = self.localStream?.streamId else {
            return nil
        }
        return self.videoTrackCasche[streamId]
    }
    
    public var audioTrack: RTCAudioTrack? {
        guard let streamId = self.localStream?.streamId else {
            return nil
        }
        return self.audioTrackCasche[streamId]
    }
    
    public var peers: [ASPeer] {
        return Array(self.peerDictionary.values)
    }
    
    public private(set) var iceServers: [RTCIceServer]
    public private(set) var videoCapturer: ASVideoCapturer?
    public private(set) var state: ASMediaStreamClientState = .disconnected
    
    public weak var delegate: ASMediaStreamClientDelegate?
    
    // MARK: - Private attributes
    
    private let peerFactory: ASPeerFactory
    private let streamFactory: ASMediaStreamFactory
    private let sessionFactory: ASMediaStreamSessionFactory
    private var peerDictionary: [String: ASPeer] = [:]
    
    private var audioTrackCasche = [String: RTCAudioTrack]()
    private var videoTrackCasche = [String: RTCVideoTrack]()
    private var session: ASMediaStreamSession?
    private var localStream: RTCMediaStream?
    
    // MARK: - Initialization
    
    public init(iceServers: [RTCIceServer], sessionFactory: ASMediaStreamSessionFactory, peerConnectionFactory: RTCPeerConnectionFactory) {
        self.iceServers = iceServers
        self.sessionFactory = sessionFactory
        self.peerFactory = ASPeerFactory(peerConnectionFactory: peerConnectionFactory)
        self.streamFactory = ASMediaStreamFactory(peerConnectionFactory: peerConnectionFactory)
        
        super.init()
    }
    
    public convenience init(iceServers: [RTCIceServer], sessionFactory: ASMediaStreamSessionFactory) {
        self.init(iceServers: iceServers, sessionFactory: sessionFactory, peerConnectionFactory: RTCPeerConnectionFactory())
    }
    
    deinit {
        self.disconnect()
    }
}

// MARK: - Authorization state

extension ASMediaStreamClient {
    public struct AuthorizationState {
        public static var isVideoEnabled: Bool {
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            return status == .authorized
        }
        
        public static var isAudioEnabled: Bool {
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
            return status == .authorized
        }
    }
}

// MARK: - Authorization management

extension ASMediaStreamClient {
    private struct MediaIdentifiers {
        static let localStream = "LocalStream"
        static let videoTrack = "VideoTrack"
        static let audioTrack = "AudioTrack"
    }
}

// MARK: - Connection management

extension ASMediaStreamClient {
    public func connectToRoom(name roomName: String, parameters: [String: Any] = [:]) {
        do {
            guard self.state == .disconnected else {
                throw ASMediaStreamClientError.joiningRoomFailed
            }
            self.changeState(to: .connecting)
            
            self.session = self.sessionFactory.makeSession(roomName: roomName, delegate: self)
            self.session?.join(parameters: parameters) { [weak self] in
                guard let caller = self else { return }
                
                do {
                    let mediaStream = caller.streamFactory.makeMediaStream(withStreamId: MediaIdentifiers.localStream)
      
                    if caller.isVideoEnabled {
                        try caller.enableVideo(for: mediaStream)
                    }
                    if caller.isAudioEnabled {
                        try caller.enableAudio(for: mediaStream)
                    }
                    caller.localStream = mediaStream
                } catch {
                    caller.delegate?.mediaStreamClient(caller, didFailWithError: error)
                }
            }
        } catch {
            self.delegate?.mediaStreamClient(self, didFailWithError: error)
        }
    }
    
    public func disconnect() {
        for peer in self.peers {
            peer.close()
        }

        self.audioTrackCasche = [:]
        self.videoTrackCasche = [:]
        self.session?.leave()
        
        self.changeState(to: .disconnected)
        
        self.peerDictionary = [:]
        self.localStream = nil
        self.session = nil
    }
}

// MARK: - Video management

extension ASMediaStreamClient {
    private func getVideoTrack(for streamId: String) throws -> RTCVideoTrack {
        guard AuthorizationState.isVideoEnabled else {
            throw ASMediaStreamClientError.enableVideoFailed
        }
        let videoTrack: RTCVideoTrack
        
        if let track = self.videoTrackCasche[streamId] {
            videoTrack = track
        } else {
            videoTrack = self.streamFactory.makeVideoTrack(withTrackId: MediaIdentifiers.videoTrack)
            self.videoTrackCasche[streamId] = videoTrack
        }
        videoTrack.isEnabled = true
        
        return videoTrack
    }
    
    private func enableVideo(for mediaStream: RTCMediaStream) throws {
        let videoTrack = try self.getVideoTrack(for: mediaStream.streamId)
        let capturer = RTCCameraVideoCapturer(delegate: videoTrack.source)
        mediaStream.addVideoTrack(videoTrack)
        
        self.videoCapturer = ASVideoCapturer(capturer: capturer)
        self.delegate?.mediaStreamClient(self, didReceiveVideoTrack: videoTrack)
    }
    
    private func disableVideo(for mediaStream: RTCMediaStream) throws {
        guard let videoTrack = self.videoTrackCasche[mediaStream.streamId] else {
            throw ASMediaStreamClientError.disableVideoFailed
        }
        mediaStream.removeVideoTrack(videoTrack)
        
        self.videoCapturer = nil
        self.delegate?.mediaStreamClient(self, didDiscardVideoTrack: videoTrack)
    }
}

// MARK: - Audio management

extension ASMediaStreamClient {
    private func getAudioTrack(for streamId: String) throws -> RTCAudioTrack {
        guard AuthorizationState.isAudioEnabled else {
            throw ASMediaStreamClientError.enableAudioFailed
        }
        let audioTrack: RTCAudioTrack
        
        if let track = self.audioTrackCasche[streamId] {
            audioTrack = track
        } else {
            audioTrack = self.streamFactory.makeAudioTrack(withTrackId: MediaIdentifiers.audioTrack)
            self.audioTrackCasche[streamId] = audioTrack
        }
        return audioTrack
    }
    
    private func enableAudio(for mediaStream: RTCMediaStream) throws {
        let audioTrack = try self.getAudioTrack(for: mediaStream.streamId)
        mediaStream.addAudioTrack(audioTrack)
        
        self.delegate?.mediaStreamClient(self, didReceiveAudioTrack: audioTrack)
    }
    
    private func disableAudio(for mediaStream: RTCMediaStream) throws {
        guard let audioTrack = self.audioTrackCasche[mediaStream.streamId] else {
            throw ASMediaStreamClientError.disableAudioFailed
        }
        mediaStream.removeAudioTrack(audioTrack)
        
        self.delegate?.mediaStreamClient(self, didDiscardAudioTrack: audioTrack)
    }
}

// MARK: - Peer management

extension ASMediaStreamClient {
    private func setPeer(_ peer: ASPeer?, forIdentifier identifier: String) {
        self.peerDictionary[identifier] = peer
    }
    
    public func peer(identifier: String) -> ASPeer? {
        return self.peerDictionary[identifier]
    }
    
    public func identifier(peer: ASPeer) -> String? {
        return self.peerDictionary.first(where: { $1 === peer })?.key
    }
}

// MARK: - Configuration

extension ASMediaStreamClient {
    private func makePeer(peerId: String) -> ASPeer {
        let peer = ASPeer(identifier: peerId, iceServers: self.iceServers, factory: self.peerFactory)
        peer.delegate = self
        
        return peer
    }

    private func changeState(to state: ASMediaStreamClientState) {
        if state != self.state {
            self.state = state
            self.delegate?.mediaStreamClient(self, didChangeState: state)
        }
    }
}

// MARK: - Message management

extension ASMediaStreamClient {
    private func sendOffer(receiverId: String?, peer: ASPeer?) {
        let constraints = self.streamFactory.makeStreamConstraints(isVideoEnabled: self.isVideoEnabled, isAudioEnabled: self.isAudioEnabled)
        
        peer?.offer(for: constraints) { [weak self, weak peer] (sessionDescription, error) in
            guard let caller = self else { return }
            
            if let sessionDescription = sessionDescription {
                peer?.setLocalDescription(sessionDescription) { [weak self] error in
                    guard let caller = self else { return }
                    
                    if let error = error {
                        caller.delegate?.mediaStreamClient(caller, didFailWithError: error)
                    } else {
                        let request = ASSessionDescriptionRequest(receiverId: receiverId, sessionDescription: sessionDescription)
                        caller.session?.send(request)
                    }
                }
            } else if let error = error {
                caller.delegate?.mediaStreamClient(caller, didFailWithError: error)
            }
        }
    }
    
    private func sendAnswer(receiverId: String?, peer: ASPeer?) {
        let constraints = self.streamFactory.makeStreamConstraints(isVideoEnabled: self.isVideoEnabled, isAudioEnabled: self.isAudioEnabled)
        
        peer?.answer(for: constraints) { [weak self, weak peer] (sessionDescription, error) in
            guard let caller = self else { return }
            
            if let sessionDescription = sessionDescription {
                peer?.setLocalDescription(sessionDescription) { [weak self] error in
                    guard let caller = self else { return }
                    
                    if let error = error {
                        caller.delegate?.mediaStreamClient(caller, didFailWithError: error)
                    } else {
                        let request = ASSessionDescriptionRequest(receiverId: receiverId, sessionDescription: sessionDescription)
                        caller.session?.send(request)
                    }
                }
            } else if let error = error {
                caller.delegate?.mediaStreamClient(caller, didFailWithError: error)
            }
        }
    }
}

// MARK: - RTCPeerConnectionDelegate

extension ASMediaStreamClient: ASPeerDelegate {
    func peer(_ peer: ASPeer, didAddStream stream: RTCMediaStream) {
        self.delegate?.mediaStreamClient(self, peer: peer, didReceiveVideoTracks: stream.videoTracks)
        self.delegate?.mediaStreamClient(self, peer: peer, didReceiveAudioTracks: stream.audioTracks)
    }
    
    func peer(_ peer: ASPeer, didRemoveStream stream: RTCMediaStream) {
        self.delegate?.mediaStreamClient(self, peer: peer, didDiscardVideoTracks: stream.videoTracks)
        self.delegate?.mediaStreamClient(self, peer: peer, didDiscardAudioTracks: stream.audioTracks)
    }

    func peer(_ peer: ASPeer, didChangeConnectionState state: RTCIceConnectionState) {
        if case .closed = state, let identifier = self.identifier(peer: peer) {
            self.setPeer(nil, forIdentifier: identifier)
            
            if let mediaStream = self.localStream {
                peer.remove(mediaStream)
            }
        }
        self.delegate?.mediaStreamClient(self, peer: peer, didChangeConnectionState: state)
    }
    
    func peer(_ peer: ASPeer, didGenerateCandidate candidate: RTCIceCandidate) {
        if let state = self.session?.state, case .joined(_) = state {
            let receiverId = self.identifier(peer: peer)
            self.session?.send(ASCandidateRequest(receiverId: receiverId, candidate: candidate))
        }
    }
    
    func peer(_ peer: ASPeer, didChangeSenderDataChannelState state: RTCDataChannelState) {
        self.delegate?.mediaStreamClient(self, peer: peer, didChangeSenderDataChannelState: state)
    }
    
    func peer(_ peer: ASPeer, didChangeReceiverDataChannelState state: RTCDataChannelState) {
        self.delegate?.mediaStreamClient(self, peer: peer, didChangeReceiverDataChannelState: state)
    }

    func peer(_ peer: ASPeer, didReceiveData data: Data) {
        self.delegate?.mediaStreamClient(self, peer: peer, didReceiveData: data)
    }
}

// MARK: - ASMediaStreamSessionDelegate

extension ASMediaStreamClient: ASMediaStreamSessionDelegate {
    public func mediaStreamSession(_ session: ASMediaStreamSession, didChangeState state: ASMediaStreamSessionState) {
        switch state {
        case .open:
            self.changeState(to: .connected)
        case .joined(let members):
            for identifier in members {
                let peer = self.makePeer(peerId: identifier)
                
                if let mediaStream = self.localStream {
                    peer.add(mediaStream)
                }
                self.setPeer(peer, forIdentifier: identifier)
                self.sendOffer(receiverId: identifier, peer: peer)
            }
        case .closed:
            self.disconnect()
        }
    }
    
    public func mediaStreamSession(_ session: ASMediaStreamSession, didReceiveSessionDescriptionResponse response: ASSessionDescriptionResponse) {
        let peer: ASPeer
        
        if let currentPeer = self.peer(identifier: response.senderId) {
            peer = currentPeer
        } else {
            peer = self.makePeer(peerId: response.senderId)
            
            if let mediaStream = self.localStream {
                peer.add(mediaStream)
            }
            self.setPeer(peer, forIdentifier: response.senderId)
        }
        
        peer.setRemoteDescription(response.sessionDescription) { [weak self, weak peer] error in
            guard let caller = self else { return }
            
            if let error = error {
                caller.delegate?.mediaStreamClient(caller, didFailWithError: error)
            } else if response.sessionDescription.type == .offer {
                caller.sendAnswer(receiverId: response.senderId, peer: peer)
            }
        }
    }
    
    public func mediaStreamSession(_ session: ASMediaStreamSession, didReceiveCandidateResponse response: ASCandidateResponse) {
        let peer = self.peer(identifier: response.senderId)
        peer?.add(response.candidate)
    }
    
    public func mediaStreamSession(_ session: ASMediaStreamSession, didFailWithError error: Error) {
        self.delegate?.mediaStreamClient(self, didFailWithError: error)
    }
}
