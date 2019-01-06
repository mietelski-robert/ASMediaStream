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
    
    public private(set) var iceServers: [RTCIceServer]
    public private(set) var videoCapturer: ASVideoCapturer?
    public private(set) var state: ASMediaStreamClientState = .disconnected
    
    public weak var delegate: ASMediaStreamClientDelegate?
    
    // MARK: - Private attributes
    
    private let connectionFactory = ASMediaStreamConnectionFactory()
    private let sessionFactory: ASMediaStreamSessionFactory
    private var peerConnection: RTCPeerConnection?
    
    private var audioTrackCasche = [String: RTCAudioTrack]()
    private var videoTrackCasche = [String: RTCVideoTrack]()
    private var session: ASMediaStreamSession?
    private var localStream: RTCMediaStream?
    
    // MARK: - Initialization
    
    public init(iceServers: [RTCIceServer], sessionFactory: ASMediaStreamSessionFactory) {
        self.iceServers = iceServers
        self.sessionFactory = sessionFactory
        super.init()
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
    public func connectToRoom(name roomName: String) {
        do {
            guard self.state == .disconnected else {
                throw ASMediaStreamClientError.alredyConnected
            }
            self.changeState(to: .connecting)
            
            self.session = self.sessionFactory.makeSession(roomName: roomName, delegate: self)
            self.session?.join() { [weak self] in
                guard let caller = self else { return }
                
                do {
                    let mediaStream = caller.connectionFactory.makeMediaStream(withStreamId: MediaIdentifiers.localStream)
      
                    if caller.isVideoEnabled {
                        try caller.enableVideo(for: mediaStream)
                    }
                    if caller.isAudioEnabled {
                        try caller.enableAudio(for: mediaStream)
                    }
                    caller.peerConnection = caller.connectionFactory.makePeerConnection(iceServers: caller.iceServers, delegate: self)
                    caller.peerConnection?.add(mediaStream)
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
        self.peerConnection?.close()
        self.session?.leave()
        
        if let mediaStream = self.localStream {
            self.peerConnection?.remove(mediaStream)
        }
        self.audioTrackCasche = [:]
        self.videoTrackCasche = [:]
        
        self.changeState(to: .disconnected)
        
        self.peerConnection = nil
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
            videoTrack = self.connectionFactory.makeVideoTrack(withTrackId: MediaIdentifiers.videoTrack)
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
        self.delegate?.mediaStreamClient(self, didReceiveLocalVideoTrack: videoTrack)
    }
    
    private func disableVideo(for mediaStream: RTCMediaStream) throws {
        guard let videoTrack = self.videoTrackCasche[mediaStream.streamId] else {
            throw ASMediaStreamClientError.disableVideoFailed
        }
        mediaStream.removeVideoTrack(videoTrack)
        
        self.videoCapturer = nil
        self.delegate?.mediaStreamClient(self, didDiscardLocalVideoTrack: videoTrack)
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
            audioTrack = self.connectionFactory.makeAudioTrack(withTrackId: MediaIdentifiers.audioTrack)
            self.audioTrackCasche[streamId] = audioTrack
        }
        return audioTrack
    }
    
    private func enableAudio(for mediaStream: RTCMediaStream) throws {
        let audioTrack = try self.getAudioTrack(for: mediaStream.streamId)
        mediaStream.addAudioTrack(audioTrack)
        
        self.delegate?.mediaStreamClient(self, didReceiveLocalAudioTrack: audioTrack)
    }
    
    private func disableAudio(for mediaStream: RTCMediaStream) throws {
        guard let audioTrack = self.audioTrackCasche[mediaStream.streamId] else {
            throw ASMediaStreamClientError.disableAudioFailed
        }
        mediaStream.removeAudioTrack(audioTrack)
        
        self.delegate?.mediaStreamClient(self, didDiscardLocalAudioTrack: audioTrack)
    }
}

extension ASMediaStreamClient {
    private func changeState(to state: ASMediaStreamClientState) {
        if state != self.state {
            self.state = state
            self.delegate?.mediaStreamClient(self, didChangeState: state)
        }
    }
}

// MARK: - Message management

extension ASMediaStreamClient {
    private func sendOffer() {
        let constraints = self.connectionFactory.makeStreamConstraints(isVideoEnabled: false, isAudioEnabled: false)
        
        self.peerConnection?.offer(for: constraints) { [weak self] (sessionDescription, error) in
            guard let caller = self else { return }
            
            if let sessionDescription = sessionDescription {
                caller.peerConnection?.setLocalDescription(sessionDescription) { [weak self] error in
                    guard let caller = self else { return }
                    
                    if let error = error {
                        caller.delegate?.mediaStreamClient(caller, didFailWithError: error)
                    } else {
                        let request = ASSessionDescriptionRequest(sessionDescription: sessionDescription)
                        caller.session?.send(request)
                    }
                }
            } else if let error = error {
                caller.delegate?.mediaStreamClient(caller, didFailWithError: error)
            }
        }
    }
    
    private func sendAnswer(receiverId: String?) {
        let constraints = self.connectionFactory.makeStreamConstraints(isVideoEnabled: self.isVideoEnabled, isAudioEnabled: self.isAudioEnabled)
        
        self.peerConnection?.answer(for: constraints) { [weak self] (sessionDescription, error) in
            guard let caller = self else { return }
            
            if let sessionDescription = sessionDescription {
                caller.peerConnection?.setLocalDescription(sessionDescription) { [weak self] error in
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

extension ASMediaStreamClient: RTCPeerConnectionDelegate {
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        DispatchQueue.main.async {
            self.delegate?.mediaStreamClient(self, didReceiveRemoteVideoTracks: stream.videoTracks)
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        DispatchQueue.main.async {
            self.delegate?.mediaStreamClient(self, didDiscardRemoteVideoTracks: stream.videoTracks)
        }
    }
    
    public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {

    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {

    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        DispatchQueue.main.async {
            if let state = self.session?.state, case .joined(_) = state {
                self.session?.send(ASCandidateRequest(candidate: candidate))
            }
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {

    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        
    }
}

// MARK: - ASMediaStreamSessionDelegate

extension ASMediaStreamClient: ASMediaStreamSessionDelegate {
    public func mediaStreamSession(_ session: ASMediaStreamSession, didChangeState state: ASMediaStreamSessionState) {
        switch state {
        case .open:
            self.changeState(to: .connected)
        case .joined(let roomMembers):
            if roomMembers > 1 {
                self.sendOffer()
            }
        case .closed:
            self.disconnect()
        }
    }
    
    public func mediaStreamSession(_ session: ASMediaStreamSession, didReceiveSessionDescriptionResponse response: ASSessionDescriptionResponse) {
        self.peerConnection?.setRemoteDescription(response.sessionDescription) { [weak self] error in
            guard let caller = self else { return }
            
            if let error = error {
                caller.delegate?.mediaStreamClient(caller, didFailWithError: error)
            } else if response.sessionDescription.type == .offer {
                caller.sendAnswer(receiverId: response.senderId)
            }
        }
    }
    
    public func mediaStreamSession(_ session: ASMediaStreamSession, didReceiveCandidateResponse response: ASCandidateResponse) {
        self.peerConnection?.add(response.candidate)
    }
    
    public func mediaStreamSession(_ session: ASMediaStreamSession, didFailWithError error: Error) {
        self.delegate?.mediaStreamClient(self, didFailWithError: error)
    }
}