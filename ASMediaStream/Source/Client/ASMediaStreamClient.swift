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
    private var container = ASMediaStreamContainer()
    
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
                throw ASMediaStreamClientError.joiningRoomFailed
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
        for item in self.container.items {
            if let mediaStream = self.localStream {
                item.peerConnection?.remove(mediaStream)
            }
            item.peerConnection?.close()
            item.dataChannelPair.sender?.close()
            item.dataChannelPair.receiver?.close()
        }

        self.audioTrackCasche = [:]
        self.videoTrackCasche = [:]
        self.session?.leave()
        
        self.changeState(to: .disconnected)
        
        self.container = ASMediaStreamContainer()
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
        self.delegate?.mediaStreamClient(self, didReceiveLocalVideo: ASVideoOutput(videoTracks: [videoTrack]))
    }
    
    private func disableVideo(for mediaStream: RTCMediaStream) throws {
        guard let videoTrack = self.videoTrackCasche[mediaStream.streamId] else {
            throw ASMediaStreamClientError.disableVideoFailed
        }
        mediaStream.removeVideoTrack(videoTrack)
        
        self.videoCapturer = nil
        self.delegate?.mediaStreamClient(self, didDiscardLocalVideo: ASVideoOutput(videoTracks: [videoTrack]))
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
        
        self.delegate?.mediaStreamClient(self, didReceiveLocalAudio: ASAudioOutput(audioTracks: [audioTrack]))
    }
    
    private func disableAudio(for mediaStream: RTCMediaStream) throws {
        guard let audioTrack = self.audioTrackCasche[mediaStream.streamId] else {
            throw ASMediaStreamClientError.disableAudioFailed
        }
        mediaStream.removeAudioTrack(audioTrack)
        
        self.delegate?.mediaStreamClient(self, didDiscardLocalAudio: ASAudioOutput(audioTracks: [audioTrack]))
    }
}

// MARK: - Data management

extension ASMediaStreamClient {
    public func sendBinaryData(_ data: Data, clientId: String) {
        let buffer = RTCDataBuffer(data: data, isBinary: true)
        
        if let item = self.container.item(identifier: clientId) {
            item.dataChannelPair.sender?.sendData(buffer)
        } else {
            self.delegate?.mediaStreamClient(self, didFailWithError: ASMediaStreamClientError.sendingDataFailed)
        }
    }
    
    public func sendData(_ data: Data, clientId: String) {
        let buffer = RTCDataBuffer(data: data, isBinary: false)

        if let item = self.container.item(identifier: clientId) {
            item.dataChannelPair.sender?.sendData(buffer)
        } else {
            self.delegate?.mediaStreamClient(self, didFailWithError: ASMediaStreamClientError.sendingDataFailed)
        }
    }
}

// MARK: - Configuration

extension ASMediaStreamClient {
    private func makeMediaStreamItem(dataChannelLabel label: String) -> ASMediaStreamItem {
        let peerConnection = self.connectionFactory.makePeerConnection(iceServers: self.iceServers, delegate: self)
        let configuration = self.connectionFactory.makeDataChannelConfiguration()
        
        let dataChannel = peerConnection.dataChannel(forLabel: label, configuration: configuration)
        dataChannel?.delegate = self
        
        return ASMediaStreamItem(peerConnection: peerConnection,
                                 dataChannelPair: ASDataChannelPair(sender: nil, receiver: dataChannel))
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
    private func sendOffer(receiverId: String?, peerConnection: RTCPeerConnection?) {
        let constraints = self.connectionFactory.makeStreamConstraints(isVideoEnabled: self.isVideoEnabled, isAudioEnabled: self.isAudioEnabled)
        
        peerConnection?.offer(for: constraints) { [weak self, weak peerConnection] (sessionDescription, error) in
            guard let caller = self else { return }
            
            if let sessionDescription = sessionDescription {
                peerConnection?.setLocalDescription(sessionDescription) { [weak self] error in
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
    
    private func sendAnswer(receiverId: String?, peerConnection: RTCPeerConnection?) {
        let constraints = self.connectionFactory.makeStreamConstraints(isVideoEnabled: self.isVideoEnabled, isAudioEnabled: self.isAudioEnabled)
        
        peerConnection?.answer(for: constraints) { [weak self, weak peerConnection] (sessionDescription, error) in
            guard let caller = self else { return }
            
            if let sessionDescription = sessionDescription {
                peerConnection?.setLocalDescription(sessionDescription) { [weak self] error in
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
            let clientId = self.container.identifier(peerConnection: peerConnection)
            let video = ASVideoOutput(clientId: clientId, videoTracks: stream.videoTracks)
            let audio = ASAudioOutput(clientId: clientId, audioTracks: stream.audioTracks)
            
            self.delegate?.mediaStreamClient(self, didReceiveRemoteVideo: video)
            self.delegate?.mediaStreamClient(self, didReceiveRemoteAudio: audio)
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        DispatchQueue.main.async {
            let clientId = self.container.identifier(peerConnection: peerConnection)
            let video = ASVideoOutput(clientId: clientId, videoTracks: stream.videoTracks)
            let audio = ASAudioOutput(clientId: clientId, audioTracks: stream.audioTracks)
            
            self.delegate?.mediaStreamClient(self, didDiscardRemoteVideo: video)
            self.delegate?.mediaStreamClient(self, didDiscardRemoteAudio: audio)
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
                let receiverId = self.container.identifier(peerConnection: peerConnection)
                self.session?.send(ASCandidateRequest(receiverId: receiverId, candidate: candidate))
            }
        }
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {

    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        DispatchQueue.main.async {
            if let identifier = self.container.identifier(peerConnection: peerConnection) {
                let previousItem = self.container.item(identifier: identifier)
                let dataChannelPair = ASDataChannelPair(sender: dataChannel, receiver: previousItem?.dataChannelPair.receiver)
                
                self.container.setItem(ASMediaStreamItem(peerConnection: peerConnection, dataChannelPair: dataChannelPair),
                                       forIdentifier: identifier)
            } else {
                self.delegate?.mediaStreamClient(self, didFailWithError: ASMediaStreamClientError.openingChannelFailed)
            }
        }
    }
}

// MARK: - RTCDataChannelDelegate

extension ASMediaStreamClient: RTCDataChannelDelegate {
    public func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {

    }
    
    public func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        DispatchQueue.main.async {
            let clientId = self.container.identifier(receiver: dataChannel)
            let data = ASDataOutput(clientId: clientId, data: buffer.data)
            self.delegate?.mediaStreamClient(self, didReceiveData: data)
        }
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
                let item = self.makeMediaStreamItem(dataChannelLabel: identifier)
                
                if let mediaStream = self.localStream {
                    item.peerConnection?.add(mediaStream)
                }
                self.container.setItem(item, forIdentifier: identifier)
                self.sendOffer(receiverId: identifier, peerConnection: item.peerConnection)
            }
        case .closed:
            self.disconnect()
        }
    }
    
    public func mediaStreamSession(_ session: ASMediaStreamSession, didReceiveSessionDescriptionResponse response: ASSessionDescriptionResponse) {
        let item: ASMediaStreamItem
        
        if let currentItem = self.container.item(identifier: response.senderId) {
            item = currentItem
        } else {
            item = self.makeMediaStreamItem(dataChannelLabel: response.senderId)
            
            if let mediaStream = self.localStream {
                item.peerConnection?.add(mediaStream)
            }
            self.container.setItem(item, forIdentifier: response.senderId)
        }
        
        item.peerConnection?.setRemoteDescription(response.sessionDescription) { [weak self] error in
            guard let caller = self else { return }
            
            if let error = error {
                caller.delegate?.mediaStreamClient(caller, didFailWithError: error)
            } else if response.sessionDescription.type == .offer {
                caller.sendAnswer(receiverId: response.senderId, peerConnection: item.peerConnection)
            }
        }
    }
    
    public func mediaStreamSession(_ session: ASMediaStreamSession, didReceiveCandidateResponse response: ASCandidateResponse) {
        let item = self.container.item(identifier: response.senderId)
        item?.peerConnection?.add(response.candidate)
    }
    
    public func mediaStreamSession(_ session: ASMediaStreamSession, didFailWithError error: Error) {
        self.delegate?.mediaStreamClient(self, didFailWithError: error)
    }
}
